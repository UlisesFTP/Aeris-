import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // --- 1. Configuración de Notificaciones Locales ---
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _localNotificationsPlugin.initialize(settings);

    // --- 2. Configuración de Notificaciones Push (Firebase) ---
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print("Firebase FCM Token: $fcmToken");
  }

  // --- 3. VERIFICAR QUE ESTA FUNCIÓN EXISTA ---
  Future<void> showNotification(
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'air_quality_channel', // id del canal
      'Alertas de Calidad del Aire', // nombre del canal
      channelDescription:
          'Notificaciones sobre niveles altos de contaminación.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0, // id único para la notificación
      title,
      body,
      notificationDetails,
    );
  }
}
