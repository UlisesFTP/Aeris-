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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory(TimeFilter.week);
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final filter = TimeFilter.values[_tabController.index];
      _loadHistory(filter);
    }
  }

  Future<void> _loadHistory(TimeFilter filter) async {
    setState(() => _isLoading = true);
    final appState = context.read<AppState>();
    await appState.loadLocationHistory(filter);
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            onRefresh: () => _loadHistory(appState.currentHistoryFilter),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : appState.locationHistory.isEmpty
                    ? _buildEmptyState(context)
                    : _buildHistoryList(context, appState.locationHistory),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.history,
          size: 64,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No hay historial',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Busca ubicaciones en el mapa para ver tu historial aquí',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context, List<LocationVisit> history) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final visit = history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                '${visit.searchCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(visit.locationName),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${visit.latitude.toStringAsFixed(2)}, ${visit.longitude.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 4),
                Text(
                  visit.getRelativeTime(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                      ),
                ),
              ],
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onTap: () {
              // Navigate to map with this location
              context
                  .findAncestorStateOfType<MainShellState>()
                  ?.navigateToMapAndLoadLocation(
                      visit.toLocationSearchResult());
            },
          ),
        );
      },
    );
  }
}
