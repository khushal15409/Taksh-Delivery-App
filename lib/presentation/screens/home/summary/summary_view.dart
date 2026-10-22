import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/presentation/screens/home/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_design.dart';

class SummaryView extends StatelessWidget {
  const SummaryView({super.key});

  static const _categoryColors = {
    'ALL': Color(0xFF1976D2),
    'FWD': Color(0xFFD81B8C),
    'RVP': Color(0xFF2E9E4F),
    'FM': Color(0xFFE53935),
    'RT': Color(0xFFF9A825),
  };

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Column(
      children: [
        AppHeaderBox(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 26),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => controller.changeTabIndex(0),
              ),
              const Expanded(
                child: Text(
                  "Order Summary",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => controller.fetchSummary(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionCard(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
                    child: Obx(() {
                      if (controller.orderSummaryData.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Category Wise Summary',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildHeaderRow(),
                          _buildRow(controller, "ALL"),
                          _buildRow(controller, "FWD"),
                          _buildRow(controller, "RVP"),
                          _buildRow(controller, "FM"),
                          _buildRow(controller, "RT"),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 18),
                  _buildCollectionCard(controller),
                  const SizedBox(height: 18),
                  _buildSuccessRateCard(controller),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    Widget cell(String text, int flex) => Expanded(
          flex: flex,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.muted,
              fontSize: 12,
            ),
          ),
        );

    return Container(
      color: const Color(0xFFF3F7FC),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          cell("Category", 14),
          cell("Desp", 10),
          cell("Succ", 10),
          cell("Fail", 10),
          cell("Rate %", 12),
        ],
      ),
    );
  }

  Widget _buildRow(HomeController controller, String type) {
    final data = controller.orderSummaryData[type.toLowerCase()];
    if (data == null) return const SizedBox.shrink();

    final int dispatch = data['dispatch'] ?? 0;
    final int success = data['success'] ?? 0;
    final int failed = data['failed'] ?? 0;
    final dynamic rate = data['success_rate_percent'] ?? 0;
    final barColor = _categoryColors[type] ?? AppTheme.brandBlue;
    final isAll = type == 'ALL';

    return Container(
      color: isAll ? const Color(0xFFE8F1FD) : Colors.white,
      child: Row(
        children: [
          Container(width: 4, height: 50, color: barColor),
          Expanded(
            flex: 14,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(type,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink,
                      fontSize: 14)),
            ),
          ),
          _valueCell(dispatch, AppTheme.brandBlue, type, "DISPATCH", 10),
          _valueCell(success, AppTheme.success, type, "SUCCESS", 10),
          _valueCell(failed, AppTheme.danger, type, "FAILED", 10),
          Expanded(
            flex: 12,
            child: Text(
              "$rate%",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  Widget _valueCell(int value, Color color, String type, String status,
      int flex) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.summaryList, arguments: {
          'category': type,
          'status': status,
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            "$value",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionCard(HomeController controller) {
    return SectionCard(
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
          Row(
            children: [
              Expanded(
                child: _collectionTile("Total", controller.totalCollection,
                    AppTheme.brandBlue, Icons.account_balance_wallet_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _collectionTile("Cash", controller.cashValue,
                    AppTheme.success, Icons.payments_outlined),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _collectionTile("Online", controller.onlineValue,
                    const Color(0xFF5E4BDB), Icons.credit_card_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _collectionTile(
      String label, RxString value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 2),
          Obx(() => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "₹${value.value}",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.ink),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(HomeController controller) {
    return SectionCard(
      child: Obx(() {
        final all = controller.orderSummaryData['all'];
        final int dispatch = (all?['dispatch'] ?? 0) as int;
        final int success = (all?['success'] ?? 0) as int;
        final int failed = (all?['failed'] ?? 0) as int;
        final pending = (dispatch - success - failed) < 0
            ? 0
            : (dispatch - success - failed);
        final rate = all?['success_rate_percent'] ?? 0;

        Widget legend(Color color, String label, int value) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(label,
                      style: const TextStyle(
                          color: AppTheme.muted, fontSize: 14)),
                  const Spacer(),
                  Text("$value",
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.ink,
                          fontSize: 15)),
                ],
              ),
            );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Success Rate",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                DonutChart(
                  success: success.toDouble(),
                  failed: failed.toDouble(),
                  center: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$rate%",
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.ink)),
                      const Text("Success Rate",
                          style:
                              TextStyle(fontSize: 10, color: AppTheme.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      legend(AppTheme.success, "Success", success),
                      legend(AppTheme.danger, "Failed", failed),
                      legend(const Color(0xFFD9DFEA), "Pending", pending),
                      const Divider(height: 14),
                      Row(
                        children: [
                          const Text("Total",
                              style: TextStyle(
                                  color: AppTheme.muted, fontSize: 14)),
                          const Spacer(),
                          Text("$dispatch",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.ink,
                                  fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
