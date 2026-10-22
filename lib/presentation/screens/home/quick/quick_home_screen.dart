import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delivery_boy/presentation/widgets/loading_overlay.dart';
import 'package:delivery_boy/presentation/widgets/app_design.dart';
import 'package:delivery_boy/presentation/screens/home/quick/widgets/quick_summary_view.dart';

class QuickHomeScreen extends GetView<QuickFlowController> {
  const QuickHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await controller.confirmAppExit();
      },
      child: LoadingOverlay(
        isLoading: controller.isLoadingRx,
        child: Obx(() => Scaffold(
              backgroundColor: AppTheme.surface,
              appBar: controller.selectedTabIndex.value == 1
                  ? AppBar(
                      backgroundColor: AppTheme.deepBlue,
                      elevation: 0,
                      centerTitle: true,
                      title: const Text(
                        "Order Summary",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
              body: Column(
                children: [
                  if (controller.selectedTabIndex.value == 0)
                    _buildHeader(context),
                  if (controller.selectedTabIndex.value == 0) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchBar(),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => controller.fetchOrders(),
                        child: Obx(() {
                          if (controller.filteredOrders.isEmpty) {
                            return _buildEmptyState();
                          }
                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: controller.filteredOrders.length,
                            itemBuilder: (context, index) {
                              final order = controller.filteredOrders[index];
                              return _buildOrderCard(order);
                            },
                          );
                        }),
                      ),
                    ),
                  ] else ...[
                    const Expanded(child: QuickSummaryView()),
                  ],
                ],
              ),
              bottomNavigationBar: _buildBottomNavigationBar(),
            )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeaderBox(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Positioned(
                right: 0,
                bottom: -4,
                child: Image.asset('assets/images/rider.png', height: 92),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                "Hello, ${controller.userProfile.value?.name?.split(' ').first ?? 'Quick Boy'} 👋",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 56),
                          ],
                        )),
                  ),
                  const NotificationBell(),
                  GestureDetector(
                    onTap: () => controller.goToProfile(),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person,
                            color: AppTheme.deepBlue, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => StatCard(
                    color: AppTheme.brandBlue,
                    value: twoDigits(controller.totalOrders.value),
                    label: 'Total')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => StatCard(
                    color: AppTheme.success,
                    value: twoDigits(controller.totalSuccess.value),
                    label: 'Success')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() => StatCard(
                    color: AppTheme.danger,
                    value: twoDigits(controller.totalFailed.value),
                    label: 'Failed')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Material(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(15),
        child: TextField(
          controller: controller.searchController,
          focusNode: controller.searchFocusNode,
          autofocus: false,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: "Search by Tracking ID...",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF0D47A1)),
            suffixIcon: Obx(() => controller.isSearchLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(strokeWidth: 2)))
                : controller.searchText.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () => controller.searchController.clear(),
                      )
                    : const SizedBox.shrink()),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return "${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}";
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final vendor = order['vendor'] as Map<String, dynamic>?;

    final name = vendor?['name'] ?? 'Vendor/Customer';
    final orderNumber = order['tracking_id'] ?? '-';
    final address = vendor?['address'] ?? 'Address not available';
    final phone = vendor?['mobile'] ?? '';

    final paymentData = order['payment'] ?? {};
    final orderData = order['order'] ?? {};
    final paymentStatus = (order['payment_status'] ??
            orderData['payment_status'] ??
            paymentData['payment_status'] ??
            '')
        .toString()
        .trim()
        .toLowerCase();

    bool isCod = false;
    if (paymentStatus == 'paid' ||
        paymentStatus == 'success' ||
        paymentStatus == 'online') {
      isCod = false;
    } else {
      final method = (order['payment_method'] ??
              orderData['payment_method'] ??
              paymentData['payment_method'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();
      if (method.contains('online') ||
          method.contains('razorpay') ||
          method.contains('prepaid') ||
          method.contains('upi')) {
        isCod = false;
      } else {
        isCod = method == 'cod' || method.contains('cash');
      }
    }

    final paymentAmount = order['total_payable'] ??
        order['total_amount'] ??
        paymentData['amount'] ??
        '0.00';
    final paymentType = isCod ? "COD" : "PREPAID";

    return InkWell(
      onTap: () => controller.goToDetails(order),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "PICKUP",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                '#$orderNumber',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _QuickButton(
                  icon: Icons.phone,
                  onTap: () => launchUrl(Uri.parse("tel:$phone")),
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _QuickButton(
                  icon: Icons.navigation_outlined,
                  onTap: () => launchUrl(Uri.parse(
                      "https://www.google.com/maps/search/?api=1&query=$address")),
                  color: Colors.blue,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      paymentType,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCod ? Colors.orange : Colors.green,
                      ),
                    ),
                    Text(
                      "₹ $paymentAmount",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyOrdersView(onRefresh: () => controller.fetchOrders());
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BottomNavigationBar(
          currentIndex: controller.selectedTabIndex.value,
          onTap: (index) => controller.changeTab(index),
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppTheme.brandBlue,
          unselectedItemColor: AppTheme.muted,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Product',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Summary',
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _QuickButton(
      {required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
