import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/repository/notification_repository.dart';
import '../constants/app_routes.dart';
import 'session_service.dart';

/// Runs when a push arrives while the app is in the background or closed. The system already
/// shows the notification itself (the server sends a `notification` payload), so there is
/// nothing to display here. It must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Not configured on this build: nothing to do in the background either.
  }
}

/// Firebase push notifications of the delivery app (same Firebase project and server as the
/// Taksh customer app; the admin panel's "Delivery app" notifications arrive here).
///
/// Firebase is optional at runtime: when it is not configured for this build, [initialize]
/// logs and returns, and every other method does nothing, so the app starts and works exactly
/// as before.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  /// Unread notifications of the inbox (bell badge).
  final unreadCount = 0.obs;

  bool _ready = false;
  bool _listening = false;
  bool _loggedIn = false;
  String? _registeredToken;
  RemoteMessage? _pendingOpen;

  /// Starts Firebase and the message listeners. Safe to call more than once; never throws.
  Future<void> initialize() async {
    if (_ready) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _ready = true;
    } catch (e) {
      debugPrint('[push] Firebase is not configured for this build, push is off: $e');
      return;
    }

    try {
      _listen();
      // The push that launched the app from a closed state, if any.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _pendingOpen = initial;
    } catch (e) {
      debugPrint('[push] listeners failed to start: $e');
    }
  }

  void _listen() {
    if (_listening) return;
    _listening = true;

    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
    FirebaseMessaging.instance.onTokenRefresh.listen(
      _register,
      onError: (Object e) => debugPrint('[push] token refresh failed: $e'),
    );
  }

  /// The delivery man is logged in: ask for the notification permission (Android 13+), register
  /// this device with the server and open a push that launched the app. Call it after every
  /// login and every app start with a saved session. Never throws.
  Future<void> onLogin() async {
    if (!_ready) return;
    if (!Get.isRegistered<SessionService>()) return;

    final session = Get.find<SessionService>();
    // The offline demo login has no real server session to attach a device to.
    if (!session.isLoggedIn || session.isMockSession) return;
    _loggedIn = true;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('[push] notification permission not granted, device not registered');
      } else {
        final token = await FirebaseMessaging.instance.getToken();
        debugPrint('[push] FCM token ${token == null ? 'NOT available' : 'received'}');
        if (token != null) await _register(token);
      }
    } catch (e) {
      debugPrint('[push] registration failed: $e');
    }

    refreshUnreadCount();
    _openPending();
  }

  Future<void> _register(String deviceToken) async {
    if (!_loggedIn || deviceToken == _registeredToken) return;
    if (!Get.isRegistered<SessionService>() ||
        !Get.isRegistered<NotificationRepository>()) {
      return;
    }

    final sessionToken = Get.find<SessionService>().token;
    if (sessionToken == null || sessionToken.isEmpty) return;

    try {
      final response = await Get.find<NotificationRepository>().registerDevice(
        deviceToken: deviceToken,
        platform: defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        token: sessionToken,
      );
      if (response is Map && response['success'] == true) {
        _registeredToken = deviceToken;
        debugPrint('[push] device registered with the server');
      } else {
        // Left unregistered: the next login, app start or token refresh tries again.
        debugPrint('[push] server rejected the device registration: $response');
      }
    } catch (e) {
      debugPrint('[push] device registration failed: $e');
    }
  }

  /// Stops pushes for the current delivery man on this device only. Call it BEFORE the login
  /// token is cleared / revoked, because the server removes the device for the logged-in user.
  /// Best effort: a failure must never block the logout.
  Future<void> unregisterDevice() async {
    final wasLoggedIn = _loggedIn;
    _loggedIn = false;
    final known = _registeredToken;
    _registeredToken = null;
    _pendingOpen = null;
    unreadCount.value = 0;
    if (!_ready || !wasLoggedIn) return;
    if (!Get.isRegistered<SessionService>() ||
        !Get.isRegistered<NotificationRepository>()) {
      return;
    }

    try {
      final sessionToken = Get.find<SessionService>().token;
      final deviceToken = known ?? await FirebaseMessaging.instance.getToken();
      if (sessionToken == null || deviceToken == null) return;
      await Get.find<NotificationRepository>()
          .unregisterDevice(deviceToken: deviceToken, token: sessionToken)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[push] device unregistration failed: $e');
    }
  }

  /// Reloads the unread count of the bell badge.
  Future<void> refreshUnreadCount() async {
    if (!_loggedIn) return;
    if (!Get.isRegistered<SessionService>() ||
        !Get.isRegistered<NotificationRepository>()) {
      return;
    }
    final sessionToken = Get.find<SessionService>().token;
    if (sessionToken == null || sessionToken.isEmpty) return;

    try {
      final response = await Get.find<NotificationRepository>()
          .getUnreadCount(token: sessionToken);
      if (response is Map && response['success'] == true) {
        final count = int.tryParse('${response['data']?['unread_count']}');
        if (count != null) unreadCount.value = count;
      }
    } catch (e) {
      debugPrint('[push] unread count failed: $e');
    }
  }

  void _onForeground(RemoteMessage message) {
    final notification = message.notification;
    debugPrint('[push] message received while the app is open');
    if (notification == null) return;

    refreshUnreadCount();

    Get.snackbar(
      notification.title ?? 'Taksh',
      notification.body ?? '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.white,
      colorText: const Color(0xFF1B2A4A),
      icon: const Icon(Icons.notifications_active, color: Color(0xFF1565C0)),
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(12),
      onTap: (_) => _openInbox(),
    );
  }

  /// The app was in the background and the delivery man tapped the notification.
  void _onOpened(RemoteMessage message) {
    debugPrint('[push] notification tapped');
    _pendingOpen = message;
    if (_loggedIn) _openPending();
  }

  /// Opens the inbox for a remembered tap, once. Waits a moment so the app's own start-up
  /// navigation (splash, home) has finished and does not replace it.
  void _openPending() {
    if (_pendingOpen == null) return;
    _pendingOpen = null;
    Future<void>.delayed(const Duration(milliseconds: 800), _openInbox);
  }

  void _openInbox() {
    if (!_loggedIn) return;
    if (Get.currentRoute == AppRoutes.notifications) return;
    Get.toNamed(AppRoutes.notifications);
  }
}
