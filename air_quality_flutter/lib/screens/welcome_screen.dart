import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';
import 'main_shell.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcome', false);

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF000000), // Pure black
                    const Color(0xFF1A1A1A), // Very dark gray
                    const Color(0xFF0A0A0A), // Near-black
                  ]
                : [
                    const Color(0xFFFFFFFF), // Pure white
                    const Color(0xFFF5F5F5), // Very light gray
                    const Color(0xFFFAFAFA), // Off-white
                  ],
          ),
        ),
        child: SafeArea(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 20),
                              // Header Section
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? const Color(0xFF252525)
                                          : const Color(0xFFF5F5F5),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDarkMode
                                            ? const Color(0xFF333333)
                                            : const Color(0xFFE5E5E5),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.air_rounded,
                                      size: 80,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    l10n.welcomeTitle,
                                    style: textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    l10n.welcomeSubtitle,
                                    style: textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7),
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Features Section
                              Column(
                                children: [
                                  _buildFeature(
                                    context,
                                    icon: Icons.timer_outlined,
                                    title: l10n.welcomeFeature1Title,
                                    subtitle: l10n.welcomeFeature1Desc,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFeature(
                                    context,
                                    icon: Icons.notifications_active_outlined,
                                    title: l10n.welcomeFeature2Title,
                                    subtitle: l10n.welcomeFeature2Desc,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildFeature(
                                    context,
                                    icon: Icons.map_outlined,
                                    title: l10n.welcomeFeature3Title,
                                    subtitle: l10n.welcomeFeature3Desc,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Button Section
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () => _onGetStarted(context),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 56),
                                      elevation: 0,
                                    ),
                                    child: Text(l10n.welcomeButton),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDarkMode ? const Color(0xFF333333) : const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF252525)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 30,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
