import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    // The splash artwork (logo, title, progress bar, skyline, truck) is one image.
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/bg_splash.png',
          fit: BoxFit.cover,
          alignment: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
