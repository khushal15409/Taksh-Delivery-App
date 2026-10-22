import 'package:get/get.dart';

import '../../../core/services/push_notification_service.dart';
import '../../../core/services/session_service.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repository/notification_repository.dart';
import '../../controllers/base_controller.dart';

/// The delivery app's notification inbox (messages sent from the admin panel).
class NotificationsController extends BaseController {
  final NotificationRepository _repository = Get.find<NotificationRepository>();
  final SessionService _session = Get.find<SessionService>();

  final items = <AppNotification>[].obs;
  final isFetchingMore = false.obs;
  final hasLoaded = false.obs;

  int _page = 1;
  int _lastPage = 1;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      if (!hasLoaded.value) showLoading();
      _page = 1;
      final response = await _repository.getNotifications(
          page: _page, token: _session.token ?? '');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final list = (data['items'] as List? ?? [])
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        items.assignAll(list);
        _lastPage = int.tryParse('${data['pagination']?['last_page']}') ?? 1;
        _syncUnread(data['unread_count']);
      } else {
        handleError(response['message'] ?? 'Could not load your notifications.');
      }
    } catch (e) {
      handleError(e);
    } finally {
      hasLoaded.value = true;
      hideLoading();
    }
  }

  Future<void> loadMore() async {
    if (isFetchingMore.value || _page >= _lastPage) return;
    try {
      isFetchingMore.value = true;
      final response = await _repository.getNotifications(
          page: _page + 1, token: _session.token ?? '');
      if (response['success'] == true && response['data'] != null) {
        _page++;
        items.addAll((response['data']['items'] as List? ?? [])
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))));
      }
    } catch (_) {
      // Pulling down to refresh tries again; nothing to tell the user here.
    } finally {
      isFetchingMore.value = false;
    }
  }

  Future<void> markRead(AppNotification notification) async {
    if (notification.isRead) return;
    final index = items.indexWhere((n) => n.id == notification.id);
    if (index != -1) items[index] = notification.copyWith(isRead: true);

    try {
      final response = await _repository.markRead(
          id: notification.id, token: _session.token ?? '');
      if (response is Map && response['success'] == true) {
        _syncUnread(response['data']?['unread_count']);
      }
    } catch (_) {
      // The badge is corrected on the next refresh.
    }
  }

  Future<void> markAllRead() async {
    if (items.every((n) => n.isRead)) return;
    try {
      final response =
          await _repository.markAllRead(token: _session.token ?? '');
      if (response is Map && response['success'] == true) {
        items.assignAll(items.map((n) => n.copyWith(isRead: true)).toList());
        PushNotificationService.instance.unreadCount.value = 0;
      } else {
        handleError(response['message'] ?? 'Could not update your notifications.');
      }
    } catch (e) {
      handleError(e);
    }
  }

  void _syncUnread(dynamic value) {
    final count = int.tryParse('$value');
    if (count != null) PushNotificationService.instance.unreadCount.value = count;
  }
}
