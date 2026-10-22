import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import '../quick_flow_controller.dart';
import 'package:delivery_boy/presentation/widgets/app_design.dart';

class QuickSummaryView extends GetView<QuickFlowController> {
  const QuickSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summaryData = controller.rxQuickSummary.value;
      if (summaryData == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummaryTable(summaryData),
            const SizedBox(height: 24),
            _buildCollectionDetailsCard(summaryData),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      );
    });
  }

  Widget _buildOrderSummaryTable(Map<String, dynamic> data) {
    final orderTypeWise = data['order_type_wise'] ?? {};
    final all = orderTypeWise['all'] ?? {};

    final dispatch = (all['dispatch'] ?? 0).toString();
    final success = (all['success'] ?? 0).toString();
    final failed = (all['failed'] ?? 0).toString();
    final rate = '${all['success_rate_percent'] ?? 0}%';

    void navigate(String status, String countValue) {
      if ((int.tryParse(countValue) ?? 0) > 0) {
        Get.toNamed(AppRoutes.summaryList, arguments: {
          'isQuick': true,
          'category': 'ALL',
          'status': status,
        });
      }
    }

    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: _summaryTile(Icons.inventory_2_outlined, AppTheme.brandBlue,
                dispatch, 'Total', () => navigate('DISPATCH', dispatch)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryTile(Icons.check_rounded, AppTheme.success, success,
                'Success', () => navigate('SUCCESS', success)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryTile(Icons.close_rounded, AppTheme.danger, failed,
                'Failed', () => navigate('FAILED', failed)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _summaryTile(Icons.rocket_launch_outlined,
                const Color(0xFF5E4BDB), rate, 'Performance', null),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(IconData icon, Color color, String value, String label,
      VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionDetailsCard(Map<String, dynamic> data) {
    double toNum(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;
    final cash = toNum(data['cash_value']);
    final online = toNum(data['online_value']);
    final maxValue = cash > online ? cash : online;

    Widget bar(String label, double value, Color color) {
      final fraction = maxValue <= 0 ? 0.0 : (value / maxValue);
      return Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("\u20B9${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)}",
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink)),
            const SizedBox(height: 4),
            Container(
              height: 10 + 100 * fraction,
              margin: const EdgeInsets.symmetric(horizontal: 36),
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Collection Details",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 14),
              _buildVerticalMetricItem(
                "Total Collection",
                "\u20B9${data['total_collection_amount'] ?? 0}",
                AppTheme.brandBlue,
                Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 12),
              _buildVerticalMetricItem(
                "Cash Collection",
                "\u20B9${data['cash_value'] ?? 0}",
                AppTheme.success,
                Icons.payments_outlined,
              ),
              const SizedBox(height: 12),
              _buildVerticalMetricItem(
                "Online Collection",
                "\u20B9${data['online_value'] ?? 0}",
                const Color(0xFF5E4BDB),
                Icons.credit_card_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Collection Overview",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  _legendDot(AppTheme.success, 'Cash'),
                  const SizedBox(width: 12),
                  _legendDot(AppTheme.brandBlue, 'Online'),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 170,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    bar('Cash', cash, AppTheme.success),
                    bar('Online', online, AppTheme.brandBlue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
      ],
    );
  }

  Widget _buildVerticalMetricItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
