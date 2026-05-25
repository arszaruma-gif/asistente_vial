import 'package:flutter/material.dart';
import '../../domain/entities/driver.dart';
import '../../domain/usecases/login_driver_usecase.dart';
import '../../domain/usecases/register_driver_usecase.dart';

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

    try {
      _currentDriver = await loginUseCase.execute(email, password);
      _state = AuthState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
    }
    notifyListeners();
  }

  Future<void> register(String name, String email, String password, String vehiclePlate) async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      _currentDriver = await registerUseCase.execute(name, email, password, vehiclePlate);
      _state = AuthState.success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.error;
    }
    notifyListeners();
  }

  void clearError() {
    _state = AuthState.initial;
    _errorMessage = '';
  }
}