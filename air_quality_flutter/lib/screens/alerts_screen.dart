import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../core/notifiers/alert_notifier.dart';
import '../widgets/location_picker_dialog.dart';

import 'package:air_quality_flutter/l10n/app_localizations.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  Future<void> _showLocationPicker(
    BuildContext context,
    String locationId,
    String title,
  ) async {
    final alertNotifier = Provider.of<AlertNotifier>(context, listen: false);
    final currentLocation = alertNotifier.alertLocations[locationId];

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
      await alertNotifier.updateAlertLocation(
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
      final alertNotifier = Provider.of<AlertNotifier>(context, listen: false);
      await alertNotifier.addCustomAlertLocation(
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

    return Consumer<AlertNotifier>(
      builder: (context, alertNotifier, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.alertsTitle),
            automaticallyImplyLeading: false,
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
                enabled: alertNotifier.notificationSettings['miUbicacion'] ?? true,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  alertNotifier.updateNotificationSetting('miUbicacion', value);
                },
                isSystem: true,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
                child: Text(
                  'La app monitoreará tu última ubicación conocida para enviar notificaciones de estado y alertas en segundo plano.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),

              // Home Location
              _buildAlertLocationTile(context, alertNotifier, 'home'),

              // Work Location
              _buildAlertLocationTile(context, alertNotifier, 'work'),

              // Custom Locations
              ...alertNotifier.alertLocations.entries
                  .where((e) => e.key.startsWith('custom_'))
                  .map(
                      (e) => _buildAlertLocationTile(context, alertNotifier, e.key)),

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

              const SizedBox(height: 24),

            ],
          ),
        );
      },
    );
  }

  Widget _buildAlertLocationTile(
    BuildContext context,
    AlertNotifier alertNotifier,
    String locationId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final location = alertNotifier.alertLocations[locationId];
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
          ? (value) {
              HapticFeedback.lightImpact();
              alertNotifier.toggleAlertLocation(locationId, value);
            }
          : null,
      onTap: () => _showLocationPicker(
        context,
        locationId,
        l10n.alertsLocationOf(title),
      ),
      onDelete: locationId.startsWith('custom_')
          ? () => alertNotifier.removeAlertLocation(locationId)
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
