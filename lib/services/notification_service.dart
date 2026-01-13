import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'supabase_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
  // The notification is shown automatically by FCM when app is in background
  print('Background message received: ${message.messageId}');
}

/// Service for handling push notifications
class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permissions
    await _requestPermissions();

    // Initialize local notifications (for foreground display)
    await _initializeLocalNotifications();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up notification tap handlers
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Get and save FCM token if user is authenticated
    await _updateFCMToken();

    // Listen for token refresh
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('Notification permission: ${settings.authorizationStatus}');
  }

  /// Initialize local notifications for foreground display
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // Already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  static Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Check-in reminders channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'check_in_reminders',
        'Check-in Reminders',
        description: 'Reminders to check in on schedule',
        importance: Importance.high,
      ),
    );

    // Urgent alerts channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        'urgent_alerts',
        'Urgent Alerts',
        description: 'Critical notifications about missed check-ins',
        importance: Importance.max,
        playSound: true,
      ),
    );
  }

  /// Handle foreground messages by showing local notification
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // Determine channel based on message data
    final isUrgent = message.data['urgent'] == 'true';
    final channelId = isUrgent ? 'urgent_alerts' : 'check_in_reminders';

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          isUrgent ? 'Urgent Alerts' : 'Check-in Reminders',
          importance: isUrgent ? Importance.max : Importance.high,
          priority: isUrgent ? Priority.max : Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data['route'],
    );
  }

  /// Handle notification tap from background/terminated state
  static void _handleNotificationTap(RemoteMessage message) {
    // The route data can be used to navigate to specific screen
    print('Notification tapped: ${message.data}');
    // Navigation is handled by the app's router when it opens
  }

  /// Handle local notification tap
  static void _onLocalNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    // Navigation is handled by the app's router
  }

  /// Get FCM token and save to Supabase
  static Future<void> _updateFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  /// Handle token refresh
  static Future<void> _onTokenRefresh(String token) async {
    await _saveFCMToken(token);
  }

  /// Save FCM token to Supabase user profile
  static Future<void> _saveFCMToken(String token) async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.updateFCMToken(token);
      print('FCM token saved');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Clear FCM token on logout
  static Future<void> clearToken() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    try {
      await SupabaseService.updateFCMToken(null);
      await _messaging.deleteToken();
      print('FCM token cleared');
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  /// Re-register FCM token (call after login)
  static Future<void> registerToken() async {
    await _updateFCMToken();
  }
}
