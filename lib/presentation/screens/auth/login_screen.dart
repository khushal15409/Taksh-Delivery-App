import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:delivery_boy/presentation/screens/auth/auth_controller.dart';
import 'package:delivery_boy/core/constants/app_colors.dart';
import 'package:delivery_boy/core/constants/app_strings.dart';
import 'package:delivery_boy/presentation/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header artwork: logo card, title, tagline and the delivery rider.
                  Image.asset(
                    'assets/images/login_top.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.07, 0, width * 0.07, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.login,
                          style: TextStyle(
                            fontSize: width * 0.08,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.welcome,
                          style: TextStyle(
                            fontSize: width * 0.04,
                            color: AppTheme.muted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCE7F5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: controller.mobileController,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: const InputDecoration(
                              counterText: "",
                              hintText: "Enter Mobile Number",
                              prefixIcon: Icon(Icons.phone_android_outlined,
                                  color: AppColors.primary),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Obx(() => CustomButton(
                              text: AppStrings.sendOtp,
                              trailingIcon: Icons.arrow_forward_rounded,
                              isLoading: controller.isLoading,
                              isEnabled: controller.isMobileValid.value,
                              onPressed: controller.sendOtp,
                            )),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Footer artwork: paper plane, pin and tagline.
                  Image.asset(
                    'assets/images/login_footer.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
