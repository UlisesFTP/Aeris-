// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../api/api_service.dart' as _i578;
import '../../api/notifications_service.dart' as _i971;
import '../../services/alert_monitoring_service.dart' as _i774;
import '../database/hive_service.dart' as _i383;
import '../notifiers/alert_notifier.dart' as _i84;
import '../notifiers/location_notifier.dart' as _i597;
import '../notifiers/map_data_notifier.dart' as _i986;
import '../notifiers/theme_notifier.dart' as _i1024;
import 'modules.dart' as _i738;

// initializes the registration of main-scope dependencies inside of GetIt
Future<_i174.GetIt> initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) async {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  gh.singleton<_i578.ApiService>(() => _i578.ApiService());
  gh.singleton<_i971.NotificationService>(() => _i971.NotificationService());
  await gh.singletonAsync<_i460.SharedPreferences>(
    () => appModule.prefs,
    preResolve: true,
  );
  await gh.singletonAsync<_i383.HiveService>(
    () => appModule.hiveService,
    preResolve: true,
  );
  gh.singleton<_i986.MapDataNotifier>(
      () => _i986.MapDataNotifier(gh<_i460.SharedPreferences>()));
  gh.singleton<_i1024.ThemeNotifier>(
      () => _i1024.ThemeNotifier(gh<_i460.SharedPreferences>()));
  gh.singleton<_i774.AlertMonitoringService>(() => _i774.AlertMonitoringService(
        gh<_i578.ApiService>(),
        gh<_i971.NotificationService>(),
      ));
  gh.singleton<_i84.AlertNotifier>(() => _i84.AlertNotifier(
        gh<_i460.SharedPreferences>(),
        gh<_i383.HiveService>(),
        gh<_i774.AlertMonitoringService>(),
      ));
  gh.singleton<_i597.LocationNotifier>(() => _i597.LocationNotifier(
        gh<_i460.SharedPreferences>(),
        gh<_i383.HiveService>(),
      ));
  return getIt;
}

class _$AppModule extends _i738.AppModule {}
