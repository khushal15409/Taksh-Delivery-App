import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';

class ExternalActions {
  static Future<void> makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('Error', 'Could not launch dialer');
    }
  }

  static Future<void> openMap(double lat, double lng) async {
    final String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    final Uri uri = Uri.parse(googleUrl);
    
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) Get.snackbar('Error', 'Could not launch maps');
    } catch (_) {
      Get.snackbar('Error', 'Could not launch maps');
    }
  }
}
