import 'package:flutter/material.dart';
import 'map_screen.dart';
import 'alerts_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import '../models/models.dart';

// Este widget es el esqueleto de la app, con la barra de navegación.
class MainShell extends StatefulWidget {
  // Le pasamos una clave global para que otras pantallas puedan encontrarlo y llamar a sus métodos.
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

// Hacemos la clase de estado pública (sin '_') para que sea accesible desde history_screen
class MainShellState extends State<MainShell> {
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: colorScheme.primary,
              unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
              selectedFontSize: 12,
              unselectedFontSize: 11,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.map_outlined),
                  activeIcon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  activeIcon: Icon(Icons.notifications),
                  label: 'Alertas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  activeIcon: Icon(Icons.history),
                  label: 'Historial',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'Ajustes',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
