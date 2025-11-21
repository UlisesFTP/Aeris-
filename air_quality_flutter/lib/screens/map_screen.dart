import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

import '../api/api_service.dart';
import '../models/models.dart';
import '../core/app_state.dart';
import '../api/notifications_service.dart';
import '../widgets/history_chart.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // Hacemos la clase de estado pública para que sea accesible desde MainShell
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Estado local de la pantalla
  AirQualityData? _airQualityData;
  WeatherData? _currentWeather;
  HealthAdvice? _healthAdvice;
  List<ForecastItem> _forecast = [];
  List<LocationSearchResult> _searchResults = [];
  List<HistoricalDataPoint> _historyData = [];
  bool _isLoading = false;
  Marker? _currentMarker;
  LocationSearchResult? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndData();
  }

  // --- NUEVO MÉTODO PÚBLICO ---
  // Este método será llamado por MainShell para cargar una ubicación desde la pantalla de historial.
  void loadLocation(LocationSearchResult location) {
    _onLocationSelected(location);
  }

  // --- LÓGICA DE DATOS ---

  Future<void> _getCurrentLocationAndData() async {
    setState(() => _isLoading = true);
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

      Position position = await Geolocator.getCurrentPosition();
      _onLocationSelected(LocationSearchResult(
          displayName: 'Ubicación Actual',
          latitude: position.latitude,
          longitude: position.longitude));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error de Geolocalización: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _searchResults.clear();
    });
    try {
      final results = await _apiService.searchLocation(_searchController.text);
      setState(() => _searchResults = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error al buscar: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onLocationSelected(LocationSearchResult location) async {
    setState(() {
      _isLoading = true;
      _searchResults.clear();
      _searchController.clear();
      _currentLocation = location;
      _healthAdvice = null; // Limpiar consejo anterior
    });
    FocusScope.of(context).unfocus();

    Provider.of<AppState>(context, listen: false).addRecentLocation(location);

    // Record visit for private history tracking
    Provider.of<AppState>(context, listen: false).recordLocationVisit(
      location.latitude,
      location.longitude,
      location.displayName,
    );

    try {
      final responses = await Future.wait([
        _apiService.getAirQuality(location.latitude, location.longitude),
        _apiService.getHistory(location.latitude, location.longitude),
        _apiService.getWeather(location.latitude, location.longitude),
      ]);

      final airData = responses[0] as AirQualityData;
      final history = responses[1] as List<HistoricalDataPoint>;
      final weatherData = responses[2] as Map<String, dynamic>;
      final newPoint = LatLng(location.latitude, location.longitude);

      // Obtener consejo de Gemini
      final advice = await _apiService.getAdvice(
        weatherCondition: weatherData['current'].condition,
        aqi: airData.aqi,
        components: airData.components,
      );

      setState(() {
        _airQualityData = airData;
        _historyData = history;
        _currentWeather = weatherData['current'];
        _forecast = weatherData['forecast'];
        _healthAdvice = advice;
        _currentMarker = Marker(
          point: newPoint,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_pin, color: Colors.red, size: 45),
        );
      });
      _mapController.move(newPoint, 13.0);

      // Mostrar notificación con el consejo
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        _notificationService.showNotification(
          title: 'Consejo de Salud (IA)',
          body: advice.advice,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al obtener datos: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSaveLocationDialog() {
    if (_currentLocation == null) return;

    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Guardar Ubicación'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Ej: Casa, Oficina..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Provider.of<AppState>(context, listen: false).saveLocation(
                    nameController.text,
                    _currentLocation!.latitude,
                    _currentLocation!.longitude,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('"${nameController.text}" guardado.')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // --- INTERFAZ DE USUARIO ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(_currentLocation?.displayName ?? 'Selecciona una ubicación'),
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
                  displayName: "Ubicación en mapa",
                  latitude: point.latitude,
                  longitude: point.longitude)),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.air_quality_flutter',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              if (_currentMarker != null)
                MarkerLayer(markers: [_currentMarker!]),
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
            initialChildSize: 0.4,
            minChildSize: 0.1,
            maxChildSize: 0.8,
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
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: _buildInfoPanel(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
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
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ubicación...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onSubmitted: (_) => _searchLocation(),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator()))
              : _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : _buildDataDisplay(textTheme),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Resultados de Búsqueda",
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

  Widget _buildDataDisplay(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Clima Actual", style: textTheme.titleLarge),
            if (_currentLocation != null)
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined),
                onPressed: _showSaveLocationDialog,
                tooltip: 'Guardar esta ubicación',
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildWeatherDisplay(),
        const SizedBox(height: 24),
        Text("Recomendación (IA)", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildAdviceDisplay(),
        const SizedBox(height: 24),
        Text("Nivel de Contaminación", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildAirQualityDisplay(),
        const SizedBox(height: 24),
        Text("Pronóstico Semanal", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildForecastDisplay(),
        const SizedBox(height: 24),
        Text("Tendencias Históricas", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(height: 150, child: HistoryChart(history: _historyData)),
      ],
    );
  }

  Widget _buildAdviceDisplay() {
    if (_healthAdvice == null) {
      return const SizedBox.shrink();
    }
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.health_and_safety,
                size: 40,
                color: Theme.of(context).colorScheme.onPrimaryContainer),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _healthAdvice!.advice,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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

  Widget _buildForecastDisplay() {
    if (_forecast.isEmpty) {
      return const Text("No hay pronóstico disponible.");
    }
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _forecast.length,
        itemBuilder: (context, index) {
          final item = _forecast[index];
          return Card(
            margin: const EdgeInsets.only(right: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(item.date),
                  Image.network(
                    'https://openweathermap.org/img/wn/${item.icon}.png',
                    width: 40,
                    height: 40,
                  ),
                  Text('${item.maxTemp.round()}° / ${item.minTemp.round()}°'),
                  Text(item.condition, style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAirQualityDisplay() {
    if (_airQualityData == null) {
      return const Center(child: Text("Selecciona una ubicación."));
    }

    final data = _airQualityData!;
    final aqiColors = [
      const Color(0xFF4CAF50), // Good - Green
      const Color(0xFFFFEB3B), // Fair - Yellow
      const Color(0xFFFF9800), // Moderate - Orange
      const Color(0xFFFF5722), // Poor - Deep Orange/Red
      const Color(0xFF9C27B0), // Very Poor - Purple
      const Color(0xFF795548), // Dangerous - Brown
    ];
    final aqiText = [
      "Bueno",
      "Regular",
      "Moderado",
      "Malo",
      "Muy Malo",
      "Peligroso"
    ];
    final aqiValue = data.aqi - 1;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: aqiColors[aqiValue],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: aqiColors[aqiValue].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                aqiText[aqiValue],
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white, // Always white for contrast
                  fontWeight: FontWeight.bold,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildComponentText('PM2.5', data.components['pm2_5']),
                _buildComponentText('CO', data.components['co']),
                _buildComponentText('O3', data.components['o3']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentText(String name, double? value) {
    IconData icon;
    switch (name) {
      case 'PM2.5':
        icon = Icons.grain;
        break;
      case 'PM10':
        icon = Icons.cloud;
        break;
      case 'CO':
        icon = Icons.local_fire_department;
        break;
      case 'O3':
        icon = Icons.air;
        break;
      case 'NO2':
        icon = Icons.warning_amber;
        break;
      case 'SO2':
        icon = Icons.science;
        break;
      default:
        icon = Icons.analytics;
    }

    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(name, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 2),
        Text(value?.toStringAsFixed(2) ?? 'N/A',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                )),
      ],
    );
  }
}
