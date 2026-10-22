import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/app_notification.dart';
import '../../widgets/app_design.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Column(
        children: [
          AppHeaderBox(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 22),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Text(
                    'Notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Mark all as read',
                  icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                  onPressed: controller.markAllRead,
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading && !controller.hasLoaded.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: controller.load,
                child: controller.items.isEmpty
                    ? _buildEmpty()
                    : NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.items.length +
                              (controller.isFetchingMore.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == controller.items.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            }
                            return _NotificationCard(
                              notification: controller.items[index],
                              onTap: () => _open(controller.items[index]),
                            );
                          },
                        ),
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 90),
        Icon(Icons.notifications_none_rounded,
            size: 84, color: Color(0xFF9DB7E0)),
        SizedBox(height: 14),
        Center(
          child: Text('No notifications yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink)),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Messages from Taksh will show up here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.muted),
          ),
        ),
      ],
    );
  }

  void _open(AppNotification notification) {
    controller.markRead(notification);
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink)),
              if (notification.sentAt != null) ...[
                const SizedBox(height: 4),
                Text(_formatTime(notification.sentAt!),
                    style:
                        const TextStyle(fontSize: 12, color: AppTheme.muted)),
              ],
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(notification.message,
                      style: const TextStyle(
                          fontSize: 15, height: 1.4, color: AppTheme.ink)),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.hour >= 12 ? 'PM' : 'AM';
    return '${t.day} ${months[t.month - 1]} ${t.year}, $hour:$minute $suffix';
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !notification.isRead;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? const Color(0xFFEAF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.brandBlue.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_rounded,
                  color: AppTheme.brandBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, height: 1.35, color: AppTheme.muted),
                  ),
                  if (notification.sentAt != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      NotificationsScreen._formatTime(notification.sentAt!),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (unread)
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 4, left: 6),
                decoration: const BoxDecoration(
                  color: AppTheme.brandBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
