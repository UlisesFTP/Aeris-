import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ERROR STATE WIDGET — Full-section error widget replacing plain SnackBars.
// Variants: network, locationPermission, generic
// Always includes a "Retry" button. locationPermission also shows "Open Settings".
// ─────────────────────────────────────────────────────────────────────────────

enum ErrorType { network, locationPermission, generic }

class ErrorStateWidget extends StatefulWidget {
  final ErrorType type;
  final VoidCallback onRetry;
  final String? customTitle;
  final String? customSubtitle;
  final String retryLabel;
  final String openSettingsLabel;

  const ErrorStateWidget({
    super.key,
    required this.type,
    required this.onRetry,
    this.customTitle,
    this.customSubtitle,
    this.retryLabel = 'Retry',
    this.openSettingsLabel = 'Open Settings',
  });

  @override
  State<ErrorStateWidget> createState() => _ErrorStateWidgetState();
}

class _ErrorStateWidgetState extends State<ErrorStateWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ErrorContent _resolveContent() {
    switch (widget.type) {
      case ErrorType.network:
        return _ErrorContent(
          icon: Icons.wifi_off_rounded,
          title: widget.customTitle ?? 'No internet connection',
          subtitle: widget.customSubtitle ??
              'Check your connection and try again.',
        );
      case ErrorType.locationPermission:
        return _ErrorContent(
          icon: Icons.location_off_rounded,
          title: widget.customTitle ?? 'Location access denied',
          subtitle: widget.customSubtitle ??
              'Allow location access to see local air quality.',
        );
      case ErrorType.generic:
        return _ErrorContent(
          icon: Icons.error_outline_rounded,
          title: widget.customTitle ?? 'Something went wrong',
          subtitle:
              widget.customSubtitle ?? 'An unexpected error occurred.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _resolveContent();

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Semantics(
          label: '${content.title}. ${content.subtitle}',
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    content.icon,
                    size: 40,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  content.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  content.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // Retry button (always visible)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(widget.retryLabel),
                  ),
                ),

                // Open Settings button (only for location permission errors)
                if (widget.type == ErrorType.locationPermission) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => openAppSettings(),
                      icon: const Icon(Icons.settings_outlined, size: 18),
                      label: Text(widget.openSettingsLabel),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorContent {
  final IconData icon;
  final String title;
  final String subtitle;
  const _ErrorContent({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
