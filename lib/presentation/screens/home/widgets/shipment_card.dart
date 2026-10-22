import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/external_actions.dart';
import '../../../../data/models/order_model.dart';

/// Maps the order status or delivery type to the internal category label.
String _resolveCategory(OrderModel shipment) {
  final type = (shipment.orderType ?? '').toLowerCase();
  switch (type) {
    case 'rvp':
    case 'reverse':
    case 'reverse_pickup':
      return 'RVP';
    case 'rt':
    case 'return':
      return 'RT';
    case 'fm':
    case 'first_mile':
    case 'firstmile':
      return 'FM';
    case 'normal':
    case 'fwd':
    case 'forward':
      return 'FWD';
    default:
      return type.isNotEmpty ? type.toUpperCase() : 'FWD';
  }
}

/// Navigate to the correct flow screen based on order category.
void _navigateToFlow(OrderModel shipment) {
  final category = _resolveCategory(shipment);
  switch (category) {
    case 'RVP':
      Get.toNamed(AppRoutes.rvpFlow, arguments: shipment);
      break;
    case 'RT':
      Get.toNamed(AppRoutes.rtFlow, arguments: shipment);
      break;
    case 'FM':
      Get.toNamed(AppRoutes.fmFlow, arguments: shipment);
      break;
    case 'FWD':
    default:
      // Pass the whole model as argument
      Get.toNamed(AppRoutes.orderDetails, arguments: shipment);
      break;
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'RVP':
      return Colors.orange;
    case 'RT':
      return Colors.purple;
    case 'FM':
      return Colors.teal;
    case 'FWD':
    default:
      return AppColors.primary;
  }
}

class ShipmentCard extends StatelessWidget {
  final OrderModel shipment;
  final bool navigateOnTap;
  final String? forcedStatus;
  final Color? forcedColor;
  final bool showActions;
  final bool isQuick;

  const ShipmentCard({
    super.key,
    required this.shipment,
    this.navigateOnTap = true,
    this.forcedStatus,
    this.forcedColor,
    this.showActions = true,
    this.isQuick = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final category = _resolveCategory(shipment);
    final catColor = _categoryColor(category);
    final uiOrderType = (shipment.orderType ?? '').toUpperCase();

    final customerName = shipment.customer?.name ?? 'Customer';
    final orderNumber = shipment.orderNumber ?? '-';
    final paymentMethod = (shipment.paymentMethod ?? 'online').toUpperCase();
    final paymentStatus = (shipment.paymentStatus ?? 'paid').toUpperCase();
    final totalAmount = shipment.totalAmount;
    final phone = shipment.customer?.mobile ?? '';

    // address
    final addr = shipment.deliveryAddress;
    String addressText = '';
    if (addr != null) {
      final parts = [
        addr.addressLine1,
        addr.addressLine2,
        addr.area?.name,
        addr.city?.name,
        addr.state?.name,
        addr.pincode,
      ].where((e) => e != null && e.toString().isNotEmpty).toList();
      addressText = parts.join(', ');
    }

    final lat = shipment.deliveryAddress?.latitude ?? 0.0;
    final lng = shipment.deliveryAddress?.longitude ?? 0.0;
    final isCod = paymentMethod == 'COD';

    final amountValue = totalAmount ?? 0;
    final amountText = '\u20B9${amountValue % 1 == 0 ? amountValue.toInt().toString() : amountValue.toStringAsFixed(2)}';
    final paymentLabel = isCod ? 'COD' : 'Prepaid';
    final pillText =
        forcedStatus != null ? '$category - $forcedStatus' : uiOrderType;
    final pillColor = forcedColor ?? catColor;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: navigateOnTap ? () => _navigateToFlow(shipment) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.08),
              offset: const Offset(0, 5),
              blurRadius: 14,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE7FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: Color(0xFF5E4BDB), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: TextStyle(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '#$orderNumber',
                        style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: width * 0.032),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pillColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    pillText,
                    style: TextStyle(
                      color: pillColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    addressText.isNotEmpty
                        ? addressText
                        : 'Address not available',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                if (showActions) ...[
                  _ActionButton(
                    icon: Icons.phone,
                    label: 'Call',
                    color: Colors.green,
                    onTap: () => ExternalActions.makeCall(phone),
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    icon: Icons.navigation_outlined,
                    label: 'Navigate',
                    color: Colors.blue,
                    onTap: () => ExternalActions.openMap(lat, lng),
                  ),
                ],
                const Spacer(),
                if (category == 'FWD' && !isQuick)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isCod ? amountText : 'Paid',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        paymentLabel,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bg, border, textColor;
  const _Badge(
      {required this.label,
      required this.bg,
      required this.border,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border),
      ),
      child: Text(label,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
