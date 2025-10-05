import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Importar Firebase Core
import 'firebase_options.dart'; // 2. Importar el archivo generado por FlutterFire
import 'theme.dart';

// 3. Convertir main en una función asíncrona
Future<void> main() async {
  // 4. Asegurarse de que los bindings de Flutter estén listos antes de cualquier cosa
  WidgetsFlutterBinding.ensureInitialized();

  // 5. Inicializar Firebase usando las opciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 6. Ahora, con Firebase listo, corremos la aplicación
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitor de Calidad del Aire',
      theme: darkTheme, // Aplicar el tema personalizado
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
