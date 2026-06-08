import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // Skip on web - Firebase Messaging not supported
    if (kIsWeb) {
      print('⚠️ Notifications disabled on web');
      return;
    }
    
    try {
      // Request permissions
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notifications authorized');
      }
      
      // Get FCM token
      final token = await _fcm.getToken();
      print('📱 FCM Token: $token');
      
      // Initialize local notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings();
      const settingsInit = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(settingsInit);
      
      // Handle messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_showLocalNotification);
      
      // Handle messages when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);
    } catch (e) {
      print('⚠️ Notifications initialization failed: $e');
    }
  }

  static void _showLocalNotification(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Update',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'zam_properties_channel',
          'ZamProperties Notifications',
          importance: Importance.high,
        ),
      ),
    );
  }

  static void _handleMessageTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Navigate based on message data
  }
}