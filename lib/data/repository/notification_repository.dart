import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';

/// Push registration and the notification inbox of the delivery man.
class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<dynamic> registerDevice({
    required String deviceToken,
    required String platform,
    required String token,
  }) {
    return apiClient.post(
      AppConstants.deviceTokenEndpoint,
      body: {'token': deviceToken, 'platform': platform},
      token: token,
    );
  }

  Future<dynamic> unregisterDevice({
    required String deviceToken,
    required String token,
  }) {
    return apiClient.delete(
      AppConstants.deviceTokenEndpoint,
      body: {'token': deviceToken},
      token: token,
    );
  }

  Future<dynamic> getNotifications({required int page, required String token}) {
    return apiClient.get(
      '${AppConstants.notificationsEndpoint}?page=$page&per_page=20',
      token: token,
    );
  }

  Future<dynamic> getUnreadCount({required String token}) {
    return apiClient.get(AppConstants.notificationsUnreadCountEndpoint,
        token: token);
  }

  Future<dynamic> markRead({required int id, required String token}) {
    return apiClient.post(
      AppConstants.notificationReadEndpoint.replaceFirst('{id}', '$id'),
      token: token,
    );
  }

  Future<dynamic> markAllRead({required String token}) {
    return apiClient.post(AppConstants.notificationsReadAllEndpoint,
        token: token);
  }
}
