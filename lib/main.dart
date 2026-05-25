import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './core/theme/app_theme.dart';
import './src/features_auth/data/datasources/auth_remote_datasources.dart';
import './src/features_auth/data/repositories/auth_repository_impl.dart';
import './src/features_auth/domain/usecases/login_driver_usecase.dart';
import './src/features_auth/domain/usecases/register_driver_usecase.dart';
import './src/features_auth/presentation/controllers/auth_notifier.dart';
import './src/features_auth/presentation/views/login_view.dart';
import './src/features_auth/presentation/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final httpClient = http.Client();
  final remoteDataSource = AuthRemoteDataSource(httpClient);
  final authRepository = AuthRepositoryImpl(remoteDataSource);
  
  final loginUseCase = LoginDriverUseCase(authRepository);
  final registerUseCase = RegisterDriverUseCase(authRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthNotifier(loginUseCase: loginUseCase, registerUseCase: registerUseCase),
        ),
      ],
      child: const QuitoTrafficApp(),
    ),
  );
}

class QuitoTrafficApp extends StatelessWidget {
  const QuitoTrafficApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mitigación Tráfico Quito',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/traffic-map': (context) => const Scaffold(
          body: Center(
            child: Text(
              "Mapa en Tiempo Real del Centro Histórico", 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            )
          )
        ),
      },
    );
  }
}