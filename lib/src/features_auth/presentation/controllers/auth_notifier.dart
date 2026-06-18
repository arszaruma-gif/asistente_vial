import 'package:flutter/material.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/login_driver_usecase.dart';
import '../../domain/usecases/register_driver_usecase.dart';
import '../../data/datasources/auth_local_datasource.dart'; // 🛠️ Importamos el datasource directo

enum AuthState { initial, loading, success, error }

class AuthNotifier extends ChangeNotifier {
  final LoginDriverUseCase loginUseCase;
  final RegisterDriverUseCase registerUseCase;

  AuthState _state = AuthState.initial;
  AuthState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Driver? _currentDriver;
  Driver? get currentDriver => _currentDriver;

  AuthNotifier({required this.loginUseCase, required this.registerUseCase});

  Future<void> login(String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();

    // 🕵️‍♂️ IMPRESIÓN DE CONTROL EXTRA
    print("🔍 [NOTIFIER] Intentando ingresar con Cédula: $email y Clave: $password");

    try {
      // 🛠️ FUERZA BRUTA: Leemos directamente de Hive para ver si los datos están ahí
      final dataSource = AuthLocalDataSource();
      final guardados = dataSource.obtenerRegistrosPendientes();
      
      print("📦 [NOTIFIER] Datos guardados en el celular actualmente: $guardados");

      // Buscamos si hay coincidencia local
      final usuarioLocal = guardados.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => {},
      );

      if (usuarioLocal.isNotEmpty) {
        print("🎉 [NOTIFIER] ¡ÉXITO LOCAL! Se encontró al conductor en el teléfono.");
        _currentDriver = Driver(
          id: "offline_id",
          name: usuarioLocal['name'] ?? 'Conductor Local',
          email: usuarioLocal['email'] ?? email,
          vehiclePlate: usuarioLocal['plate'] ?? '',
        );
        _state = AuthState.success;
        notifyListeners();
        return; // Detiene el flujo aquí para dar paso libre al Home
      }

      print("🌐 [NOTIFIER] No se halló en local, intentando conectar con el servidor...");
      // Si no está guardado de manera local, intentamos el flujo normal de la API
      _currentDriver = await loginUseCase.execute(email, password);
      _state = AuthState.success;
    } catch (e) {
      print("❌ [NOTIFIER] Error en Login: $e");
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      throw Exception(_errorMessage);
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String vehiclePlate) async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      print("🚀 [NOTIFIER] Enviando datos al caso de uso para registrar...");
      _currentDriver = await registerUseCase.execute(name, email, password, vehiclePlate);
      _state = AuthState.success;
      
      // 🔥 CLAVE: Le notificamos a la app que el registro fue un éxito rotundo antes de cerrar el hilo
      notifyListeners(); 
    } catch (e) {
      print("❌ [NOTIFIER] Error en Registro: $e");
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
      notifyListeners();
      throw Exception(_errorMessage);
    }
  }

  void clearError() {
    _state = AuthState.initial;
    _errorMessage = '';
  }
}