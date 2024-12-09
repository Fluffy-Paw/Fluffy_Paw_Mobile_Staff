import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreProvider {
  final Ref ref;

  StoreProvider(this.ref);

  Future<Response> createStore({
    required File operatingLicense,
    required String name,
    required String phone,
    required String address,
    required String userName,
    required String password,
    required String confirmPassword,
    required String email,
    required List<File> certificates,
  }) async {
    try {
      final formData = FormData.fromMap({
        'OperatingLicense': await MultipartFile.fromFile(
          operatingLicense.path,
          filename: operatingLicense.path.split('/').last,
        ),
        'Name': name,
        'Phone': phone,
        'Address': address,
        'UserName': userName,
        'Password': password,
        'ConfirmPassword': confirmPassword,
        'Email': email,
      });

      // Add certificates if any
      for (var file in certificates) {
        formData.files.add(
          MapEntry(
            'File',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) throw Exception('Authentication token not found');

      return ref.read(apiClientProvider).post(
        AppConstants.createStore,
        data: formData,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );
    } catch (e) {
      debugPrint('Error in createStore: $e');
      rethrow;
    }
  }
}

final storeProvider = Provider((ref) => StoreProvider(ref));
