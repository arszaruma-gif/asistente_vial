import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final http.Client client;

  AuthRemoteDataSource(this.client);

  Future<Map<String, dynamic>> loginWithHttp(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Credenciales incorrectas');
      }
    } catch (e) {
      throw Exception('Error de conexión con el servidor de tráfico central');
    }
  }

  Future<Map<String, dynamic>> registerWithHttp(String name, String email, String password, String vehiclePlate) async {
    try {
      final response = await client.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'plate': vehiclePlate,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'El correo o placa ya están registrados');
      }
    } catch (e) {
      throw Exception('Error al conectar con la base de datos vial de Quito');
    }
  }
}