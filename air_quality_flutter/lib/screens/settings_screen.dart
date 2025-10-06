import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado inicial de los interruptores (switches)
  bool _locationPermissions = true;
  bool _darkMode = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Oculta la flecha de "atrás"
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'General'),
          // CORRECCIÓN: Se llama a la función usando parámetros nombrados.
          _buildOptionTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Permisos de ubicación',
            subtitle: 'Activa el acceso a la ubicación',
            value: _locationPermissions,
            onChanged: (val) => setState(() => _locationPermissions = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.brightness_6_outlined,
            title: 'Tema de la aplicación',
            subtitle: 'Cambiar entre claro y oscuro',
            value: _darkMode,
            onChanged: (val) => setState(() => _darkMode = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Recibir alertas de calidad del aire',
            value: _notifications,
            onChanged: (val) => setState(() => _notifications = val),
          ),
        ],
      ),
    );
  }

  // Widget reutilizable para el encabezado de cada sección
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget reutilizable para cada opción con un interruptor
  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
          activeTrackColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}
