import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🛠️ NUEVO: Importamos provider
import '../controllers/auth_notifier.dart'; // 🛠️ NUEVO: Importamos el controlador

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _cedulaController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _cedulaController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🛠️ CAPTURAMOS EL NOTIFIER PARA HACER LA VALIDACIÓN REAL CONTRA HIVE
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logotipo / Icono del Sistema
              const Icon(
                Icons.directions_car_filled_rounded,
                size: 90,
                color: Color(0xFF1A237E), // Azul oscuro institucional
              ),
              const SizedBox(height: 10),
              const Text(
                "Asistencia Vial Quito",
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1A237E)
                ),
              ),
              const Text(
                "Casco Colonial - Mitigación de Tráfico",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // Campo de Número de Cédula
              TextField(
                controller: _cedulaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Número de Cédula',
                  prefixIcon: Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de Contraseña
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              // BOTÓN CON COMPROBACIÓN REAL
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final cedula = _cedulaController.text.trim();
                    final password = _passwordController.text.trim();

                    // 1. Candado inicial: Campos vacíos
                    if (cedula.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❌ Error: Ingrese su número de cédula y contraseña.'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return; 
                    }

                    // 2. 🔒 CANDADO DEFINITIVO: Verificar si existe en Hive
                    try {
                      // Llama al método login del repositorio que configuramos antes
                      await authNotifier.login(cedula, password);
                      
                      // Si la cédula y contraseña coinciden, pasas al Home
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } catch (e) {
                      // Si pusiste cualquier dato falso, salta este error naranja
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ Cédula o contraseña incorrectas. Intente de nuevo.'),
                            backgroundColor: Colors.orange,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'INGRESAR',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),

              // Enlace para ir a la pantalla de Registro
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  '¿No tienes cuenta? Regístrate aquí',
                  style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}