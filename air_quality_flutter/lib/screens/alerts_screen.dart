import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../core/app_state.dart';
import '../widgets/location_picker_dialog.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  Future<void> _showLocationPicker(
    BuildContext context,
    String locationId,
    String title,
  ) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final currentLocation = appState.alertLocations[locationId];

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        title: title,
        initialLocation: currentLocation?.isConfigured == true
            ? LatLng(currentLocation!.latitude!, currentLocation.longitude!)
            : null,
      ),
    );

    if (result != null) {
      await appState.updateAlertLocation(
        locationId,
        result['latitude'] as double,
        result['longitude'] as double,
        result['displayName'] as String,
      );
    }
  }

  Future<void> _addCustomLocation(BuildContext context) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Ubicación'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nombre (ej: Gimnasio, Escuela)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Siguiente'),
          ),
        ],
      ),
    );

    if (name == null || !context.mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        title: 'Selecciona ubicación de $name',
      ),
    );

    if (result != null && context.mounted) {
      final appState = Provider.of<AppState>(context, listen: false);
      await appState.addCustomAlertLocation(
        name,
        result['latitude'] as double,
        result['longitude'] as double,
        result['displayName'] as String,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Alertas'),
            automaticallyImplyLeading: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verificando calidad del aire...'),
                  duration: Duration(seconds: 2),
                ),
              );
              final count = await appState.forceCheckAlertLocations();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Verificadas $count ubicaciones'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Verificar ahora'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, 'Alertas de Ubicación'),

              // Current Location (always enabled)
              _buildLocationTile(
                context,
                icon: Icons.my_location,
                title: 'Mi ubicación',
                subtitle: 'Ubicación actual del dispositivo',
                enabled: appState.notificationSettings['miUbicacion'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('miUbicacion', value);
                },
                onTap: null, // Not configurable
              ),

              // Home Location
              _buildAlertLocationTile(
                context,
                appState,
                'home',
              ),

              // Work Location
              _buildAlertLocationTile(
                context,
                appState,
                'work',
              ),

              // Custom Locations
              ...appState.alertLocations.entries
                  .where((e) => e.key.startsWith('custom_'))
                  .map((e) => _buildAlertLocationTile(
                        context,
                        appState,
                        e.key,
                      )),

              // Add Custom Location Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: OutlinedButton.icon(
                  onPressed: () => _addCustomLocation(context),
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Agregar ubicación personalizada'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Alertas de Contaminación'),

              _buildLocationTile(
                context,
                icon: Icons.cloud_outlined,
                title: 'PM2.5',
                subtitle: 'Partículas finas',
                enabled: appState.notificationSettings['pm25'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('pm25', value);
                },
              ),

              _buildLocationTile(
                context,
                icon: Icons.cloud_queue,
                title: 'PM10',
                subtitle: 'Partículas gruesas',
                enabled: appState.notificationSettings['pm10'] ?? false,
                onChanged: (value) {
                  appState.updateNotificationSetting('pm10', value);
                },
              ),

              _buildLocationTile(
                context,
                icon: Icons.grain,
                title: 'Ozono',
                subtitle: 'O₃',
                enabled: appState.notificationSettings['ozono'] ?? true,
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

  Widget _buildAlertLocationTile(
    BuildContext context,
    AppState appState,
    String locationId,
  ) {
    final location = appState.alertLocations[locationId];
    if (location == null) return const SizedBox.shrink();

    IconData icon;
    switch (locationId) {
      case 'home':
        icon = Icons.home_outlined;
        break;
      case 'work':
        icon = Icons.work_outline;
        break;
      default:
        icon = Icons.location_on;
    }

    final subtitle =
        location.isConfigured ? location.displayName! : 'Toca para configurar';

    return _buildLocationTile(
      context,
      icon: icon,
      title: location.name,
      subtitle: subtitle,
      enabled: location.enabled,
      onChanged: location.isConfigured
          ? (value) => appState.toggleAlertLocation(locationId, value)
          : null,
      onTap: () => _showLocationPicker(
        context,
        locationId,
        'Selecciona ubicación de ${location.name}',
      ),
      onDelete: locationId.startsWith('custom_')
          ? () => appState.removeAlertLocation(locationId)
          : null,
    );
  }

  Widget _buildLocationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
    required void Function(bool)? onChanged,
    VoidCallback? onTap,
    VoidCallback? onDelete,
  }) {
    final theme = Theme.of(context);
    final isConfigurable = onTap != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: subtitle == 'Toca para configurar'
                ? theme.colorScheme.error.withOpacity(0.7)
                : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Eliminar',
              ),
            Switch(
              value: enabled,
              onChanged: onChanged,
            ),
          ],
        ),
        onTap: isConfigurable ? onTap : null,
        enabled: true,
      ),
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
