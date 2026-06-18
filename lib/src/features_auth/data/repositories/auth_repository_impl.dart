import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/driver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final String apiUrl = "http://192.168.100.100:3000/api/drivers";
  final AuthLocalDataSource localDataSource = AuthLocalDataSource();
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource) {
    // 📡 Monitoreo constante en segundo plano
    Connectivity().onConnectivityChanged.listen((event) async {
      final List<ConnectivityResult> results = event is List 
          ? List<ConnectivityResult>.from(event) 
          : [event as ConnectivityResult];
      
      if (results.isNotEmpty && !results.contains(ConnectivityResult.none)) {
        print("📶 [REPOSITORIO] ¡Conexión de red detectada en segundo plano!");
        await Future.delayed(const Duration(seconds: 2));
        await _sincronizarDatosPendientes();
      }
    });
  }

  @override
  Future<Driver> login(String email, String password) async {
    final pendientes = localDataSource.obtenerRegistrosPendientes();
    final usuarioEncontrado = pendientes.firstWhere(
      (conductor) => conductor['email'] == email && conductor['password'] == password,
      orElse: () => {},
    );

    if (usuarioEncontrado.isNotEmpty) {
      return Driver(
        id: "offline_session",
        name: usuarioEncontrado['name'] ?? 'Conductor',
        email: usuarioEncontrado['email'] ?? email,
        vehiclePlate: usuarioEncontrado['plate'] ?? '',
      );
    }
    throw Exception("No se encontró sesión local disponible.");
  }

  @override
  Future<Driver> register(String name, String email, String password, String vehiclePlate) async {
    // 1. Guardar preventivo inmediato en local (Hive) siempre
    final datosConductorOffline = {
      'name': name,
      'email': email,
      'password': password,
      'plate': vehiclePlate,
    };
    
    await localDataSource.guardarRegistroLocal(datosConductorOffline);
    print("💾 [REPOSITORIO] Guardado preventivo en Hive completado: $email");

    final driverEntidad = Driver(
      id: "offline_pending",
      name: name,
      email: email,
      vehiclePlate: vehiclePlate,
    );

    // 2. Comprobación síncrona obligatoria: Esperamos el envío antes de continuar
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final tieneInternet = connectivityResult is List 
          ? !connectivityResult.contains(ConnectivityResult.none)
          : connectivityResult != ConnectivityResult.none;

      if (tieneInternet) {
        print("🌐 [REPOSITORIO] Red activa detectada. Sincronizando inmediatamente...");
        // 🔥 CLAVE: El await retiene el flujo para garantizar la salida del paquete HTTP
        await _sincronizarDatosPendientes(); 
      } else {
        print("📦 [REPOSITORIO] Sin internet en el dispositivo. Permanecerá guardado en Hive.");
      }
    } catch (e) {
      print("⚠️ [REPOSITORIO] Error procesando envío inicial: $e");
    }

    return driverEntidad;
  }

  Future<void> _sincronizarDatosPendientes() async {
    try {
      final pendientes = localDataSource.obtenerRegistrosPendientes();
      if (pendientes.isEmpty) {
        print("🧹 [REPOSITORIO] Hive limpio, nada por subir.");
        return;
      }

      print("📤 [REPOSITORIO] Conectando con la API para vaciar registros...");

      for (var conductor in List.from(pendientes)) {
        try {
          final response = await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(conductor),
          ).timeout(const Duration(seconds: 4));

          if (response.statusCode == 201 || response.statusCode == 200) {
            await localDataSource.borrarDeLocal(conductor['email']);
            print("🗑️ [REPOSITORIO] ¡Sincronizado con éxito!: ${conductor['email']}. Removido de Hive.");
          } else {
            print("⚠️ [REPOSITORIO] API rebotó el dato (${conductor['email']}): ${response.body}");
          }
        } catch (e) {
          print("❌ [REPOSITORIO] Sin respuesta del servidor Node.js para ${conductor['email']}: $e");
          break; 
        }
      }
    } catch (e) {
      print("❌ [REPOSITORIO] Error en proceso maestro de sincronización: $e");
    }
  }
}