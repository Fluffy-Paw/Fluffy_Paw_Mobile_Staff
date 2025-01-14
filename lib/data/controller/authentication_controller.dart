import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/models/authentication/settings.dart';
import 'package:fluffypawsm/data/models/authentication/signup_model.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/repositories/auth_service_provider.dart';
import 'package:fluffypawsm/data/repositories/firebase_service.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthenticationController extends StateNotifier<bool> {
  late final Ref ref;

  AuthenticationController(this.ref) : super(false);

  late Settings _settings;

  // Future<bool> getSettingsInfo() async {
  //   try {
  //     final response = await ref.read(authServiceProvider).settings();
  //     _settings = Settings.fromMap(response.data['data']);
  //     return true;
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     return false;
  //   }
  // }
  // login
  Future<bool> login(
      {required String contact, required String password}) async {
    try {
      state = true;
      final response = await ref
          .read(authServiceProvider)
          .login(contact: contact, password: password);

      if (response.statusCode != 200) {
        state = false;
        return false;
      }

      final accessToken = response.data['data'] as String;

      // Làm sạch token trước khi decode
      final cleanToken = accessToken.trim().replaceAll(RegExp(r'\s+'), '');

      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(cleanToken);
        String? role = decodedToken[
            "http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];

        if (role == "PetOwner") {
          state = false;
          return false;
        }

        // Lưu token và xử lý theo role
        await ref
            .read(hiveStoreService)
            .saveUserAuthToken(authToken: cleanToken);

        if (role == "StoreManager") {
          ref.read(apiClientProvider).updateToken(token: accessToken);
          await ref.read(profileController.notifier).getProfile();
          state = false;
          return true;
        } else {
          ref.read(apiClientProvider).updateToken(token: accessToken);
          await ref.read(profileController.notifier).getAccountDetails();
          ref.read(dashboardController.notifier).getDashboardInfo();
          state = false;
          return true;
        }
      } catch (e) {
        debugPrint("JWT decode error: $e");
        state = false;
        return false;
      }
    } catch (e) {
      debugPrint("Login error: $e");
      state = false;
      return false;
    }
  }

  Future<bool> registration({
    required SignUpModel signUpModel,
    required XFile businessLicense,
    required XFile frontId,
    required XFile backId,
    required XFile logo,
  }) async {
    try {
      state = true;

      final response = await ref.read(authServiceProvider).registration(
            userName: signUpModel.userName,
            fullName: signUpModel.fullName,
            password: signUpModel.password,
            confirmPassword: signUpModel.confirmPassword,
            email: signUpModel.email,
            name: signUpModel.storeName,
            mst: signUpModel.mst,
            address: signUpModel.address,
            hotline: signUpModel.hotline,
            brandEmail: signUpModel.brandEmail,
            businessLicense: businessLicense,
            front: frontId,
            back: backId,
            logo: logo,
          );

      if (response.statusCode != 200) {
        state = false;
        return false;
      }

      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }

  Future<Map<String, dynamic>> sendOTP({required String mobile}) async {
    try {
      state = true;
      // Format the phone number to international format if needed
      String formattedNumber =
          mobile.startsWith('+') ? mobile : '+84${mobile.substring(1)}';

      final result =
          await firebaseAuthService.verifyPhoneNumber(formattedNumber);

      return result;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    } finally {
      state = false;
    }
  }

  Future<Map<String, dynamic>> verifyOTP({required String otp}) async {
    try {
      state = true;
      final result = await firebaseAuthService.verifyOTP(otp);

      if (result['success']) {
        // Set đúng provider để verify phone number
        ref.read(isPhoneNumberVerified.notifier).state = true;
        print('Phone number verified: ${ref.read(isPhoneNumberVerified)}');
      }

      return result;
    } catch (e) {
      print('OTP verification error: $e');
      return {'success': false, 'message': e.toString()};
    } finally {
      state = false;
    }
  }
  Future<bool> forgotPassword({
    required String phoneNumber,
    required String newPassword,
  }) async {
    try {
      state = true;
      final response = await ref.read(authServiceProvider).forgotPassword(
            phoneNumber: phoneNumber,
            newPassword: newPassword,
          );

      if (response.statusCode != 200) {
        state = false;
        return false;
      }
      
      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      throw Exception('Có lỗi xảy ra khi đổi mật khẩu: ${e.toString()}');
    }
  }
}

final authController = StateNotifierProvider<AuthenticationController, bool>(
    (ref) => AuthenticationController(ref));
