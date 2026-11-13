import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import 'session_service.dart';

/// Online / offline switch of the rider (`is_online` on the server).
///
/// The server is the source of truth: it sets online on login, offline on logout and
/// offline again when the app stops pinging. This service only mirrors it, flips it
/// from the header switch and keeps it alive with a heartbeat while the app is open.
class OnlineStatusService extends GetxService with WidgetsBindingObserver {
  static const _heartbeatEvery = Duration(seconds: 60);

  final isOnline = false.obs;
  final isBusy = false.obs;

  Timer? _timer;

  static OnlineStatusService get instance => Get.isRegistered<OnlineStatusService>()
      ? Get.find<OnlineStatusService>()
      : Get.put(OnlineStatusService(), permanent: true);

  ApiClient get _api => Get.find<ApiClient>();
  String? get _token => Get.isRegistered<SessionService>() ? Get.find<SessionService>().token : null;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The server may have set us offline while the app was in the background.
      refresh();
    } else if (state == AppLifecycleState.paused) {
      _stopHeartbeat();
    }
  }

  /// Read the current state from the server (profile).
  Future<void> refresh() async {
    final token = _token;
    if (token == null) return;
    try {
      final res = await _api.get(AppConstants.profileEndpoint, token: token);
      if (res is Map && res['success'] == true && res['data'] is Map) {
        _apply(_asBool(res['data']['is_online']));
      }
    } catch (_) {
      // Keep whatever is shown; the next refresh corrects it.
    }
  }

  /// Switch from the header. Reverts the switch if the server did not accept it.
  Future<void> setOnline(bool value) async {
    final token = _token;
    if (token == null || isBusy.value) return;
    final previous = isOnline.value;
    isBusy.value = true;
    isOnline.value = value; // optimistic
    try {
      final res = await _api.post(AppConstants.onlineStatusEndpoint,
          body: {'is_online': value}, token: token);
      if (res is Map && res['success'] == true) {
        _apply(value);
      } else {
        isOnline.value = previous;
        Get.snackbar('Status', (res is Map ? res['message'] : null)?.toString() ?? 'Could not update status',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      isOnline.value = previous;
      Get.snackbar('Status', 'Could not update status',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBusy.value = false;
    }
  }

  /// Call on logout: the server sets offline itself, this only stops the local timer.
  void reset() {
    _stopHeartbeat();
    isOnline.value = false;
  }

  void _apply(bool online) {
    isOnline.value = online;
    if (online) {
      _startHeartbeat();
    } else {
      _stopHeartbeat();
    }
  }

  void _startHeartbeat() {
    _timer?.cancel();
    _timer = Timer.periodic(_heartbeatEvery, (_) => _beat());
  }

  void _stopHeartbeat() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _beat() async {
    final token = _token;
    if (token == null) return _stopHeartbeat();
    try {
      final res = await _api.post(AppConstants.heartbeatEndpoint, token: token);
      if (res is Map && res['success'] == true && res['data'] is Map) {
        _apply(_asBool(res['data']['is_online']));
      }
    } catch (_) {}
  }

  bool _asBool(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';
}
