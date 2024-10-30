import 'dart:io';

import 'package:dio/dio.dart';

abstract class AuthProvider {
  Future<Response> login({required String contact, required String password});
  // Future<Response> registration({
  //   required SignUpModel signUpModel,
  //   required File profile,
  //   required File shopLogo,
  //   required File shopBanner,
  // });
  // Future<Response> sendOTP({required String mobile});
  // Future<Response> verifyOTP({required String mobile, required String otp});
 //Future<Response> settings();
}