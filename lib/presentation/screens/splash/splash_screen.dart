import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg_splash.png',
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 5),
                Image.asset(
                  'assets/images/logo_clean.png',
                  width: width * 0.68,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width * 0.098,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.brandBlue,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: width * 0.62,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.05, end: 0.95),
                    duration: const Duration(seconds: 3),
                    builder: (context, value, _) => ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFD6E6FA),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1976D2)),
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 8),
                const Text(
                  'People. Deliveries. Progress.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.deepBlue,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Together with Taksh',
                  style: TextStyle(fontSize: 13, color: AppTheme.muted),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
