import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../widgets/option_tile.dart';
import 'package:permission_handler/permission_handler.dart'; // Para abrir la configuración de la app

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que la pantalla se actualice cuando cambie el estado.
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Ajustes'),
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, 'General'),
              OptionTile(
                icon: Icons.location_on_outlined,
                title: 'Permisos de ubicación',
                subtitle: 'Activa el acceso a la ubicación',
                value: true, // El permiso se maneja a nivel de sistema
                onChanged: (value) {
                  // Este botón ahora abre los ajustes del sistema para que el usuario gestione los permisos.
                  openAppSettings();
                },
              ),
              OptionTile(
                icon: Icons.brightness_6_outlined,
                title: 'Tema de la aplicación',
                subtitle: 'Cambiar entre claro y oscuro',
                // El valor del switch viene directamente de AppState.
                value: appState.isDarkMode,
                // Al cambiar, llamamos al método en AppState.
                onChanged: (value) {
                  appState.toggleTheme();
                },
              ),
              OptionTile(
                icon: Icons.notifications_none_outlined,
                title: 'Notificaciones',
                subtitle: 'Recibir alertas de calidad del aire',
                value: true, // El permiso se maneja a nivel de sistema
                onChanged: (value) {
                  // Este botón abre los ajustes de notificaciones de la app.
                  openAppSettings();
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
