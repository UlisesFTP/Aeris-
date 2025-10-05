import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:air_quality_flutter/api/api_service.dart';
import 'package:air_quality_flutter/api/models.dart';
import 'package:air_quality_flutter/api/notifications_service.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  AirQualityData? _airQualityData;
  List<LocationSearchResult> _searchResults = [];
  bool _isLoading = false;
  Marker? _currentMarker;

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

      // --- CAMBIO PRINCIPAL AQUÍ ---
      // Ahora la notificación usa una recomendación inteligente
      if (data.aqi >= 4) {
        _notificationService.showNotification(
          title: 'Alerta de Calidad del Aire',
          body: _getAqiRecommendation(data.aqi), // <-- Se usa la nueva función
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

  // --- NUEVA FUNCIÓN PARA LAS RECOMENDACIONES ---
  String _getAqiRecommendation(int aqi) {
    switch (aqi) {
      case 4:
        return 'Calidad del aire MALA. Se recomienda a los grupos sensibles reducir la actividad al aire libre.';
      case 5:
        return 'Calidad del aire MUY MALA. Evita las actividades al aire libre y considera usar cubrebocas si sales.';
      case 6: // Suponiendo que el AQI puede llegar a 6
        return 'PELIGROSO. Permanece en interiores y mantén las ventanas cerradas.';
      default:
        return 'Los niveles de contaminación son altos. Considera limitar la actividad al aire libre.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitor de Calidad del Aire'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return (constraints.maxWidth > 700)
              ? _buildWideLayout()
              : _buildNarrowLayout();
        },
      ),
    );
  }

  Widget _buildWideLayout() => Row(
        children: [
          SizedBox(width: 380, child: _buildControlsPanel()),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),
          Expanded(child: _buildMap()),
        ],
      );

  Widget _buildNarrowLayout() => Column(
        children: [
          SizedBox(height: 320, child: _buildControlsPanel()),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Expanded(child: _buildMap()),
        ],
      );

  Widget _buildControlsPanel() => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar ubicación...',
                suffixIcon: IconButton(
                    icon: const Icon(Icons.search), onPressed: _searchLocation),
              ),
              onSubmitted: (_) => _searchLocation(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isNotEmpty
                      ? _buildSearchResults()
                      : _buildAirQualityDisplay(),
            ),
          ],
        ),
      );

  Widget _buildMap() => FlutterMap(
        mapController: _mapController,
        options: MapOptions(
            initialCenter: const LatLng(23.6345, -102.5528),
            initialZoom: 5.0,
            onTap: (_, point) => _onLocationSelected(LocationSearchResult(
                displayName: "Ubicación seleccionada",
                latitude: point.latitude,
                longitude: point.longitude))),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (_currentMarker != null) MarkerLayer(markers: [_currentMarker!]),
          RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: () =>
                    launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
              ),
            ],
          ),
        ],
      );

  Widget _buildSearchResults() => ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final location = _searchResults[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              title: Text(location.displayName),
              onTap: () => _onLocationSelected(location),
              dense: true,
            ),
          );
        },
      );

  Widget _buildAirQualityDisplay() {
    if (_airQualityData == null) {
      return Center(
          child: Text(
        'Selecciona una ubicación para ver los datos.',
        style: Theme.of(context).textTheme.bodyLarge,
      ));
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          aqiText[aqiValue],
          style: textTheme.displaySmall?.copyWith(
            color: aqiColors[aqiValue],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text('PM2.5: ${data.components['pm2_5'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyLarge),
        Text('CO: ${data.components['co'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyLarge),
        Text('O3: ${data.components['o3'] ?? 'N/A'} µg/m³',
            style: textTheme.bodyLarge),
      ],
    );
  }
}
