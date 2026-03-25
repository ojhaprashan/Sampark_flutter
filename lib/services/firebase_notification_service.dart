import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/widgets/video_call_dialog.dart';
import '../pages/AppWebView/appweb.dart';

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

  /// Global Navigator Key to access context from static service
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        
        // Heads up notifications for iOS/macOS when app is in foreground
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
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
          onDidReceiveNotificationResponse: _handleLocalNotificationTap,
        );
        
        // Create the Android notification channel explicitly
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'sampark_channel', // id
          'Sampark Notifications', // title
          description: 'Important notifications from Sampark', // description
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        print('✅ [FCM] Local notifications and channel initialized');
      } catch (e) {
        print('⚠️ [FCM] Local notifications init warning: $e');
      }

      // Handle foreground messages
      try {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('🔔 [FCM] Foreground message received: ${message.messageId}');
          
          final data = message.data;
          final acceptUrl = data['accept_url'];
          
          if (acceptUrl != null && acceptUrl.isNotEmpty) {
            print('📞 Incoming Video Call Request Detected');
            _showVideoCallUI(
              acceptUrl: acceptUrl,
              declineUrl: data['declined_url'] ?? '',
              message: message.notification?.body ?? data['body'] ?? 'Incoming Call...',
            );
          } else {
            showLocalNotification(message);
          }
        });
      } catch (e) {
        print('⚠️ [FCM] Foreground message listener warning: $e');
      }

      // Handle notification tap when app is in background/terminated
      try {
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('🔔 [FCM] Notification tapped (App was in background): ${message.messageId}');
          _handleNotificationTap(message);
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

  /// Show Video Call Accept/Reject UI
  static void _showVideoCallUI({
    required String acceptUrl,
    required String declineUrl,
    required String message,
  }) {
    final context = navigatorKey.currentContext;
    if (context == null) {
      print('❌ [FCM] Cannot show VideoCallUI: context is null');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => VideoCallDialog(
        message: message,
        acceptUrl: acceptUrl,
        declineUrl: declineUrl,
      ),
    );
  }

  /// Handle notification tap (Background/Terminated)
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔔 [FCM] Handling notification tap: ${message.data}');
    
    final acceptUrl = message.data['accept_url'];
    if (acceptUrl != null && acceptUrl.isNotEmpty) {
      final context = navigatorKey.currentContext;
      if (context != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InAppWebViewPage(
              url: acceptUrl,
              title: 'Video Call',
            ),
          ),
        );
      }
    }
  }

  /// Handle local notification tap (Foreground)
  static void _handleLocalNotificationTap(NotificationResponse response) {
    print('🔔 [FCM] Local notification tapped: ${response.payload}');
    // Parse payload if it's a JSON string of RemoteMessage.data
  }

  /// Get FCM Token
  static Future<String?> getFCMToken() async {
    try {
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
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      return token;
    } catch (e) {
      print('❌ [FCM] Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM Token
  static Future<void> saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    } catch (e) {
      print('❌ [FCM] Error saving FCM token: $e');
    }
  }

  /// Get saved FCM Token
  static Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      return null;
    }
  }

  /// Show local notification
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
        message.notification?.title ?? message.data['title'] ?? 'Sampark',
        message.notification?.body ?? message.data['body'] ?? '',
        platformChannelSpecifics,
        payload: message.data.toString(),
      );

      print('✅ [FCM] Local notification shown');
    } catch (e) {
      print('❌ [FCM] Error showing notification: $e');
    }
  }

  /// Delete token
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
    } catch (e) {
      print('❌ [FCM] Error deleting token: $e');
    }
  }
}
