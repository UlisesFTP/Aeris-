import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../models/models.dart';
import '../core/notifiers/location_notifier.dart';
import '../core/notifiers/map_data_notifier.dart';
import '../services/local_advice_service.dart';
import '../widgets/skeleton_widgets.dart';
import '../widgets/empty_state_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';
import '../services/message_service.dart';

class MapScreen extends StatefulWidget {
  /// GlobalKey estático reutilizable:
  /// - router.dart lo pasa al GoRoute builder para que go_router preserve el state.
  /// - MainShell.navigateToMapAndLoadLocation lo usa para llamar loadLocation().
  static final GlobalKey<MapScreenState> globalKey =
      GlobalKey<MapScreenState>();

  const MapScreen({super.key});

  @override
  // Hacemos la clase de estado pública para que sea accesible desde MainShell
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Animation controller for staggered card animations
  late AnimationController _staggerController;
  final int _cardCount = 5; // number of animated sections

  // Estado local de la pantalla
  AirQualityData? _airQualityData;
  WeatherData? _currentWeather;
  HealthAdvice? _healthAdvice;
  HealthAdvice? _weatherAdvice;
  List<ForecastItem> _forecast = [];
  List<LocationSearchResult> _searchResults = [];
  bool _isLoading = false;
  String _loadingPhase = '';
  Marker? _currentMarker;
  LocationSearchResult? _currentLocation;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _getCurrentLocationAndData();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  /// Builds a staggered animation for the i-th card (0-indexed)
  Animation<double> _cardAnimation(int index) {
    final start = (index / _cardCount).clamp(0.0, 1.0);
    final end = ((index + 1) / _cardCount).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _staggerController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  /// Wraps a child widget in a fade + slide-up animation
  Widget _animatedCard(int index, Widget child) {
    final anim = _cardAnimation(index);
    return AnimatedBuilder(
      animation: anim,
      builder: (context, ch) {
        return Opacity(
          opacity: anim.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)),
            child: ch,
          ),
        );
      },
      child: child,
    );
  }

  // --- NUEVO MÉTODO PÚBLICO ---
  // Este método será llamado por MainShell para cargar una ubicación desde la pantalla de historial.
  void loadLocation(LocationSearchResult location) {
    _onLocationSelected(location);
  }

  // --- LÓGICA DE DATOS ---

  Future<void> _getCurrentLocationAndData() async {
    setState(() {
      _isLoading = true;
      _loadingPhase = 'Obteniendo ubicación…';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Los permisos de ubicación fueron denegados.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Los permisos de ubicación están permanentemente denegados.');
      }

      // ── ESTRATEGIA "Last Known First" ─────────────────────────────────────
      // 1. Intentar usar la última posición conocida inmediatamente.
      //    Es instantánea y evita bloquear al usuario esperando el GPS.
      Position? position = await Geolocator.getLastKnownPosition();

      if (position != null) {
        final age =
            DateTime.now().difference(position.timestamp ?? DateTime.now());
        if (age <= const Duration(minutes: 5)) {
          // Posición reciente (< 5 min): úsala directamente
          _loadLocationFromPosition(position);
          // En background, intentar obtener una posición más precisa
          _refinePositionInBackground();
          return;
        }
      }

      // 2. Si no hay posición reciente, pedir una nueva con timeout corto
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low, // low es mucho más rápido
          timeLimit: const Duration(seconds: 5),
        );
      } on TimeoutException {
        // Fallback a última posición conocida (aunque sea vieja)
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw Exception('No se pudo obtener la ubicación del dispositivo.');
      }

      _loadLocationFromPosition(position);
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Error de Geolocalización: $e');
      }
      setState(() {
        _isLoading = false;
        _loadingPhase = '';
      });
    }
  }

  void _loadLocationFromPosition(Position position) {
    String currentLocName = 'Ubicación Actual';
    if (mounted) {
      currentLocName = AppLocalizations.of(context)!.alertsCurrentLocation;
    }

    // Guardar posición real para que el background service la use
    Provider.of<LocationNotifier>(context, listen: false)
        .updateLastKnownDevicePosition(position.latitude, position.longitude);

    _onLocationSelected(LocationSearchResult(
        displayName: currentLocName,
        latitude: position.latitude,
        longitude: position.longitude));
  }

  /// Refina la posición en background cuando la última conocida era suficiente.
  Future<void> _refinePositionInBackground() async {
    try {
      final refined = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
      if (!mounted) return;
      // Solo actualizar si el usuario sigue en la ubicación actual
      final current = _currentLocation;
      if (current != null &&
          (current.latitude - refined.latitude).abs() < 0.01 &&
          (current.longitude - refined.longitude).abs() < 0.01) {
        return; // Misma zona, no hace falta recargar
      }
      _loadLocationFromPosition(refined);
    } catch (_) {
      // Silencioso: el usuario ya tiene datos válidos
    }
  }

  void _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    HapticFeedback.mediumImpact();
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _loadingPhase = 'Buscando ubicación…';
      _searchResults.clear();
    });
    try {
      final results = await _apiService.searchLocation(_searchController.text);
      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Error al buscar: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
        _loadingPhase = '';
      });
    }
  }

  void _onLocationSelected(LocationSearchResult location) async {
    final locationNotifier = Provider.of<LocationNotifier>(context, listen: false);
    final mapDataNotifier = Provider.of<MapDataNotifier>(context, listen: false);
    final languageCode = Localizations.localeOf(context).languageCode;

    setState(() {
      _isLoading = true;
      _loadingPhase = 'Consultando datos…';
      _searchResults.clear();
      _searchController.clear();
      _currentLocation = location;
    });
    FocusScope.of(context).unfocus();

    locationNotifier.addRecentLocation(location);
    locationNotifier.recordLocationVisit(
      location.latitude,
      location.longitude,
      location.displayName,
    );

    final newPoint = LatLng(location.latitude, location.longitude);

    // ── CACHE: intentar mostrar datos locales inmediatamente ────────────────
    final cached =
        mapDataNotifier.getCachedMapData(location.latitude, location.longitude);
    if (cached != null) {
      _applyCachedData(cached, newPoint);
      setState(() => _isLoading = false);
      // Refrescar en background sin bloquear
      _refreshDataInBackground(location, languageCode);
      return;
    }

    try {
      // -----------------------------------------------------------------------
      // FASE 1: Datos críticos — AQI + Clima en paralelo.
      // -----------------------------------------------------------------------
      final responses = await Future.wait([
        _apiService.getAirQuality(location.latitude, location.longitude),
        _apiService.getWeather(location.latitude, location.longitude,
            language: languageCode),
      ]);

      final airData = responses[0] as AirQualityData;
      final weatherData = responses[1] as Map<String, dynamic>;

      _applyApiData(airData, weatherData, newPoint);

      // Guardar en caché para la próxima vez
      mapDataNotifier.cacheMapData(
        lat: location.latitude,
        lon: location.longitude,
        airQuality: airData,
        weather: weatherData['current'] as WeatherData,
        forecast: weatherData['forecast'] as List<ForecastItem>,
      );

      // FASE 2: Datos secundarios en background
      _loadSecondaryData(
        location: location,
        airData: airData,
        weatherData: weatherData,
        languageCode: languageCode,
      );
    } catch (e) {
      if (mounted) {
        MessageService.showError(context, 'Error de conexión: $e');
        setState(() {
          _isLoading = false;
          _loadingPhase = '';
        });
      }
    }
  }

  // ── HELPERS DE DATOS ──────────────────────────────────────────────────────

  void _applyCachedData(Map<String, dynamic> cached, LatLng newPoint) {
    final airJson = cached['airQuality'] as Map<String, dynamic>;
    final weatherJson = cached['weather'] as Map<String, dynamic>;
    final forecastList = (cached['forecast'] as List<dynamic>)
        .map((f) => ForecastItem.fromJson(f as Map<String, dynamic>))
        .toList();

    setState(() {
      _airQualityData = AirQualityData(
        aqi: airJson['aqi'] as int,
        components: (airJson['components'] as Map<String, dynamic>?) ?? {},
      );
      _currentWeather = WeatherData(
        temp: (weatherJson['temp'] as num).toDouble(),
        condition: weatherJson['condition'] as String,
        icon: weatherJson['icon'] as String,
      );
      _forecast = forecastList;
      _currentMarker = _buildMarker(newPoint);
    });
    _mapController.move(newPoint, 13.0);
    _staggerController.reset();
    _staggerController.forward();

    // Consejos locales son instantáneos
    if (_airQualityData != null) {
      setState(() => _healthAdvice =
          LocalAdviceService.getAqiAdvice(_airQualityData!.aqi));
    }
    if (_currentWeather != null) {
      setState(() => _weatherAdvice = LocalAdviceService.getWeatherAdvice(
            condition: _currentWeather!.condition,
            temp: _currentWeather!.temp,
          ));
    }
  }

  void _applyApiData(AirQualityData airData, Map<String, dynamic> weatherData,
      LatLng newPoint) {
    if (!mounted) return;
    setState(() {
      _airQualityData = airData;
      _currentWeather = weatherData['current'];
      _forecast = weatherData['forecast'];
      _currentMarker = _buildMarker(newPoint);
      _isLoading = false;
      _loadingPhase = '';
    });
    _mapController.move(newPoint, 13.0);
    _staggerController.reset();
    _staggerController.forward();
  }

  /// Refresca datos desde la API en background cuando ya se mostró caché.
  Future<void> _refreshDataInBackground(
      LocationSearchResult location, String languageCode) async {
    try {
      final responses = await Future.wait([
        _apiService.getAirQuality(location.latitude, location.longitude),
        _apiService.getWeather(location.latitude, location.longitude,
            language: languageCode),
      ]);
      final airData = responses[0] as AirQualityData;
      final weatherData = responses[1] as Map<String, dynamic>;
      final newPoint = LatLng(location.latitude, location.longitude);

      _applyApiData(airData, weatherData, newPoint);

      Provider.of<MapDataNotifier>(context, listen: false).cacheMapData(
        lat: location.latitude,
        lon: location.longitude,
        airQuality: airData,
        weather: weatherData['current'] as WeatherData,
        forecast: weatherData['forecast'] as List<ForecastItem>,
      );

      _loadSecondaryData(
        location: location,
        airData: airData,
        weatherData: weatherData,
        languageCode: languageCode,
      );
    } catch (_) {
      // Silencioso: el usuario ya vio datos cacheados
    }
  }

  /// Carga en background: historial AQI. Los consejos ahora son locales e instantáneos.
  Future<void> _loadSecondaryData({
    required LocationSearchResult location,
    required AirQualityData airData,
    required Map<String, dynamic> weatherData,
    required String languageCode,
  }) async {
    // ── Consejos locales — instantáneos, sin red ───────────────────────────
    final currentWeather = weatherData['current'] as WeatherData;
    final aqiAdvice = LocalAdviceService.getAqiAdvice(airData.aqi);
    final weatherAdvice = LocalAdviceService.getWeatherAdvice(
      condition: currentWeather.condition,
      temp: currentWeather.temp,
      minTemp: (weatherData['forecast'] as List<ForecastItem>).isNotEmpty
          ? weatherData['forecast'][0].minTemp
          : null,
      maxTemp: (weatherData['forecast'] as List<ForecastItem>).isNotEmpty
          ? weatherData['forecast'][0].maxTemp
          : null,
    );

    if (mounted) {
      setState(() {
        _healthAdvice = aqiAdvice;
        _weatherAdvice = weatherAdvice;
      });
    }

    // Notificaciones se manejan ahora de forma asíncrona en segundo plano
    // (WorkManager + AlertMonitoringService). El MapScreen solo muestra datos en UI.
  }

  void _showSaveLocationDialog() {
    if (_currentLocation == null) return;

    final nameController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              Text(l10n.alertsAddLocation), // Reusing "Add Location" or similar
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: l10n.mapSaveLocationHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.mapCancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  HapticFeedback.mediumImpact();
                  Provider.of<LocationNotifier>(context, listen: false).saveLocation(
                    nameController.text,
                    _currentLocation!.latitude,
                    _currentLocation!.longitude,
                  );
                  Navigator.pop(context);
                  MessageService.showSuccess(
                      context, l10n.mapLocationSaved(nameController.text));
                }
              },
              child: Text(l10n.mapSave),
            ),
          ],
        );
      },
    );
  }

  // --- INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLocation?.displayName ??
            AppLocalizations.of(context)!.mapSelectLocation),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocationAndData,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(23.6345, -102.5528),
              initialZoom: 5.0,
              onTap: (_, point) => _onLocationSelected(LocationSearchResult(
                  displayName: AppLocalizations.of(context)!.mapLocationOnMap,
                  latitude: point.latitude,
                  longitude: point.longitude)),
            ),
            children: [
              TileLayer(
                urlTemplate: Theme.of(context).brightness == Brightness.dark
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.air_quality_flutter',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_currentMarker != null) ...[
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _currentMarker!.point,
                      radius: 40,
                      color: _getMarkerColor().withValues(alpha: 0.15),
                      borderColor: _getMarkerColor().withValues(alpha: 0.3),
                      borderStrokeWidth: 1,
                    ),
                  ],
                ),
                MarkerLayer(markers: [_currentMarker!]),
              ],
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(
                        Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
              ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.28,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10.0, color: Colors.black.withOpacity(0.2))
                  ],
                ),
                child: RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async {
                    if (_currentLocation != null) {
                      _onLocationSelected(_currentLocation!);
                    }
                  },
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: _buildInfoPanel(l10n),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.mapSearchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            onSubmitted: (_) => _searchLocation(),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const SkeletonMapSheet()
              : _buildCurrentContent(textTheme, l10n),
        ],
      ),
    );
  }

  /// Routes to the right content based on search/data state.
  Widget _buildCurrentContent(TextTheme textTheme, AppLocalizations l10n) {
    // Track whether user has searched (search controller has text) but got no results
    final hasSearched = _searchController.text.isNotEmpty && !_isLoading;
    if (_searchResults.isNotEmpty) {
      return _buildSearchResults();
    }
    if (hasSearched) {
      return CenteredEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.emptySearchTitle,
        subtitle: l10n.emptySearchSubtitle,
      );
    }
    return _buildDataDisplay(textTheme, l10n);
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.mapSearchResults,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final location = _searchResults[index];
            return Card(
              child: ListTile(
                title: Text(location.displayName),
                onTap: () => _onLocationSelected(location),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataDisplay(TextTheme textTheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _animatedCard(
            0,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.mapCurrentWeather, style: textTheme.titleLarge),
                    if (_currentLocation != null)
                      IconButton(
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: _showSaveLocationDialog,
                        tooltip: l10n.mapSaveLocationTooltip,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildWeatherDisplay(),
              ],
            )),
        if (_weatherAdvice != null) ...[
          const SizedBox(height: 16),
          _animatedCard(1, _buildWeatherAdviceDisplay(l10n)),
        ],
        const SizedBox(height: 24),
        _animatedCard(
            2,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mapHealthAdvice, style: textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildAdviceDisplay(),
              ],
            )),
        const SizedBox(height: 24),
        _animatedCard(
            3,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mapAirQuality, style: textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildAirQualityDisplay(l10n),
              ],
            )),
        const SizedBox(height: 24),
        _animatedCard(
            4,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.mapWeeklyForecast, style: textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildForecastDisplay(),
              ],
            )),
        // Padding de seguridad para que la barra de navegación no tape el contenido
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildAdviceDisplay() {
    if (_healthAdvice == null) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF66BB6A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF66BB6A).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.health_and_safety,
                          size: 22, color: Color(0xFF66BB6A)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mapHealthAdviceAI,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _healthAdvice!.advice,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDisplay() {
    if (_currentWeather == null) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Image.network(
              'https://openweathermap.org/img/wn/${_currentWeather!.icon}@2x.png',
              width: 64,
              height: 64,
              errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 64),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_currentWeather!.temp.toStringAsFixed(1)}°C',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  _currentWeather!.condition,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Converts ISO date string to human-friendly label
  String _humanizeDate(String isoDate, AppLocalizations l10n) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final target = DateTime(date.year, date.month, date.day);

      if (target == today) return l10n.forecastToday;
      if (target == tomorrow) return l10n.forecastTomorrow;

      // Short weekday + day number: "Mié 14"
      final locale = Localizations.localeOf(context).languageCode;
      return DateFormat('E d', locale).format(date);
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildForecastDisplay() {
    if (_forecast.isEmpty) {
      return Text(AppLocalizations.of(context)!.mapNoForecastAvailable);
    }
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast.length,
        itemBuilder: (context, index) {
          final item = _forecast[index];
          final isToday = index == 0;
          final dateLabel = _humanizeDate(item.date, l10n);

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 10.0),
            decoration: BoxDecoration(
              color: isToday
                  ? (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0))
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isToday
                    ? Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3)
                    : (isDark
                        ? const Color(0xFF3A3A3C)
                        : const Color(0xFFE5E5E5)),
                width: isToday ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Image.network(
                    'https://openweathermap.org/img/wn/${item.icon}@2x.png',
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.cloud, size: 40),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${item.maxTemp.round()}°',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${item.minTemp.round()}°',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.condition,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── AQI PALETTE (international standard colors) ───────────────────────
  static const List<Color> _aqiColors = [
    Color(0xFF4CAF50), // 1 Good        – green
    Color(0xFF8BC34A), // 2 Fair        – light green
    Color(0xFFFFEB3B), // 3 Moderate    – yellow
    Color(0xFFFF9800), // 4 Poor        – orange
    Color(0xFFE53935), // 5 Very Poor   – red
    Color(0xFF6A1B9A), // 6 Dangerous   – purple
  ];

  static const List<String> _aqiEmojis = ['🟢', '🟡', '🟠', '🔴', '🟣', '⚫'];

  Color _getMarkerColor() {
    if (_airQualityData == null) return Colors.grey;
    final idx = (_airQualityData!.aqi - 1).clamp(0, 5);
    return _aqiColors[idx];
  }

  Marker _buildMarker(LatLng point) {
    final color = _getMarkerColor();
    return Marker(
      point: point,
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
          // Main circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualityDisplay(AppLocalizations l10n) {
    if (_airQualityData == null) {
      return Center(child: Text(l10n.mapSelectLocationPrompt));
    }

    final data = _airQualityData!;
    final idx = (data.aqi - 1).clamp(0, 5);
    final aqiColor = _aqiColors[idx];
    final aqiLabels = [
      l10n.aqiGood,
      l10n.aqiFair,
      l10n.aqiModerate,
      l10n.aqiPoor,
      l10n.aqiVeryPoor,
      l10n.aqiDangerous,
    ];
    final healthDesc = [
      l10n.aqiDescGood,
      l10n.aqiDescFair,
      l10n.aqiDescModerate,
      l10n.aqiDescPoor,
      l10n.aqiDescVeryPoor,
      l10n.aqiDescDangerous,
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF222222) : Colors.white;

    return Card(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── AQI Hero number ───────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Big number
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: data.aqi.toDouble()),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) {
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: aqiColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: aqiColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '${v.round()}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: aqiColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _aqiEmojis[idx],
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            aqiLabels[idx],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: aqiColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        healthDesc[idx],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.65),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Scale bar with 6 segments ─────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: List.generate(6, (i) {
                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: i == idx ? 14 : 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: i <= idx
                                ? _aqiColors[i]
                                : _aqiColors[i].withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 6),
                // Labels below scale
                Row(
                  children: List.generate(6, (i) {
                    return Expanded(
                      child: Text(
                        ['1', '2', '3', '4', '5', '6'][i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              i == idx ? FontWeight.w800 : FontWeight.w400,
                          color: i == idx
                              ? aqiColor
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFEEEEEE),
            ),
            const SizedBox(height: 16),

            // ── Pollutant bars ─────────────────────────────────────────────
            Text(
              l10n.mapMainPollutants,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 12),
            _buildComponentBar(
                'PM2.5', data.components['pm2_5'], 12, 35, 'μg/m³'),
            const SizedBox(height: 16),
            _buildComponentBar(
                'CO', data.components['co'], 4400, 9400, 'μg/m³'),
            const SizedBox(height: 16),
            _buildComponentBar('O₃', data.components['o3'], 100, 180, 'μg/m³'),
            const SizedBox(height: 16),
            _buildComponentBar('NO₂', data.components['no2'], 40, 200, 'μg/m³'),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFEEEEEE),
            ),
            const SizedBox(height: 16),

            // ── Condiciones ambientales ────────────────────────────────────
            Text(
              l10n.mapEnvironmentalConditions,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.8,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
            const SizedBox(height: 12),
            _buildEnvironmentalMetrics(),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentBar(
    String name,
    double? value,
    double warnThreshold,
    double dangerThreshold,
    String unit,
  ) {
    final double v = value ?? 0;
    final double ratio = (v / dangerThreshold).clamp(0.0, 1.0);

    // Determine status
    String status;
    Color barColor;
    final l10n = AppLocalizations.of(context)!;
    if (v < warnThreshold) {
      status = l10n.pollutantStatusLow;
      barColor = const Color(0xFF4CAF50);
    } else if (v < dangerThreshold) {
      status = l10n.pollutantStatusModerate;
      barColor = const Color(0xFFFF9800);
    } else {
      status = l10n.pollutantStatusHigh;
      barColor = const Color(0xFFE53935);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final trackColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: barColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: barColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value != null ? '${value.toStringAsFixed(1)} $unit' : 'N/A',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Track
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Animated fill
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (_, animated, __) {
                    return Container(
                      height: 6,
                      width: constraints.maxWidth * animated,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: barColor.withValues(alpha: 0.4),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildEnvironmentalMetrics() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final w = _currentWeather!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final trackColor =
        isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF0F0F0);

    return Column(
      children: [
        _buildMetricRow(
          icon: Icons.water_drop,
          label: l10n.metricHumidity,
          value: w.humidity?.toDouble(),
          unit: '%',
          max: 100,
          lowThreshold: 30,
          highThreshold: 70,
          colors: const [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          trackColor: trackColor,
        ),
        const SizedBox(height: 12),
        _buildMetricRow(
          icon: Icons.air,
          label: l10n.metricWind,
          value: w.windSpeed,
          unit: 'm/s',
          max: 20,
          lowThreshold: 5,
          highThreshold: 12,
          colors: const [
            Color(0xFF81C784),
            Color(0xFFFFB74D),
            Color(0xFFE53935)
          ],
          trackColor: trackColor,
        ),
        const SizedBox(height: 12),
        _buildMetricRow(
          icon: Icons.speed,
          label: l10n.metricPressure,
          value: w.pressure?.toDouble(),
          unit: 'hPa',
          max: 1050,
          min: 960,
          lowThreshold: 990,
          highThreshold: 1020,
          colors: const [
            Color(0xFFBA68C8),
            Color(0xFF42A5F5),
            Color(0xFF66BB6A)
          ],
          trackColor: trackColor,
          isCentered: true,
          centerValue: 1013,
        ),
        const SizedBox(height: 12),
        _buildMetricRow(
          icon: Icons.thermostat,
          label: l10n.metricFeelsLike,
          value: w.feelsLike,
          unit: '°C',
          max: 45,
          lowThreshold: 15,
          highThreshold: 30,
          colors: const [
            Color(0xFF4FC3F7),
            Color(0xFFFFB74D),
            Color(0xFFE53935)
          ],
          trackColor: trackColor,
        ),
      ],
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required double? value,
    required String unit,
    required double max,
    double min = 0,
    required double lowThreshold,
    required double highThreshold,
    required List<Color> colors,
    required Color trackColor,
    bool isCentered = false,
    double? centerValue,
  }) {
    final double v = value ?? 0;
    final double ratio = ((v - min) / (max - min)).clamp(0.0, 1.0);

    // Determine color based on value
    Color barColor;
    if (isCentered && centerValue != null) {
      final deviation = (v - centerValue).abs();
      if (deviation < 10) {
        barColor = colors[1];
      } else if (deviation < 20) {
        barColor = colors[0];
      } else {
        barColor = colors[2];
      }
    } else {
      if (v < lowThreshold) {
        barColor = colors[0];
      } else if (v < highThreshold) {
        barColor = colors[1];
      } else {
        barColor = colors.length > 2 ? colors[2] : colors[1];
      }
    }

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: barColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: barColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    value != null ? '${value.toStringAsFixed(1)} $unit' : 'N/A',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: barColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Track
                      Container(
                        height: 8,
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          color: trackColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      // Animated fill
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: ratio),
                        duration: const Duration(milliseconds: 900),
                        curve: Curves.easeOutCubic,
                        builder: (_, animated, __) {
                          return Container(
                            height: 8,
                            width: constraints.maxWidth * animated,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  barColor.withValues(alpha: 0.7),
                                  barColor
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: barColor.withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherAdviceDisplay(AppLocalizations l10n) {
    if (_weatherAdvice == null) {
      return const SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5E5),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFFB74D),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB74D).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wb_sunny,
                          size: 22, color: Color(0xFFFFB74D)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mapWeatherAdvice,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _weatherAdvice!.advice,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
