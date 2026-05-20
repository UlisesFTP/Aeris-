import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'services/background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'theme.dart';
import 'core/di/di.dart';
import 'core/database/hive_service.dart';
import 'core/database/migration_service.dart';
import 'core/notifiers/theme_notifier.dart';
import 'core/notifiers/location_notifier.dart';
import 'core/notifiers/alert_notifier.dart';
import 'core/notifiers/map_data_notifier.dart';
import 'api/notifications_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

/// Ping fire-and-forget al backend para reducir cold-start en servicios
/// como Render. No bloquea el inicio de la app.
void _warmUpBackend() {
  try {
    final url = dotenv.env['API_URL'];
    if (url != null && url.isNotEmpty) {
      http.get(Uri.parse('$url/health')).timeout(const Duration(seconds: 5)).catchError((_) {
        // Silencioso: solo es un precalentamiento
        return http.Response('', 500);
      });
    }
  } catch (_) {
    // Ignorar cualquier error de warm-up
  }
}

Future<void> main() async {
  // Asegurarse de que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: 'assets/.env');

  // Precalentar backend: ping fire-and-forget para despertar el servidor
  // (especialmente útil en Render con cold starts)
  _warmUpBackend();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    // -----------------------------------------------------------------------
    // 1. Registrar el handler de mensajes FCM en segundo plano (app cerrada).
    //    DEBE registrarse ANTES de cualquier otro listener de Firebase.
    //    Es la función top-level definida en notifications_service.dart.
    // -----------------------------------------------------------------------
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // -----------------------------------------------------------------------
    // 2. Inicializar el servicio de notificaciones locales y crear los canales
    //    de Android (weather_status + air_quality_alerts).
    // -----------------------------------------------------------------------
    final notificationService = NotificationService();
    await notificationService.initNotifications();

    // -----------------------------------------------------------------------
    // 3. Inicializar WorkManager y registrar la tarea periódica.
    //    - Frecuencia: 15 min (mínimo que acepta Android).
    //    - ExistingWorkPolicy.keep: si ya existe la tarea (por ej. tras hot
    //      restart en debug), NO la reinicia. Evita duplicados.
    //    - Constraints: solo cuando hay conexión a internet.
    // -----------------------------------------------------------------------
    await Workmanager().initialize(
      callbackDispatcher,
    );

    await Workmanager().registerPeriodicTask(
      uniqueTaskName,
      taskName,
      frequency: kWorkManagerInterval,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep, // No reiniciar si ya existe
    );

    if (kDebugMode) {
      print('[Main] WorkManager registrado. Intervalo: $kWorkManagerInterval');
    }
  }

  // Inicializar Hive ANTES de configureDependencies() para que
  // AppModule.hiveService (@preResolve) pueda abrir las cajas.
  await Hive.initFlutter();

  // Configurar inyección de dependencias (get_it + injectable).
  // SharedPreferences y HiveService son registrados internamente con @preResolve.
  await configureDependencies();

  // Migración one-shot: mueve datos de SharedPreferences → Hive si aún no se hizo.
  await MigrationService.run(
    prefs: getIt<SharedPreferences>(),
    hive: getIt<HiveService>(),
  );

  // Comprobar si se debe mostrar la pantalla de bienvenida
  final prefs = getIt<SharedPreferences>();
  final bool showWelcome = prefs.getBool('showWelcome') ?? true;

  runApp(
    MultiProvider(
      providers: [
        // ThemeNotifier: tema oscuro/claro + código de idioma
        ChangeNotifierProvider<ThemeNotifier>.value(
          value: getIt<ThemeNotifier>(),
        ),
        // LocationNotifier: ubicaciones guardadas, recientes, historial
        ChangeNotifierProvider<LocationNotifier>.value(
          value: getIt<LocationNotifier>(),
        ),
        // AlertNotifier: alertas de AQI, ajustes de notificaciones
        ChangeNotifierProvider<AlertNotifier>.value(
          value: getIt<AlertNotifier>(),
        ),
        // MapDataNotifier: caché local de datos del mapa
        ChangeNotifierProvider<MapDataNotifier>.value(
          value: getIt<MapDataNotifier>(),
        ),
      ],
      child: MyApp(showWelcome: showWelcome),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool showWelcome;

  const MyApp({super.key, required this.showWelcome});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLanguage();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    _updateLanguage();
  }

  void _updateLanguage() {
    if (mounted) {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final code = locale.languageCode;
      // ThemeNotifier guarda el código de idioma para uso general.
      Provider.of<ThemeNotifier>(context, listen: false).updateLanguage(code);
      // AlertNotifier lo necesita para las notificaciones de alerta.
      Provider.of<AlertNotifier>(context, listen: false).updateLanguageCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Aeris',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'), // Español
        Locale('en'), // English
      ],
      home: widget.showWelcome ? const WelcomeScreen() : const MainShell(),
    );
  }
}
