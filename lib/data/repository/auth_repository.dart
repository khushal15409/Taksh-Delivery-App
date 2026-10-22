import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../core/error/failure.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository({required this.apiClient});

  Future<Map<String, dynamic>> sendOtp(String mobileNumber) async {
    return await apiClient.postMultipart(
      AppConstants.sendOtpEndpoint,
      fields: {'mobile_number': mobileNumber},
    );
  }

  Future<UserModel> verifyOtp(String mobileNumber, String otp) async {
    final response = await apiClient.postMultipart(
      AppConstants.verifyOtpEndpoint,
      fields: {
        'mobile_number': mobileNumber,
        'otp': otp,
      },
    );

    if (response['success'] == true) {
      final data = response['data'];
      final hasToken = data is Map &&
          (data['token'] != null ||
              (data['delivery_man'] is Map &&
                  data['delivery_man']['token'] != null));
      if (!hasToken) {
        // The OTP is valid but there is no login: the number is not registered
        // yet or the registration is still pending approval. Stay on the OTP
        // screen with a clear message instead of entering the app without a token.
        final registered = data is Map && data['can_register'] != true;
        throw AppException(registered
            ? (data['message']?.toString() ??
                'Your registration is pending approval.')
            : 'This mobile number is not registered as a delivery partner.');
      }
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } else {
      throw AppException(response['message'] ?? 'Verification Failed');
    }
  }

  Future<void> logout(String token) async {
    await apiClient.post(AppConstants.logoutEndpoint, token: token);
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    return await apiClient.post(
      AppConstants.registrationEndpoint,
      body: data,
    );
  }
}
