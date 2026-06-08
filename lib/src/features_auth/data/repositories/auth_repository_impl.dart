import '../../domain/entities/driver.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Driver> login(String email, String password) async {
    final data = await remoteDataSource.loginWithHttp(email, password);
    return _mapToEntity(data);
  }

  @override
  Future<Driver> register(String name, String email, String password, String vehiclePlate) async {
    final data = await remoteDataSource.registerWithHttp(name, email, password, vehiclePlate);
    return _mapToEntity(data);
  }

  Driver _mapToEntity(Map<String, dynamic> json) {
    return Driver(
      id: json['driver']['id'].toString(),
      name: json['driver']['name'],
      email: json['driver']['email'],
      vehiclePlate: json['driver']['plate'],
    );
  }
}