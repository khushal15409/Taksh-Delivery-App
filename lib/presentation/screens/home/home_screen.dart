import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import 'home_controller.dart';
import 'summary/summary_view.dart';
import 'widgets/shipment_card.dart';
import '../../widgets/app_design.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        body: Obx(() => controller.rxIndex.value == 0
            ? Column(
                children: [
                  _buildHeader(context, controller),
                  // Search Bar
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(width * 0.04, 16, width * 0.04, 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1565C0).withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      autofocus: false,
                      onChanged: (value) =>
                          controller.rxSearchText.value = value,
                      decoration: InputDecoration(
                        hintText: "Search by name or tracking ID...",
                        hintStyle: const TextStyle(
                            color: AppTheme.muted, fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.muted),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        suffixIcon:
                            Obx(() => controller.rxSearchText.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 20),
                                    onPressed: () {
                                      controller.rxSearchText.value = "";
                                    },
                                  )
                                : const SizedBox.shrink()),
                      ),
                    ),
                  ),

                  // Filter Tabs
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                        horizontal: width * 0.04, vertical: 10),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: "All (${controller.rxTotalCount.value})",
                          isSelected:
                              controller.rxSelectedFilter.value == "All",
                          onTap: () => controller.selectFilter("All"),
                        ),
                        _FilterChip(
                          label: "FWD",
                          isSelected:
                              controller.rxSelectedFilter.value == "FWD",
                          onTap: () => controller.selectFilter("FWD"),
                        ),
                        _FilterChip(
                          label: "RVP",
                          isSelected:
                              controller.rxSelectedFilter.value == "RVP",
                          onTap: () => controller.selectFilter("RVP"),
                        ),
                        _FilterChip(
                          label: "RT",
                          isSelected: controller.rxSelectedFilter.value == "RT",
                          onTap: () => controller.selectFilter("RT"),
                        ),
                        _FilterChip(
                          label: "FM",
                          isSelected: controller.rxSelectedFilter.value == "FM",
                          onTap: () => controller.selectFilter("FM"),
                        ),
                      ],
                    ),
                  ),

                  // Shipment List
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () =>
                          controller.fetchOrders(showLoadingIndicator: false),
                      child: controller.isLoading
                          ? _buildShimmerList(width)
                          : controller.filteredShipments.isEmpty
                              ? EmptyOrdersView(onRefresh: () {
                                  controller.fetchOrders(
                                      showLoadingIndicator: true);
                                  controller.fetchSummary();
                                })
                              : ListView.builder(
                                  controller: controller.scrollController,
                                  padding: EdgeInsets.all(width * 0.04),
                                  itemCount: controller
                                          .filteredShipments.length +
                                      (controller.isFetchingMore.value ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        controller.filteredShipments.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 20.0),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
                                    return ShipmentCard(
                                        shipment: controller
                                            .filteredShipments[index]);
                                  },
                                ),
                    ),
                  ),
                ],
              )
            : const SummaryView()),
        bottomNavigationBar: Obx(() => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
                child: BottomNavigationBar(
                  currentIndex: controller.rxIndex.value,
                  onTap: controller.changeTabIndex,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  selectedItemColor: AppTheme.brandBlue,
                  unselectedItemColor: AppTheme.muted,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.bold),
                  items: [
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.inventory_2_outlined),
                      activeIcon: const Icon(Icons.inventory_2),
                      label: AppStrings.shipments,
                    ),
                    BottomNavigationBarItem(
                      icon: const Icon(Icons.assignment_outlined),
                      activeIcon: const Icon(Icons.bar_chart_rounded),
                      label: AppStrings.summary,
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    const months = [
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
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dateStr =
        '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

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
                child: Image.asset('assets/images/rider.png', height: 102),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting, 👋',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.rxDeliveryManName.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )),
                        const SizedBox(height: 6),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white),
                    onPressed: () {
                      controller.fetchOrders(showLoadingIndicator: true);
                      controller.fetchSummary();
                    },
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.settings),
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
          Obx(() => Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.inventory_2_outlined,
                      color: AppTheme.brandBlue,
                      value: twoDigits(controller.rxHeaderDispatch.value),
                      label: 'Total Dispatch',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.check_rounded,
                      color: AppTheme.success,
                      value: twoDigits(controller.rxHeaderSuccess.value),
                      label: 'Total Success',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.close_rounded,
                      color: AppTheme.danger,
                      value: twoDigits(controller.rxHeaderFailed.value),
                      label: 'Total Failed',
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    showAppConfirmDialog(
      icon: Icons.logout_rounded,
      title: AppStrings.exitApp,
      message: AppStrings.exitMessage,
      yesText: AppStrings.yes,
      noText: AppStrings.no,
      onYes: () => SystemNavigator.pop(),
    );
  }

  Widget _buildShimmerList(double width) {
    return ListView.builder(
      padding: EdgeInsets.all(width * 0.04),
      itemCount: 5,
      itemBuilder: (context, index) => _ShimmerCard(width: width),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final double width;
  const _ShimmerCard({required this.width});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _shimmerBox(widget.width * 0.4, 20),
                  _shimmerBox(widget.width * 0.2, 20),
                ],
              ),
              const SizedBox(height: 12),
              _shimmerBox(widget.width * 0.3, 14),
              const SizedBox(height: 16),
              Row(
                children: [
                  _shimmerBox(20, 20),
                  const SizedBox(width: 8),
                  _shimmerBox(widget.width * 0.5, 12),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(40, 10),
                      const SizedBox(height: 6),
                      _shimmerBox(80, 16),
                    ],
                  ),
                  Row(
                    children: [
                      _shimmerBox(40, 40),
                      const SizedBox(width: 12),
                      _shimmerBox(40, 40),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
            Colors.grey.shade200,
          ],
          stops: [
            0.0,
            0.5 + (_animation.value / 4),
            1.0,
          ],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandBlue : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
