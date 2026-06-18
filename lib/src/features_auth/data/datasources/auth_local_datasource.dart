import 'package:hive_flutter/hive_flutter.dart';

class AuthLocalDataSource {
  // Conectamos con el colchón de datos temporal que abrimos en el main
  final _box = Hive.box('registros_offline');

  /// Guarda el formulario en la memoria del celular si estás en Modo Avión o sin red
  Future<void> guardarRegistroLocal(Map<String, dynamic> datosConductor) async {
    // Usamos el email (cédula) como clave única para que no se dupliquen datos
    await _box.put(datosConductor['email'], datosConductor);
    print("📥 Registro respaldado localmente en el celular: ${datosConductor['email']}");
  }

  /// 🛠️ CORRECCIÓN: Convierte de forma segura los mapas dinámicos de Hive
  List<Map<String, dynamic>> obtenerRegistrosPendientes() {
    try {
      if (_box.isEmpty) return [];
      
      return _box.values.map((elemento) {
        // Transformamos el mapa dinámico de Hive a un mapa compatible con String
        final mapaDinamic = elemento as Map;
        return mapaDinamic. earnersMap(); 
      }).toList();
    } catch (e) {
      print("⚠️ Error al mapear desde Hive: $e");
      // Alternativa ultra-segura si el casting directo falla
      return _box.values.map((e) {
        final copia = <String, dynamic>{};
        if (e is Map) {
          e.forEach((k, v) => copia[k.toString()] = v);
        }
        return copia;
      }).toList();
    }
  }

  /// Borra el registro local una vez que tu API de la PC lo guardó en pgAdmin
  Future<void> borrarDeLocal(String email) async {
    await _box.delete(email);
    print("🗑️ Registro liberado del celular (sincronizado con pgAdmin): $email");
  }
}

// Extensión rápida para facilitar la conversión de mapas
extension MapConverter on Map {
  Map<String, dynamic> earnersMap() {
    return Map<String, dynamic>.from(this);
  }
}