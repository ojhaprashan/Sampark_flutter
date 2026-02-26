import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background message handler (must be a top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 [FCM] Background message received: ${message.messageId}');
  print('   ├─ Title: ${message.notification?.title}');
  print('   ├─ Body: ${message.notification?.body}');
  print('   └─ Data: ${message.data}');

  // Show local notification when message is received in background
  await FirebaseNotificationService.showLocalNotification(message);
}

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initialize Firebase Cloud Messaging and Local Notifications
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ [FCM] Already initialized');
      return;
    }

    try {
      print('🔄 [FCM] Initializing...');

      // Initialize Firebase with error handling
      try {
        await Firebase.initializeApp();
        print('✅ [FCM] Firebase initialized');
      } catch (e) {
        print('⚠️ [FCM] Firebase initialization warning: $e');
        print('⚠️ [FCM] Continuing with limited FCM functionality');
        // Continue even if Firebase init fails - allows app to work without real FCM
      }

      // Try to set the background message handler
      try {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
      } catch (e) {
        print('⚠️ [FCM] Background message handler warning: $e');
      }

      // Request permission for iOS
      try {
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        print('🔔 [FCM] Permissions requested: ${settings.authorizationStatus}');
      } catch (e) {
        print('⚠️ [FCM] Permission request warning: $e');
      }

      // Initialize local notifications for Android & iOS
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      try {
        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: _handleNotificationTap,
        );
        print('✅ [FCM] Local notifications initialized');
      } catch (e) {
        print('⚠️ [FCM] Local notifications init warning: $e');
      }

      // Handle foreground messages
      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('🔔 [FCM] Foreground message received: ${message.messageId}');
          print('   ├─ Title: ${message.notification?.title}');
          print('   ├─ Body: ${message.notification?.body}');
          print('   └─ Data: ${message.data}');

          showLocalNotification(message);
        });
      } catch (e) {
        print('⚠️ [FCM] Foreground message listener warning: $e');
      }

      // Handle notification tap when app is in background/terminated
      try {
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('🔔 [FCM] Notification tapped (App was in background): ${message.messageId}');
          _handleNotificationTap(
            NotificationResponse(
              notificationResponseType:
                  NotificationResponseType.selectedNotification,
              payload: message.data.toString(),
            ),
          );
        });
      } catch (e) {
        print('⚠️ [FCM] Message opened app listener warning: $e');
      }

      _isInitialized = true;
      print('✅ [FCM] Initialization complete');
    } catch (e) {
      print('⚠️ [FCM] Initialization warning: $e');
      _isInitialized = true; // Mark as initialized even if partial success
    }
  }

  /// Get FCM Token for this device
  static Future<String?> getFCMToken() async {
    try {
      // Try to get token with retries (Firebase might take a moment to initialize)
      String? token;
      int retryCount = 0;
      const maxRetries = 3;
      
      while (token == null && retryCount < maxRetries) {
        try {
          token = await _firebaseMessaging.getToken();
          if (token != null) {
            print('🔑 [FCM] Token obtained: ${token.substring(0, 20)}...');
            return token;
          }
        } catch (e) {
          print('⚠️ [FCM] Retry ${retryCount + 1}/$maxRetries failed: $e');
        }
        
        retryCount++;
        if (token == null && retryCount < maxRetries) {
          // Wait 1 second before retrying
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      
      if (token == null) {
        print('❌ [FCM] Failed to get token after $maxRetries attempts');
        print('❌ [FCM] Firebase may not be properly initialized');
        print('❌ [FCM] Possible causes:');
        print('   ├─ Google Play Services not installed');
        print('   ├─ Firebase not initialized in main.dart');
        print('   ├─ Invalid google-services.json');
        print('   └─ Network issues');
        return null;
      }
      
      return token;
    } catch (e) {
      print('❌ [FCM] Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM Token to SharedPreferences
  static Future<void> saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      print('💾 [FCM] Token saved to SharedPreferences');
    } catch (e) {
      print('❌ [FCM] Error saving FCM token: $e');
    }
  }

  /// Get saved FCM Token from SharedPreferences
  static Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      if (token != null) {
        print('🔑 [FCM] Retrieved saved token: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e) {
      print('❌ [FCM] Error getting saved FCM token: $e');
      return null;
    }
  }

  /// Show local notification (called from foreground listener or background handler)
  static Future<void> showLocalNotification(RemoteMessage message) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'sampark_channel',
        'Sampark Notifications',
        channelDescription: 'Important notifications from Sampark',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        message.notification?.title ?? 'Sampark',
        message.notification?.body ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      print('✅ [FCM] Local notification shown');
    } catch (e) {
      print('❌ [FCM] Error showing notification: $e');
    }
  }

  /// Handle notification tap
  static void _handleNotificationTap(NotificationResponse response) {
    print('🔔 [FCM] Notification tapped: ${response.payload}');
    // TODO: Add navigation logic based on notification payload if needed
  }

  /// Delete token on logout
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      print('🗑️ [FCM] Token deleted');
    } catch (e) {
      print('❌ [FCM] Error deleting token: $e');
    }
  }
}
