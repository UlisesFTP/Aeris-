import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  // Estado inicial de los interruptores (switches)
  bool _myLocationAlerts = false;
  bool _homeAlerts = true;
  bool _workAlerts = false;
  bool _pm25Alerts = false;
  bool _pm10Alerts = false;
  bool _ozoneAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Oculta la flecha de "atrás"
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader(context, 'Alertas de ubicación'),
          _buildOptionTile(
            context: context,
            icon: Icons.location_on_outlined,
            title: 'Mi ubicación',
            subtitle: 'Ubicación actual',
            value: _myLocationAlerts,
            onChanged: (val) => setState(() => _myLocationAlerts = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.home_outlined,
            title: 'Casa',
            subtitle: 'Sin alertas',
            value: _homeAlerts,
            onChanged: (val) => setState(() => _homeAlerts = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.work_outline,
            title: 'Trabajo',
            subtitle: 'Sin alertas',
            value: _workAlerts,
            onChanged: (val) => setState(() => _workAlerts = val),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'Alertas de contaminación'),
          _buildOptionTile(
            context: context,
            icon: Icons.cloud_outlined,
            title: 'PM2.5',
            subtitle: 'Sin alertas',
            value: _pm25Alerts,
            onChanged: (val) => setState(() => _pm25Alerts = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.cloud_outlined,
            title: 'PM10',
            subtitle: 'Sin alertas',
            value: _pm10Alerts,
            onChanged: (val) => setState(() => _pm10Alerts = val),
          ),
          _buildOptionTile(
            context: context,
            icon: Icons.cloud_outlined,
            title: 'Ozono',
            subtitle: 'Sin alertas',
            value: _ozoneAlerts,
            onChanged: (val) => setState(() => _ozoneAlerts = val),
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
