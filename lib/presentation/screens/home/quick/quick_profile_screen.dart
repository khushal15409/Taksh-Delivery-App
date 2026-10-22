import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/home/quick/quick_flow_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/presentation/widgets/app_design.dart';

class QuickProfileScreen extends GetView<QuickFlowController> {
  const QuickProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Obx(() {
        final profile = controller.userProfile.value;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

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
                        const Expanded(
                          child: Text(
                            "Profile",
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
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => controller.updateProfilePicture(),
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
                              backgroundImage: profile.profilePhoto != null
                                  ? NetworkImage(profile.profilePhoto!)
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(profile.name ?? "Field Executive",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              Text("ID: TKSH-Q-${profile.id ?? '001'}",
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              _buildProfileItem(Icons.phone, "Mobile Number",
                  profile.mobileNumber.isNotEmpty ? profile.mobileNumber : "N/A"),
              _buildProfileItem(Icons.email, "Email",
                  profile.email.isNotEmpty ? profile.email : "N/A"),
              _buildProfileItem(Icons.location_on, "Operating City",
                  profile.city ?? "N/A"),
              _buildProfileItem(Icons.directions_bike, "Vehicle Type",
                  profile.vehicleType ?? "N/A"),
              _buildProfileItem(Icons.numbers, "Vehicle Number",
                  profile.vehicleNumber ?? "N/A"),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => controller.confirmLogout(),
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("LOGOUT",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text("App Version 2.3.0",
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}
