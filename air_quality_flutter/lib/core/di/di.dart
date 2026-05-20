// Archivo generado por injectable. No editar manualmente.
// Ejecutar: dart run build_runner build --delete-conflicting-outputs

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart'; // generado por build_runner

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'initGetIt', // nombre de la función generada
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async {
  // initGetIt es async porque AppModule tiene @preResolve (SharedPreferences)
  await initGetIt(getIt);
}
