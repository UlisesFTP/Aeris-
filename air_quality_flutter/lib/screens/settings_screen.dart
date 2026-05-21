import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/notifiers/theme_notifier.dart';
import '../core/notifiers/alert_notifier.dart';
import '../widgets/option_tile.dart';
import 'legal_screen.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
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
                value: themeNotifier.isDarkMode,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  themeNotifier.toggleTheme();
                },
              ),
              ListTile(
                leading: Icon(Icons.translate_outlined,
                    color: Theme.of(context).colorScheme.primary),
                title: Text(l10n.settingsLanguage),
                subtitle: Text(l10n.settingsLanguageSubtitle),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getLanguageName(themeNotifier.preferredLanguageCode, l10n),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => _showLanguageDialog(context, themeNotifier, l10n),
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

  String _getLanguageName(String? code, AppLocalizations l10n) {
    switch (code) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'pt':
        return 'Português';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      default:
        return l10n.langSystem;
    }
  }

  void _showLanguageDialog(BuildContext context, ThemeNotifier themeNotifier, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.settingsLanguage,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Divider(),
              _buildLanguageOption(context, themeNotifier, null, l10n.langSystem),
              _buildLanguageOption(context, themeNotifier, 'es', 'Español'),
              _buildLanguageOption(context, themeNotifier, 'en', 'English'),
              _buildLanguageOption(context, themeNotifier, 'pt', 'Português'),
              _buildLanguageOption(context, themeNotifier, 'fr', 'Français'),
              _buildLanguageOption(context, themeNotifier, 'de', 'Deutsch'),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, ThemeNotifier themeNotifier, String? code, String name) {
    final isSelected = themeNotifier.preferredLanguageCode == code;
    return ListTile(
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () {
        HapticFeedback.mediumImpact();
        themeNotifier.setPreferredLanguage(code);
        
        try {
          Provider.of<AlertNotifier>(context, listen: false).updateLanguageCode(
            code ?? WidgetsBinding.instance.platformDispatcher.locale.languageCode
          );
        } catch (_) {}

        Navigator.pop(context);
      },
    );
  }
}
