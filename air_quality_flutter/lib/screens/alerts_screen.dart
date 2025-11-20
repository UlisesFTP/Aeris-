import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/option_tile.dart'; // Reutilizamos nuestro widget personalizado

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que el widget se reconstruya automáticamente
    // cuando cambien los ajustes en AppState.
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Alertas'),
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, 'Alertas de Ubicación'),
              // Cada OptionTile ahora está conectado al AppState
              OptionTile(
                icon: Icons.my_location,
                title: 'Mi ubicación',
                subtitle: 'Ubicación actual',
                value: appState.notificationSettings['miUbicacion'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('miUbicacion', value);
                },
              ),
              OptionTile(
                icon: Icons.home_outlined,
                title: 'Casa',
                subtitle: 'Sin alertas',
                value: appState.notificationSettings['casa'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('casa', value);
                },
              ),
              OptionTile(
                icon: Icons.work_outline,
                title: 'Trabajo',
                subtitle: 'Sin alertas',
                value: appState.notificationSettings['trabajo'] ?? false,
                onChanged: (value) {
                  appState.updateNotificationSetting('trabajo', value);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Alertas de Contaminación'),
              OptionTile(
                icon: Icons.cloud_outlined,
                title: 'PM2.5',
                subtitle: 'Partículas finas',
                value: appState.notificationSettings['pm25'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('pm25', value);
                },
              ),
              OptionTile(
                icon: Icons.cloud_queue,
                title: 'PM10',
                subtitle: 'Partículas gruesas',
                value: appState.notificationSettings['pm10'] ?? false,
                onChanged: (value) {
                  appState.updateNotificationSetting('pm10', value);
                },
              ),
              OptionTile(
                icon: Icons.grain,
                title: 'Ozono',
                subtitle: 'O₃',
                value: appState.notificationSettings['ozono'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('ozono', value);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
