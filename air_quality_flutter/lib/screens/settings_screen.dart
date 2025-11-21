import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/app_state.dart';
import '../widgets/option_tile.dart';
import 'legal_screen.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.settingsTitle),
            automaticallyImplyLeading: false,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // --- SECCIÓN GENERAL ---
              _buildSectionHeader(context, l10n.settingsSectionGeneral),
              OptionTile(
                icon: Icons.brightness_6_outlined,
                title: l10n.settingsThemeDark,
                subtitle: l10n.settingsThemeDarkSubtitle,
                value: appState.isDarkMode,
                onChanged: (value) => appState.toggleTheme(),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN SISTEMA ---
              _buildSectionHeader(context, l10n.settingsSectionSystem),
              ListTile(
                leading: Icon(Icons.notifications_none_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.settingsNotifications),
                subtitle: Text(l10n.settingsNotificationsSubtitle),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => openAppSettings(),
              ),
              ListTile(
                leading: Icon(Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.settingsLocation),
                subtitle: Text(l10n.settingsLocationSubtitle),
                trailing: const Icon(Icons.open_in_new, size: 20),
                onTap: () => openAppSettings(),
              ),

              const SizedBox(height: 24),

              // --- SECCIÓN INFORMACIÓN ---
              _buildSectionHeader(context, l10n.settingsSectionInfo),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.settingsVersion),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.settingsPrivacyPolicy),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LegalScreen(
                        title: l10n.legalPrivacyTitle,
                        content: l10n.legalPrivacyContent,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.settingsTermsOfService),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LegalScreen(
                        title: l10n.legalTermsTitle,
                        content: l10n.legalTermsContent,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  l10n.settingsFooter,
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
