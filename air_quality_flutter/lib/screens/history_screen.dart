import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:air_quality_flutter/models/models.dart';
import '../core/app_state.dart';
import 'main_shell.dart';

import 'package:air_quality_flutter/l10n/app_localizations.dart';
import '../services/message_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _listAnimController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

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
    // Cargar historial y asegurar que las ubicaciones guardadas estén actualizadas
    await Future.wait([
      appState.loadLocationHistory(filter),
      appState.loadSavedLocationsFromApi(),
    ]);
    setState(() => _isLoading = false);
    _listAnimController.reset();
    _listAnimController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listAnimController.dispose();
    super.dispose();
  }

  /// Staggered animation for the i-th list item
  Animation<double> _itemAnimation(int index, int totalCount) {
    if (totalCount == 0) return const AlwaysStoppedAnimation(1.0);
    final start = (index / totalCount).clamp(0.0, 0.9);
    final end = ((index + 1) / totalCount).clamp(start + 0.05, 1.0);
    return CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Calculate total animated items
        final savedCount = appState.savedLocations.length;
        final historyCount = appState.locationHistory.length;
        final totalItems = savedCount + historyCount + 2; // +2 for headers

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.historyTitle),
            automaticallyImplyLeading: false,
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.historyTabDay),
                Tab(text: l10n.historyTabWeek),
                Tab(text: l10n.historyTabMonth),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () => _loadHistory(appState.currentHistoryFilter),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : AnimatedBuilder(
                    animation: _listAnimController,
                    builder: (context, _) {
                      int itemIndex = 0;
                      return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // SECCIÓN 1: Ubicaciones Guardadas
                          _animatedItem(
                            itemIndex++,
                            totalItems,
                            _buildSectionHeader(
                                context, l10n.historySectionSaved),
                          ),
                          if (appState.savedLocations.isEmpty)
                            _animatedItem(
                              itemIndex++,
                              totalItems,
                              _buildEmptySection(
                                  context, l10n.historyNoSavedLocations),
                            )
                          else
                            ...appState.savedLocations.values.map((loc) =>
                                _animatedItem(
                                  itemIndex++,
                                  totalItems,
                                  _buildSavedLocationItem(context, loc),
                                )),

                          const SizedBox(height: 24),

                          // SECCIÓN 2: Historial de Visitas
                          _animatedItem(
                            itemIndex++,
                            totalItems,
                            _buildSectionHeader(
                                context, l10n.historySectionVisits),
                          ),
                          if (appState.locationHistory.isEmpty)
                            _animatedItem(
                              itemIndex++,
                              totalItems,
                              _buildEmptySection(
                                  context, l10n.historyNoRecentHistory),
                            )
                          else
                            ...appState.locationHistory.map((visit) =>
                                _animatedItem(
                                  itemIndex++,
                                  totalItems,
                                  _buildHistoryItem(context, visit),
                                )),

                          // Espacio extra al final
                          const SizedBox(height: 48),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Widget _animatedItem(int index, int total, Widget child) {
    final anim = _itemAnimation(index, total);
    return Opacity(
      opacity: anim.value.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 24 * (1 - anim.value)),
        child: child,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 4.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }

  Widget _buildSavedLocationItem(BuildContext context, SavedLocation location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.bookmark,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(location.displayName ?? location.name),
        subtitle: Text(
          '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () {
            _confirmDelete(context, location);
          },
        ),
        onTap: () {
          context
              .findAncestorStateOfType<MainShellState>()
              ?.navigateToMapAndLoadLocation(location.toLocationSearchResult());
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, LocationVisit visit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Text(
            '${visit.searchCount}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(visit.locationName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${visit.latitude.toStringAsFixed(2)}, ${visit.longitude.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              visit.getRelativeTime(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () {
          context
              .findAncestorStateOfType<MainShellState>()
              ?.navigateToMapAndLoadLocation(visit.toLocationSearchResult());
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, SavedLocation location) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.historyDeleteTitle),
        content: Text(l10n.historyDeleteConfirmation(location.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().removeSavedLocation(location.id!);
              MessageService.showSuccess(
                  context, l10n.historyDeleted(location.name));
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
