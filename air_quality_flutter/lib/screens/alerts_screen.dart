import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../core/app_state.dart';
import '../widgets/location_picker_dialog.dart';

import 'package:air_quality_flutter/l10n/app_localizations.dart';
import '../services/message_service.dart';

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
    final l10n = AppLocalizations.of(context)!;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.alertsNewLocation),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.alertsNewLocationHint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: Text(l10n.next),
          ),
        ],
      ),
    );

    if (name == null || !context.mounted) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => LocationPickerDialog(
        title: l10n.alertsSelectLocation(name),
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
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.alertsTitle),
            automaticallyImplyLeading: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              MessageService.showInfo(context, l10n.alertsVerifying);
              final count = await appState.forceCheckAlertLocations();
              if (context.mounted) {
                MessageService.showSuccess(context, l10n.alertsVerified(count));
              }
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.alertsCheckNow),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, l10n.alertsSectionLocations),

              // Current Location
              _buildLocationTile(
                context,
                icon: Icons.my_location,
                title: l10n.alertsCurrentLocation,
                subtitle: l10n.alertsCurrentLocationSubtitle,
                enabled: appState.notificationSettings['miUbicacion'] ?? true,
                onChanged: (value) {
                  appState.updateNotificationSetting('miUbicacion', value);
                },
                isSystem: true,
              ),

              // Home Location
              _buildAlertLocationTile(context, appState, 'home'),

              // Work Location
              _buildAlertLocationTile(context, appState, 'work'),

              // Custom Locations
              ...appState.alertLocations.entries
                  .where((e) => e.key.startsWith('custom_'))
                  .map(
                      (e) => _buildAlertLocationTile(context, appState, e.key)),

              // Add Custom Location Button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                child: OutlinedButton.icon(
                  onPressed: () => _addCustomLocation(context),
                  icon: const Icon(Icons.add_location_alt),
                  label: Text(l10n.alertsAddLocation),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              _buildSectionHeader(context, l10n.alertsSectionPollutants),

              _buildLocationTile(
                context,
                icon: Icons.wb_sunny_outlined,
                title: l10n.alertsPollutantWeather,
                subtitle: l10n.alertsPollutantWeatherSubtitle,
                enabled: appState.notificationSettings['weather'] ?? true,
                onChanged: (value) =>
                    appState.updateNotificationSetting('weather', value),
              ),

              _buildLocationTile(
                context,
                icon: Icons.cloud_outlined,
                title: l10n.alertsPollutantPM25,
                subtitle: l10n.alertsPollutantPM25Subtitle,
                enabled: appState.notificationSettings['pm25'] ?? true,
                onChanged: (value) =>
                    appState.updateNotificationSetting('pm25', value),
              ),

              _buildLocationTile(
                context,
                icon: Icons.cloud_queue,
                title: l10n.alertsPollutantPM10,
                subtitle: l10n.alertsPollutantPM10Subtitle,
                enabled: appState.notificationSettings['pm10'] ?? false,
                onChanged: (value) =>
                    appState.updateNotificationSetting('pm10', value),
              ),

              _buildLocationTile(
                context,
                icon: Icons.wb_sunny_outlined,
                title: l10n.alertsPollutantO3,
                subtitle: l10n.alertsPollutantO3Subtitle,
                enabled: appState.notificationSettings['ozono'] ?? true,
                onChanged: (value) =>
                    appState.updateNotificationSetting('ozono', value),
              ),

              const SizedBox(height: 80), // Space for FAB
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
    final l10n = AppLocalizations.of(context)!;
    final location = appState.alertLocations[locationId];
    if (location == null) return const SizedBox.shrink();

    IconData icon;
    String title;

    switch (locationId) {
      case 'home':
        icon = Icons.home_filled;
        title = l10n.alertsLocationHome;
        break;
      case 'work':
        icon = Icons.work;
        title = l10n.alertsLocationWork;
        break;
      default:
        icon = Icons.place;
        title = location.name;
    }

    final subtitle = location.isConfigured
        ? location.displayName!
        : l10n.alertsTapToConfigure;

    return _buildLocationTile(
      context,
      icon: icon,
      title: title,
      subtitle: subtitle,
      enabled: location.enabled,
      onChanged: location.isConfigured
          ? (value) => appState.toggleAlertLocation(locationId, value)
          : null,
      onTap: () => _showLocationPicker(
        context,
        locationId,
        l10n.alertsLocationOf(title),
      ),
      onDelete: locationId.startsWith('custom_')
          ? () => appState.removeAlertLocation(locationId)
          : null,
      isConfigured: location.isConfigured,
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
    bool isSystem = false,
    bool isConfigured = true,
  }) {
    final theme = Theme.of(context);
    final isConfigurable = onTap != null;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: isConfigurable ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: !isConfigured
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onDelete,
                  color: theme.colorScheme.error,
                ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeColor: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 16.0, top: 8.0),
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
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
