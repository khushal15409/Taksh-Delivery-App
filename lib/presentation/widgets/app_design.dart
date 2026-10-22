import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/push_notification_service.dart';

/// Blue header with the skyline background used by every main screen.
class AppHeaderBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AppHeaderBox({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.radius = 32,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: padding.add(EdgeInsets.only(top: top)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.deepBlue, Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg_header.png'),
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
      ),
      child: child,
    );
  }
}

/// "Total / Success / Failed" tile that sits inside the header (number + label, tinted by [color]).
class StatCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;

  const StatCard({
    super.key,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppTheme.muted),
          ),
        ],
      ),
    );
  }
}

String twoDigits(int value) => value.toString().padLeft(2, '0');

/// Rounded white card used for sections of the summary / profile screens.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Donut chart: success (green), failed (red) and the remainder (grey).
class DonutChart extends StatelessWidget {
  final double success;
  final double failed;
  final double size;
  final Widget? center;

  const DonutChart({
    super.key,
    required this.success,
    required this.failed,
    this.size = 130,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(success: success, failed: failed),
        child: Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double success;
  final double failed;

  _DonutPainter({required this.success, required this.failed});

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke,
        size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFFD9DFEA);
    canvas.drawArc(rect, 0, math.pi * 2, false, paint);

    final total = success + failed;
    if (total <= 0) return;

    var start = -math.pi / 2;
    final successSweep = math.pi * 2 * (success / total);
    final failedSweep = math.pi * 2 * (failed / total);

    if (success > 0) {
      paint.color = AppTheme.success;
      canvas.drawArc(rect, start, successSweep, false, paint);
      start += successSweep;
    }
    if (failed > 0) {
      paint.color = AppTheme.danger;
      canvas.drawArc(rect, start, failedSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.success != success || old.failed != failed;
}

/// Confirmation dialog in the app's style (Exit App, ...).
Future<void> showAppConfirmDialog({
  required IconData icon,
  required String title,
  required String message,
  required String yesText,
  required String noText,
  required VoidCallback onYes,
}) {
  return Get.dialog(
    Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.danger, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.ink)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.muted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.brandBlue,
                      side: const BorderSide(color: AppTheme.brandBlue),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(noText,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onYes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    child: Text(yesText,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Empty list state (open box illustration + refresh button).
class EmptyOrdersView extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyOrdersView({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 30),
        Center(
          child: Image.asset('assets/images/empty_orders.png', width: 230),
        ),
        const SizedBox(height: 16),
        const Center(
          child: Text('No Orders Yet',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink)),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "You don't have any shipments assigned today. Please check again later.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.muted, height: 1.4),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Refresh',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.brandBlue,
              side: const BorderSide(color: AppTheme.brandBlue, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bell icon of the headers: opens the notification inbox, with an unread badge.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = PushNotificationService.instance.unreadCount.value;
      return IconButton(
        tooltip: 'Notifications',
        onPressed: () => Get.toNamed(AppRoutes.notifications),
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 26),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppTheme.danger,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
