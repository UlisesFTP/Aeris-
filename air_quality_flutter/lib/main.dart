import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Load environment variables
  await dotenv.load(fileName: "assets/.env");

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar servicio de notificaciones (solo en plataformas móviles)
  // En web, las notificaciones locales no están soportadas completamente
  if (!kIsWeb) {
    final notificationService = NotificationService();
    await notificationService.initNotifications();
  }

  // Comprobar si se debe mostrar la pantalla de bienvenida
  final prefs = await SharedPreferences.getInstance();
  final bool showWelcome = prefs.getBool('showWelcome') ?? true;

  // Correr la app con un proveedor de estado para manejar el tema
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
    // Set initial language after first frame
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
      final languageCode = locale.languageCode;
      Provider.of<AppState>(context, listen: false)
          .updateLanguage(languageCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar los cambios de tema desde AppState
    final appState = Provider.of<AppState>(context);

    return MaterialApp(
      title: 'Air Quality Monitor',
      // Cambiar dinámicamente entre el tema claro y oscuro
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
