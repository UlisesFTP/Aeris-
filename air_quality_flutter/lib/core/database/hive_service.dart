import 'package:hive_flutter/hive_flutter.dart';

import '../../models/models.dart';

/// Servicio que encapsula toda la interacción con Hive.
///
/// Expone las cajas tipadas para que AppState y otros componentes
/// puedan leer y escribir datos estructurados sin conocer los detalles
/// de Hive internamente.
///
/// Se registra como singleton mediante el módulo injectable (AppModule)
/// con @preResolve, por eso NO lleva @singleton directamente en la clase.
class HiveService {
  // Nombres de las cajas — usar constantes para evitar typos.
  static const _savedLocationsBox = 'saved_locations';
  static const _alertLocationsBox = 'alert_locations';
  static const _locationHistoryBox = 'location_history';

  late final Box<SavedLocation> savedLocationsBox;
  late final Box<AlertLocation> alertLocationsBox;
  late final Box<LocationVisit> locationHistoryBox;

  HiveService._(); // Constructor privado: usar HiveService.create()

  /// Factory asíncrona: registra adaptadores y abre las cajas.
  /// Llamada desde AppModule con @preResolve.
  ///
  /// IMPORTANTE: HiveFlutter.initFlutter() debe haberse llamado
  /// ANTES de invocar este método (en main.dart, previo a configureDependencies()).
  static Future<HiveService> create() async {
    final service = HiveService._();
    await service._init();
    return service;
  }

  Future<void> _init() async {
    // Registrar adaptadores generados por hive_generator.
    // registerAdapter es idempotente si se llama varias veces con el mismo typeId.
    if (!Hive.isAdapterRegistered(SavedLocationAdapter().typeId)) {
      Hive.registerAdapter(SavedLocationAdapter());
    }
    if (!Hive.isAdapterRegistered(AlertLocationAdapter().typeId)) {
      Hive.registerAdapter(AlertLocationAdapter());
    }
    if (!Hive.isAdapterRegistered(LocationVisitAdapter().typeId)) {
      Hive.registerAdapter(LocationVisitAdapter());
    }

    // Abrir las cajas tipadas.
    savedLocationsBox =
        await Hive.openBox<SavedLocation>(_savedLocationsBox);
    alertLocationsBox =
        await Hive.openBox<AlertLocation>(_alertLocationsBox);
    locationHistoryBox =
        await Hive.openBox<LocationVisit>(_locationHistoryBox);
  }

  // ── Helpers de acceso ────────────────────────────────────────────────────

  /// Todos los SavedLocation como mapa nombre → objeto.
  Map<String, SavedLocation> get allSavedLocations {
    return Map.fromEntries(
      savedLocationsBox.keys
          .cast<String>()
          .map((k) => MapEntry(k, savedLocationsBox.get(k)!)),
    );
  }

  /// Guarda (o sobreescribe) una ubicación usando su nombre como clave.
  Future<void> putSavedLocation(String name, SavedLocation location) =>
      savedLocationsBox.put(name, location);

  /// Elimina una SavedLocation por nombre.
  Future<void> deleteSavedLocation(String name) =>
      savedLocationsBox.delete(name);

  /// Reemplaza TODAS las SavedLocations por el mapa dado.
  Future<void> replaceAllSavedLocations(
      Map<String, SavedLocation> locations) async {
    await savedLocationsBox.clear();
    await savedLocationsBox.putAll(locations);
  }

  // ──────────────────────────────────────────────────────────────────────────

  /// Todos los AlertLocation como mapa id → objeto.
  Map<String, AlertLocation> get allAlertLocations {
    return Map.fromEntries(
      alertLocationsBox.keys
          .cast<String>()
          .map((k) => MapEntry(k, alertLocationsBox.get(k)!)),
    );
  }

  /// Reemplaza TODAS las AlertLocations por el mapa dado.
  Future<void> replaceAllAlertLocations(
      Map<String, AlertLocation> locations) async {
    await alertLocationsBox.clear();
    await alertLocationsBox.putAll(locations);
  }

  // ──────────────────────────────────────────────────────────────────────────

  /// Historial de visitas ordenado por fecha descendente.
  List<LocationVisit> get allLocationHistory {
    final list = locationHistoryBox.values.toList();
    list.sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
    return list;
  }

  /// Reemplaza TODO el historial de visitas.
  Future<void> replaceAllLocationHistory(List<LocationVisit> visits) async {
    await locationHistoryBox.clear();
    await locationHistoryBox.addAll(visits);
  }

  /// Cierra todas las cajas abiertas. Llamar solo al cerrar la app si es necesario.
  Future<void> close() async {
    await savedLocationsBox.close();
    await alertLocationsBox.close();
    await locationHistoryBox.close();
  }
}
