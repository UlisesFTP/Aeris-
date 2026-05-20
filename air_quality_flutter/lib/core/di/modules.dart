import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/hive_service.dart';

/// Módulo injectable que registra dependencias externas que requieren
/// inicialización asíncrona.
///
/// @preResolve hace que injectable llame al factory durante initGetIt()
/// y lo guarde como singleton antes de construir cualquier clase que dependa de él.
///
/// PREREQUISITO en main.dart (antes de configureDependencies()):
///   await HiveFlutter.initFlutter();
@module
abstract class AppModule {
  /// SharedPreferences: inicializado de forma asíncrona.
  @singleton
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// HiveService: abre las cajas Hive de forma asíncrona.
  /// Requiere que HiveFlutter.initFlutter() haya sido llamado en main.dart.
  @singleton
  @preResolve
  Future<HiveService> get hiveService => HiveService.create();
}
