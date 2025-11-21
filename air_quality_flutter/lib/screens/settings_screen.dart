import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_state.dart';
import '../widgets/option_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              // --- SECCIÓN GENERAL ---
              _buildSectionHeader(context, 'General'),
              OptionTile(
                icon: Icons.brightness_6_outlined,
                title: 'Tema Oscuro',
                subtitle: 'Cambiar apariencia de la aplicación',
                value: appState.isDarkMode,
                onChanged: (value) => appState.toggleTheme(),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN SISTEMA ---
              _buildSectionHeader(context, 'Sistema'),
              ListTile(
                leading: Icon(Icons.notifications_none_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Notificaciones'),
                subtitle: const Text('Gestionar permisos en el sistema'),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => openAppSettings(),
              ),
              ListTile(
                leading: Icon(Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: const Text('Ubicación'),
                subtitle: const Text('Gestionar permisos de ubicación'),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => openAppSettings(),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN INFORMACIÓN ---
              _buildSectionHeader(context, 'Información'),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versión'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Política de Privacidad'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Próximamente: Política de Privacidad')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Términos de Servicio'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Próximamente: Términos de Servicio')),
                  );
                },
              ),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Aeris v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
