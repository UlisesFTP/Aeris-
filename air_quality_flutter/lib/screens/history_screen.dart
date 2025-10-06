import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_quality_flutter/models/models.dart';
import '../core/app_state.dart';
import 'main_shell.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usamos Consumer para que la pantalla se actualice cuando cambien los datos en AppState
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Historial'),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Día'),
                Tab(text: 'Semana'),
                Tab(text: 'Mes'),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => appState.loadSavedLocationsFromApi(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader(context, 'Ubicaciones Guardadas'),
                appState.savedLocations.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text('No has guardado ninguna ubicación.'),
                      ))
                    : _buildLocationList(
                        context, appState.savedLocations.values.toList()),
                const SizedBox(height: 24),
                _buildSectionHeader(context, 'Ubicaciones Visitadas'),
                appState.recentLocations.isEmpty
                    ? const Center(
                        child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0),
                        child: Text('Tu historial de búsqueda está vacío.'),
                      ))
                    : _buildLocationList(context, appState.recentLocations),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationList(
      BuildContext context, List<SavedLocation> locations) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return Card(
          child: ListTile(
            leading: Icon(
              location.id != null
                  ? Icons.bookmark
                  : Icons.history, // Icono diferente para guardadas y recientes
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(location.displayName ?? location.name),
            subtitle: Text(
                '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}'),
            trailing: location.id != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.redAccent),
                    onPressed: () {
                      // Lógica para eliminar ubicación guardada
                      Provider.of<AppState>(context, listen: false)
                          .removeSavedLocation(location.id!);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('"${location.name}" eliminada.')));
                    },
                  )
                : null,
            onTap: () {
              // Llama al método en MainShell para cambiar a la pestaña del mapa y cargar la ubicación
              context
                  .findAncestorStateOfType<MainShellState>()
                  ?.navigateToMapAndLoadLocation(
                      location.toLocationSearchResult());
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
