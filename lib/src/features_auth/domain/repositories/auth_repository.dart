import '../entities/driver.dart';

abstract class AuthRepository {
  Future<Driver> login(String email, String password);
  Future<Driver> register(String name, String email, String password, String vehiclePlate);
}