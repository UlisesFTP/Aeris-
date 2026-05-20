import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/di.dart'; // expone la instancia global getIt

import '../screens/welcome_screen.dart';
import '../screens/main_shell.dart';
import '../screens/map_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/legal_screen.dart';

/// Router declarativo de la app Aeris.
///
/// Rutas:
///   /welcome          → WelcomeScreen (solo si showWelcome == true)
///   /map              → MapScreen     (tab 0 dentro de StatefulShellRoute)
///   /alerts           → AlertsScreen  (tab 1)
///   /history          → HistoryScreen (tab 2)
///   /settings         → SettingsScreen (tab 3)
///   /legal            → LegalScreen   (fuera del shell, recibe extra Map)
///
/// Para usar en main.dart cuando se migre a MaterialApp.router:
///   routerConfig: AppRouter.router
class AppRouter {
  AppRouter._(); // Clase solo con miembros estáticos

  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/map',

    /// Redirección global basada en el flag showWelcome.
    /// Si el usuario todavía no vio la bienvenida, lo manda a /welcome.
    /// Si ya la vio y está en /welcome, lo manda a /map.
    redirect: (context, state) {
      final prefs = getIt<SharedPreferences>();
      final showWelcome = prefs.getBool('showWelcome') ?? true;
      final isWelcome = state.matchedLocation == '/welcome';

      if (showWelcome && !isWelcome) return '/welcome';
      if (!showWelcome && isWelcome) return '/map';
      return null;
    },

    routes: [
      // ── Pantalla de bienvenida (fuera del shell) ────────────────────────
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),

      // ── Shell de las 4 pestañas (IndexedStack persistente) ──────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            MainShell(navigationShell: shell),
        branches: [
          // Tab 0 — Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                // Pasamos el GlobalKey estático para que MainShell pueda
                // llamar a MapScreenState.loadLocation() desde HistoryScreen.
                builder: (context, state) =>
                    MapScreen(key: MapScreen.globalKey),
              ),
            ],
          ),
          // Tab 1 — Alertas
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/alerts',
                builder: (context, state) => const AlertsScreen(),
              ),
            ],
          ),
          // Tab 2 — Historial
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          // Tab 3 — Ajustes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Pantalla legal (fuera del shell, recibe datos en extra) ─────────
      GoRoute(
        path: '/legal',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return LegalScreen(
            title: extra?['title'] ?? '',
            content: extra?['content'] ?? '',
          );
        },
      ),
    ],
  );
}
