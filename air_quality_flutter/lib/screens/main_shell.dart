import 'package:flutter/material.dart';

import 'package:flutter_iconly/flutter_iconly.dart';
import 'map_screen.dart';
import 'alerts_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../models/models.dart';

import 'package:air_quality_flutter/l10n/app_localizations.dart';

// Este widget es el esqueleto de la app, con la barra de navegación.
class MainShell extends StatefulWidget {
  // Le pasamos una clave global para que otras pantallas puedan encontrarlo y llamar a sus métodos.
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

// Hacemos la clase de estado pública (sin '_') para que sea accesible desde history_screen
class MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  // Creamos una clave global para poder acceder a los métodos de MapScreenState
  final GlobalKey<MapScreenState> _mapScreenKey = GlobalKey<MapScreenState>();

  // Lista de las pantallas que se mostrarán.
  // Ahora pasamos la clave a nuestra MapScreen.
  late final List<Widget> _pages = <Widget>[
    MapScreen(key: _mapScreenKey), // Pasamos la clave aquí
    const AlertsScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  // --- NUEVA FUNCIÓN ---
  // Este método será llamado desde la pantalla de historial.
  void navigateToMapAndLoadLocation(LocationSearchResult location) {
    // 1. Cambia a la pestaña del mapa.
    setState(() {
      _selectedIndex = 0;
    });
    // 2. Llama al método público en MapScreenState para cargar los datos.
    // Usamos un pequeño retraso para asegurar que la pantalla del mapa esté visible
    // antes de intentar cargar los datos.
    Future.delayed(const Duration(milliseconds: 50), () {
      _mapScreenKey.currentState?.loadLocation(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final navItems = <_NavItem>[
      _NavItem(IconlyLight.home, IconlyBold.home, l10n.navMap),
      _NavItem(IconlyLight.notification, IconlyBold.notification, l10n.navAlerts),
      _NavItem(IconlyLight.timeCircle, IconlyBold.timeCircle, l10n.navHistory),
      _NavItem(IconlyLight.setting, IconlyBold.setting, l10n.navSettings),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _pages[_selectedIndex],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: _PillNavBar(
        items: navItems,
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
        isDark: isDark,
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

/// Navigation bar that matches the reference design:
/// - White rounded container with subtle shadow
/// - Active tab: dark pill with icon + label
/// - Inactive tabs: plain icon only
class _PillNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _PillNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF3A3A3C)
                  : const Color(0xFFE8E8E8),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final isSelected = index == selectedIndex;
                final item = items[index];
                return _PillNavItem(
                  icon: isSelected ? item.activeIcon : item.icon,
                  label: item.label,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  isDark: isDark,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PillNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Colors matching the reference image
    final pillColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final pillTextColor = isDark ? Colors.black : Colors.white;
    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF1C1C1E).withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 16 : 12,
            vertical: isSelected ? 10 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? pillColor : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  icon,
                  key: ValueKey('$isSelected-${icon.hashCode}'),
                  size: 22,
                  color: isSelected ? pillTextColor : iconColor,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 72),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: pillTextColor,
                              letterSpacing: 0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
