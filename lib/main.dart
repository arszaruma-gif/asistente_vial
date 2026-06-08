import 'package:asitente_vial/src/features_auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import './core/theme/app_theme.dart';
import './src/features_auth/data/datasources/auth_remote_datasource.dart';
import './src/features_auth/data/repositories/auth_repository_impl.dart';
import './src/features_auth/domain/usecases/login_driver_usecase.dart';
import './src/features_auth/domain/usecases/register_driver_usecase.dart';
import './src/features_auth/presentation/controllers/auth_notifier.dart';
import './src/features_auth/presentation/views/login_view.dart';
import './src/features_auth/presentation/views/register_view.dart';
import './src/features_auth/presentation/views/home_view.dart'; // Tu Pantalla 3 con Menu Drawer

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
      
      // Requerimiento: Pantalla 1, 2 y 3 mapeadas en rutas conocidas
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const HomeView(), 
      },

      // Requerimiento: Controlar si una pantalla o ruta NO EXISTE
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text("Pantalla No Encontrada"), backgroundColor: Colors.red),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "La ruta '${settings.name}' no existe en el sistema.",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text("Volver al Inicio (Login)"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
