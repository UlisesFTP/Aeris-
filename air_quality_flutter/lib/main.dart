import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
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
import 'core/app_state.dart';
import 'api/notifications_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:air_quality_flutter/l10n/app_localizations.dart';

Future<void> main() async {
  // Asegurarse de que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: 'assets/.env');

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

  // Comprobar si se debe mostrar la pantalla de bienvenida
  final prefs = await SharedPreferences.getInstance();
  final bool showWelcome = prefs.getBool('showWelcome') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
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
      Provider.of<AppState>(context, listen: false)
          .updateLanguage(locale.languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Aeris',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
