import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/settings/settings_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../widgets/app_design.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Obx(() {
        if (controller.isLoading && controller.user.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.user.value;

        return SingleChildScrollView(
          child: Column(
            children: [
              AppHeaderBox(
                radius: 40,
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 26),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                        Expanded(
                          child: Text(
                            AppStrings.profile,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: controller.updateProfilePicture,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: const Color(0xFFC8E4FF),
                              backgroundImage: user?.profilePhoto != null
                                  ? NetworkImage(user!.profilePhoto!)
                                  : const AssetImage(
                                          'assets/images/avatar_rider.png')
                                      as ImageProvider,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_camera_outlined,
                                  size: 18, color: AppTheme.brandBlue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? AppStrings.profile,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppStrings.appName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Profile Data List
              Container(
                margin: EdgeInsets.symmetric(horizontal: width * 0.05),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                        icon: Icons.person,
                        label: AppStrings.name,
                        value: user?.name ?? "N/A"),
                    _ProfileDivider(),
                    _ProfileRow(
                        icon: Icons.phone,
                        label: AppStrings.mobile,
                        value: user?.mobileNumber ?? "N/A"),
                    _ProfileDivider(),
                    _ProfileRow(
                        icon: Icons.email,
                        label: AppStrings.email,
                        value: user?.email ?? "N/A"),
                    _ProfileDivider(),
                    _ProfileRow(
                        icon: Icons.location_on,
                        label: AppStrings.address,
                        value: user?.address ?? "N/A"),
                    _ProfileDivider(),

                    // Language Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.language,
                              color: AppTheme.brandBlue, size: 22),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              AppStrings.language,
                              style: const TextStyle(
                                  color: AppTheme.ink,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          Row(
                            children: [
                              _LanguageOption(
                                label: "EN",
                                isSelected: Get.locale?.languageCode == 'en',
                                onTap: () =>
                                    Get.updateLocale(const Locale('en', 'US')),
                              ),
                              const SizedBox(width: 8),
                              _LanguageOption(
                                label: "HI",
                                isSelected: Get.locale?.languageCode == 'hi',
                                onTap: () =>
                                    Get.updateLocale(const Locale('hi', 'IN')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              // Logout Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                child: InkWell(
                  onTap: controller.logout,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF5252), Color(0xFFE53935)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.danger.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.logout,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.brandBlue, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
                color: AppTheme.ink, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  color: AppTheme.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
        height: 1, color: Colors.grey.shade100, indent: 20, endIndent: 20);
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
