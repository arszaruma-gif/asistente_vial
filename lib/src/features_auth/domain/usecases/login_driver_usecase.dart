import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

class LoginDriverUseCase {
  final AuthRepository repository;

  LoginDriverUseCase(this.repository);

  Future<Driver> execute(String email, String password) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Todos los campos son obligatorios');
    }
    if (!email.contains('@')) {
      throw Exception('El formato del correo electrónico es inválido');
    }
    return await repository.login(email.trim(), password);
  }
}