import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:air_quality_flutter/api/api_service.dart';
// CORRECCIÓN DEFINITIVA: Apuntamos a la única fuente de verdad.
import 'package:air_quality_flutter/models/models.dart';
import 'package:air_quality_flutter/api/notifications_service.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  AirQualityData? _airQualityData;
  List<LocationSearchResult> _searchResults = [];
  bool _isLoading = false;
  Marker? _currentMarker;
  String _currentLocationName = "Selecciona una ubicación";

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _notificationService.initNotifications();
    _getCurrentLocationAndData();
  }

  Future<void> _getCurrentLocationAndData() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están deshabilitados.');
      }

      permission = await Geolocator.checkPermission();
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
          SnackBar(content: Text('Error de Geolocalización: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _searchLocation() async {
    if (_searchController.text.isEmpty) return;
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
      _currentLocationName = location.displayName;
    });
    FocusScope.of(context).unfocus();
    try {
      final data = await _apiService.getAirQuality(
          location.latitude, location.longitude);
      final newPoint = LatLng(location.latitude, location.longitude);
      setState(() {
        _airQualityData = data;
        _currentMarker = Marker(
          point: newPoint,
          width: 80,
          height: 80,
          child: Icon(Icons.location_pin,
              color: Theme.of(context).colorScheme.error, size: 45),
        );
      });
      _mapController.move(newPoint, 13.0);

      if (data.aqi >= 4) {
        _notificationService.showNotification(
          title: 'Alerta de Calidad del Aire',
          body: _getAqiRecommendation(data.aqi),
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
        return 'Calidad del aire MALA. Se recomienda a los grupos sensibles reducir la actividad al aire libre.';
      case 5:
        return 'Calidad del aire MUY MALA. Evita las actividades al aire libre y considera usar cubrebocas si sales.';
      case 6:
        return 'PELIGROSO. Permanece en interiores y mantén las ventanas cerradas.';
      default:
        return 'Los niveles de contaminación son altos. Considera limitar la actividad al aire libre.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentLocationName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Navegar a la pantalla de Alertas
            },
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
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.2),
                    ),
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
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            onSubmitted: (_) => _searchLocation(),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isNotEmpty
                  ? _buildSearchResults()
                  : _buildMainContent(textTheme),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final location = _searchResults[index];
        return ListTile(
          title: Text(location.displayName),
          onTap: () => _onLocationSelected(location),
        );
      },
    );
  }

  Widget _buildMainContent(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nivel de Contaminación", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildAirQualityDisplay(),
        const SizedBox(height: 24),
        Text("Tendencias Históricas", style: textTheme.titleLarge),
        const SizedBox(height: 16),
        Container(
          height: 150,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16)),
          child:
              const Center(child: Text("Gráfico de Historial (Próximamente)")),
        ),
      ],
    );
  }

  Widget _buildAirQualityDisplay() {
    if (_airQualityData == null) {
      return const Center(child: Text('Aún no hay datos para mostrar.'));
    }

    final data = _airQualityData!;
    final aqiColors = [
      Colors.green.shade300,
      Colors.yellow.shade300,
      Colors.orange.shade300,
      Colors.red.shade300,
      Colors.purple.shade300,
      Colors.brown.shade300
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

    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Text(
          aqiText[aqiValue],
          style: textTheme.displaySmall?.copyWith(
            color: aqiColors[aqiValue],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text('PM2.5: ${data.components['pm2_5'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyMedium),
        Text('CO: ${data.components['co'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyMedium),
        Text('O3: ${data.components['o3'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyMedium),
      ],
    );
  }
}
