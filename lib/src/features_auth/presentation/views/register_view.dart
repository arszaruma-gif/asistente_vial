import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_notifier.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Controladores básicos
  final _nameController = TextEditingController(); // 🛠️ NUEVO: Controlador para el Nombre y Apellido
  final _cedulaController = TextEditingController();
  final _plateController = TextEditingController();
  final _sectorController = TextEditingController();
  final _passwordController = TextEditingController(); 

  // Estados del Formulario Basados en tu Diseño
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedVehicleType = 'Carro';
  String _selectedLicenseType = 'Licencia Tipo B';
  String _selectedFrequency = 'Diaria';
  bool _enableRealTimeAlerts = true;

  // Listas de datos para los Chips y Dropdowns
  final List<String> _vehicleTypes = ['Carro', 'Moto', 'Transporte Público', 'Transporte Pesado'];
  final List<String> _licenseTypes = ['Licencia Tipo B', 'Licencia Tipo C', 'Licencia Tipo D', 'Licencia Tipo E'];
  final List<String> _frequencies = ['Diaria', 'Semanal', 'Ocasional'];
  
  // Zonas del Casco Colonial seleccionadas por defecto
  final List<String> _selectedZonas = ['Calle Venezuela', 'Calle Rocafuerte', 'Plaza Grande', 'San Francisco'];
  final List<String> _sectoresQuito = ['La Merced', 'Centro Histórico', 'San Roque', 'La Marín', 'El Panecillo', 'Chimbacalle'];

  @override
  void dispose() {
    _nameController.dispose(); // 🛠️ NUEVO: Liberamos la memoria del nuevo controlador
    _cedulaController.dispose();
    _plateController.dispose();
    _sectorController.dispose();
    _passwordController.dispose(); 
    super.dispose();
  }

  // Helper para seleccionar Fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 10, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Helper para seleccionar Hora
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro Asistencia Vial\nQuito - Casco Colonial", style: TextStyle(fontSize: 16, height: 1.2)),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "DATOS DEL CONDUCTOR Y VEHÍCULO",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),

            // 👤 0. Nombre y Apellido (NUEVO: Añadido al inicio del formulario)
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre y Apellido',
                hintText: 'Ingresa tus nombres completos',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Sector de Domicilio (Autocomplete)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Sector de Domicilio (Autocomplete)',
                border: OutlineInputBorder(),
              ),
              child: Autocomplete<String>(
                initialValue: TextEditingValue(text: _sectorController.text.isEmpty ? 'La Merced, Quito' : _sectorController.text),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                  return _sectoresQuito.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  _sectorController.text = selection;
                },
              ),
            ),
            const SizedBox(height: 16),

            // 2. Fecha de Nacimiento (DatePicker)
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha de Nacimiento',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null 
                      ? "Sábado, 15 de Octubre, 1990" 
                      : "${_selectedDate!.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Número de Cédula
            TextField(
              controller: _cedulaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de Cédula',
                hintText: 'Número de Cédula',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 4. Hora de Inicio Jornada (TimePicker)
            InkWell(
              onTap: () => _selectTime(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Hora de Inicio Jornada para Reportes',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedTime == null 
                      ? "07:00 AM" 
                      : _selectedTime!.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Input Chips Zonas Coloniales
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Input Chips Zonas Colonial de Interés para Alertas',
                border: OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedZonas.map((zona) {
                  return InputChip(
                    label: Text(zona),
                    onDeleted: () {
                      setState(() {
                        _selectedZonas.remove(zona);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 6. Choice Chips (Tipo de Vehículo)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'TIPO DE VEHÍCULO',
                border: OutlineInputBorder(),
              ),
              child: Wrap(
                spacing: 8.0,
                children: _vehicleTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: _selectedVehicleType == type,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedVehicleType = type);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 7. Switch (Habilitar Alertas)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Switch',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Habilitar Alertas en Tiempo Real (On)", style: TextStyle(fontSize: 15)),
                  Switch(
                    value: _enableRealTimeAlerts,
                    onChanged: (value) => setState(() => _enableRealTimeAlerts = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 8. Número de Placa
            TextField(
              controller: _plateController,
              maxLength: 7,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'NÚMERO DE PLACA',
                hintText: 'PDA-1234',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 8.5 Campo de Contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'CREA TU CONTRASEÑA',
                hintText: 'Mínimo 6 caracteres',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // 9. Tipo de Licencia (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedLicenseType,
              decoration: const InputDecoration(
                labelText: 'TIPO DE LICENCIA',
                border: OutlineInputBorder(),
              ),
              items: _licenseTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedLicenseType = newValue!);
              },
            ),
            const SizedBox(height: 16),

            // 10. Radio Group (Frecuencia de Uso)
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'FRECUENCIA DE USO DEL APP',
                border: OutlineInputBorder(),
              ),
              child: Column(
                children: _frequencies.map((freq) {
                  return RadioListTile<String>(
                    title: Text(freq),
                    value: freq,
                    groupValue: _selectedFrequency,
                    onChanged: (value) {
                      setState(() => _selectedFrequency = value!);
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Botón de Enviar Formulario
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final name = _nameController.text.trim(); // 🛠️ NUEVO
                  final cedula = _cedulaController.text.trim();
                  final plate = _plateController.text.trim();
                  final password = _passwordController.text.trim();

                  // 🔒 CANDADO DE SEGURIDAD ACTUALIZADO:
                  if (name.isEmpty || cedula.isEmpty || plate.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ Error: Nombre, Cédula, Placa y Contraseña son obligatorios.'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return; 
                  }

                  // 🚀 MODIFICADO: Enviamos el "name" capturado dinámicamente en lugar del texto fijo
                  await authNotifier.register(
                    name, 
                    cedula, 
                    password, 
                    plate,
                  );

                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                icon: const Icon(Icons.directions_car, color: Colors.white),
                label: const Text('GUARDAR REGISTRO', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}