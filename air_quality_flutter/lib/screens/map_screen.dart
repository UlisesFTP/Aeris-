import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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
    });
    FocusScope.of(context).unfocus();

    Provider.of<AppState>(context, listen: false).addRecentLocation(location);

    try {
      final responses = await Future.wait([
        _apiService.getAirQuality(location.latitude, location.longitude),
        _apiService.getHistory(location.latitude, location.longitude),
      ]);

      final airData = responses[0] as AirQualityData;
      final history = responses[1] as List<HistoricalDataPoint>;
      final newPoint = LatLng(location.latitude, location.longitude);

      setState(() {
        _airQualityData = airData;
        _historyData = history;
        _currentMarker = Marker(
          point: newPoint,
          width: 80,
          height: 80,
          child: Icon(Icons.location_pin,
              color: Theme.of(context).colorScheme.error, size: 45),
        );
      });
      _mapController.move(newPoint, 13.0);

// Mostrar notificación si la calidad del aire es mala o peor
      if (airData.aqi >= 4 &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS)) {
        _notificationService.showNotification(
          title: 'Alerta de Calidad del Aire',
          body: _getAqiRecommendation(airData.aqi),
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

  String _getAqiRecommendation(int aqi) {
    switch (aqi) {
      case 4:
        return 'Calidad del aire MALA. Grupos sensibles deben reducir la actividad al aire libre.';
      case 5:
        return 'Calidad del aire MUY MALA. Evita las actividades al aire libre.';
      case 6:
        return 'PELIGROSO. Permanece en interiores y mantén las ventanas cerradas.';
      default:
        return 'Niveles de contaminación altos. Limita la actividad al aire libre.';
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
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
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
            Text("Nivel de Contaminación", style: textTheme.titleLarge),
            if (_currentLocation != null)
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined),
                onPressed: _showSaveLocationDialog,
                tooltip: 'Guardar esta ubicación',
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAirQualityDisplay(),
        const SizedBox(height: 24),
        Text("Tendencias Históricas", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        SizedBox(height: 150, child: HistoryChart(history: _historyData)),
      ],
    );
  }

  Widget _buildAirQualityDisplay() {
    if (_airQualityData == null) {
      return const Center(child: Text("Selecciona una ubicación."));
    }

    final data = _airQualityData!;
    final aqiColors = [
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.brown
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
            Text(
              aqiText[aqiValue],
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: aqiColors[aqiValue],
                    fontWeight: FontWeight.bold,
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
    return Column(
      children: [
        Text(name, style: Theme.of(context).textTheme.titleMedium),
        Text(value?.toStringAsFixed(2) ?? 'N/A',
            style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
