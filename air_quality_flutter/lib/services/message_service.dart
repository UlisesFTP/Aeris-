import 'package:flutter/material.dart';

class MessageService {
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.check_circle_outline_rounded,
      backgroundColor: Colors.green.shade800,
      textColor: Colors.white,
    );
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.error_outline_rounded,
      backgroundColor: Colors.red.shade900,
      textColor: Colors.white,
    );
  }

  static void showWarning(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      icon: Icons.warning_amber_rounded,
      backgroundColor: Colors.orange.shade900,
      textColor: Colors.white,
    );
  }

  static void showInfo(BuildContext context, String message) {
    final theme = Theme.of(context);
    _showSnackBar(
      context,
      message,
      icon: Icons.info_outline_rounded,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      textColor: theme.colorScheme.onSurface,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        elevation: 4,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
