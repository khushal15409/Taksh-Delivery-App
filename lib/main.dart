import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:delivery_boy/core/constants/app_constants.dart';
import 'package:delivery_boy/core/constants/app_routes.dart';
import 'package:delivery_boy/core/constants/app_strings.dart';
import 'package:delivery_boy/core/services/push_notification_service.dart';
import 'package:delivery_boy/core/localization/app_translations.dart';
import 'package:delivery_boy/presentation/bindings/initial_binding.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('--- APP START startup: VERSION SYNC CHECK 2.3.0 ---');
  await GetStorage.init();
  // Never throws: when Firebase is not configured for the build, push is simply off.
  await PushNotificationService.instance.initialize();
  _initConnectivity();
  runApp(const MyApp());
}

Timer? _offlineTimer;

void _initConnectivity() {
  InternetConnectionChecker().onStatusChange.listen((status) {
    if (status == InternetConnectionStatus.disconnected) {
      // The probe can flap (blocked probe addresses, brief signal loss). Showing the
      // no-internet screen for it steals focus from text fields and hides the
      // current screen, so only show it once the connection is confirmed lost.
      _offlineTimer?.cancel();
      _offlineTimer = Timer(const Duration(seconds: 5), () async {
        if (await _isReallyOffline() &&
            Get.currentRoute != AppRoutes.noInternet) {
          Get.toNamed(AppRoutes.noInternet);
        }
      });
    } else {
      _offlineTimer?.cancel();
      if (Get.currentRoute == AppRoutes.noInternet) {
        Get.back();
      }
    }
  });
}

Future<bool> _isReallyOffline() async {
  try {
    if (await InternetConnectionChecker().hasConnection) return false;
    // Our own API host is what the app actually needs.
    final host = Uri.parse(AppConstants.baseUrl).host;
    final result =
        await InternetAddress.lookup(host).timeout(const Duration(seconds: 5));
    return result.isEmpty;
  } catch (_) {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
