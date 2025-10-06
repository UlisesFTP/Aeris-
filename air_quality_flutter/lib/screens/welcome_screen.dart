import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_shell.dart'; // Aún no existe, pero lo crearemos en el siguiente paso

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Método que se ejecuta al presionar el botón
  Future<void> _onGetStarted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    // Guardamos que la bienvenida ya fue mostrada
    await prefs.setBool('showWelcome', false);

    // Navegamos a la pantalla principal de la app, reemplazando esta.
    // Esto evita que el usuario pueda "volver atrás" a la pantalla de bienvenida.
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el tema definido para asegurar consistencia
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.air, size: 64),
              const SizedBox(height: 24),
              Text(
                "Respira Fácil, Vive Sano",
                style: textTheme.headlineLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                "Monitorea la calidad del aire en tiempo real, recibe alertas y visualiza los datos en un mapa. Mantente informado y protege tu salud.",
                style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              _buildFeature(
                context,
                icon: Icons.timer_outlined,
                title: "Monitoreo en Tiempo Real",
                subtitle:
                    "Obtén datos de calidad del aire actualizados para tu ubicación.",
              ),
              _buildFeature(
                context,
                icon: Icons.notifications_active_outlined,
                title: "Alertas Inteligentes",
                subtitle:
                    "Recibe notificaciones cuando la calidad del aire cambie en tu área.",
              ),
              _buildFeature(
                context,
                icon: Icons.map_outlined,
                title: "Mapa Interactivo",
                subtitle:
                    "Visualiza la información en un mapa detallado y fácil de usar.",
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _onGetStarted(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: const Text("Comenzar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para no repetir código
  Widget _buildFeature(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final textTheme = Theme.of(context).textTheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.white60 : Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
