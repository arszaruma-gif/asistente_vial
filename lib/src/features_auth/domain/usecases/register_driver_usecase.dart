import '../../data/repositories/auth_repository_impl.dart';

class RegisterDriverUseCase {
  final AuthRepositoryImpl repository;

  RegisterDriverUseCase(this.repository);

  // Cambiado de void a Future<dynamic> para que devuelva el usuario logueado al controlador
  Future<dynamic> execute(String name, String email, String password, String plate) async {
    return await repository.register(name, email, password, plate);
  }
}