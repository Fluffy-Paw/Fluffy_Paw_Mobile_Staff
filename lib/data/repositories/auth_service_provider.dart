import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthService implements AuthProvider {
  final Ref ref;

  AuthService(this.ref);

  @override
  Future<Response> login(
      {required String contact, required String password}) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.loginUrl,
      data: {
        'username': contact,
        'password': password,
      },
    );
    return response;
  }

  // @override
  // Future<Response> registration(
  //     {required SignUpModel signUpModel,
  //       required File profile,
  //       required File shopLogo,
  //       required File shopBanner}) async {
  //   FormData formData = FormData.fromMap({
  //     'profile_photo': await MultipartFile.fromFile(
  //       profile.path,
  //       filename: 'profile_photo.jpg',
  //     ),
  //     'logo': await MultipartFile.fromFile(shopLogo.path,
  //         filename: 'shop_logo.jpg'),
  //     'banner': await MultipartFile.fromFile(shopBanner.path),
  //     ...signUpModel.toMap(),
  //   });
  //   final response = await ref.read(apiClientProvider).post(
  //     AppConstants.registrationUrl,
  //     data: formData,
  //   );
  //   return response;
  // }

  // @override
  // Future<Response> settings() async {
  //   final response =
  //   await ref.read(apiClientProvider).get(AppConstants.settings);
  //   return response;
  // }

  // @override
  // Future<Response> sendOTP({required String mobile}) async {
  //   final response =
  //   await ref.read(apiClientProvider).post(AppConstants.sendOTP, data: {
  //     'mobile': mobile,
  //   });
  //   return response;
  // }

  // @override
  // Future<Response> verifyOTP(
  //     {required String mobile, required String otp}) async {
  //   final response = await ref.read(apiClientProvider).post(
  //     AppConstants.verifyOtp,
  //     data: {
  //       'mobile': mobile,
  //       'otp': otp,
  //     },
  //   );
  //   return response;
  // }
}

final authServiceProvider = Provider((ref) => AuthService(ref));