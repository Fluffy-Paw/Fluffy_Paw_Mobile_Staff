import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  Future<Response> registration({
    required String userName,
    required String fullName,
    required String password,
    required String confirmPassword,
    required String email,
    required String name,
    required String mst,
    required String address,
    required String hotline,
    required String brandEmail,
    required XFile businessLicense,
    required XFile front,
    required XFile back,
    required XFile logo,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'UserName': userName,
        'FullName': fullName,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'Email': email,
        'Name': name,
        'MST': mst,
        'Address': address,
        'Hotline': hotline,
        'BrandEmail': brandEmail,
        'BusinessLicense': await MultipartFile.fromFile(businessLicense.path,
            filename: 'business_license.png'),
        'Front':
            await MultipartFile.fromFile(front.path, filename: 'front_id.png'),
        'Back':
            await MultipartFile.fromFile(back.path, filename: 'back_id.png'),
        'Logo': await MultipartFile.fromFile(logo.path, filename: 'logo.png'),
      });

      final response = await ref.read(apiClientProvider).post(
        'https://fluffypaw.azurewebsites.net/api/Authentication/RegisterSM',
        data: formData,
        headers: {
          'accept': '*/*',
          'Content-Type': 'multipart/form-data',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final authServiceProvider = Provider((ref) => AuthService(ref));
