import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../datasources/auth_local_datasource.dart'; // Ruta relativa exacta a tu estructura

class SyncService {
  final AuthLocalDataSource _localDataSource = AuthLocalDataSource();
  
  // 💻 Recuerda cambiar esto por la IP real de tu PC en tu red Wi-Fi
  final String _apiUrl = "http://192.168.1.15:3000/api/drivers"; 

  /// 📡 Enciende el radar automático de red
  void escucharConexion() {
    print("📡 [SYNC SERVICE] Radar activado. Vigilando red del celular...");

    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      if (!results.contains(ConnectivityResult.none)) {
        print("📶 [SYNC SERVICE] ¡Internet detectado! Subiendo datos acumulados a pgAdmin...");
        await ejecutarSincronizacion();
      } else {
        print("📶 [SYNC SERVICE] Sin internet. Los registros se guardarán localmente en Hive.");
      }
    });
  }

  /// 🚀 Envío automático en lote hacia Node.js + pgAdmin
  Future<void> ejecutarSincronizacion() async {
    try {
      // Usamos el método exacto que tienes en tu DataSource
      final pendientes = _localDataSource.obtenerRegistrosPendientes(); 
      
      if (pendientes.isEmpty) {
        print("🧹 [SYNC SERVICE] Hive limpio. Nada que sincronizar.");
        return;
      }

      print("🚀 [SYNC SERVICE] Detectados ${pendientes.length} registros en Hive. Subiendo...");

      for (var conductor in pendientes) {
        try {
          final response = await http.post(
            Uri.parse(_apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(conductor),
          );

          if (response.statusCode == 201 || response.statusCode == 200) {
            // Si tu API en Node lo guardó en Postgres, lo sacamos de Hive
            await _localDataSource.borrarDeLocal(conductor['email']);
            print("✅ [SYNC SERVICE] Cédula ${conductor['email']} migrada a pgAdmin y borrada de Hive.");
          } else {
            print("⚠️ [SYNC SERVICE] API rechazó el dato: ${response.body}");
          }
        } catch (e) {
          print("❌ [SYNC SERVICE] La API de la PC no responde: $e");
          break; // Frena el bucle si tu servidor está apagado
        }
      }
    } catch (globalError) {
      print("⚠️ [SYNC SERVICE] Error en lectura: $globalError");
    }
  }
}