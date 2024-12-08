import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ServiceServiceProvider {
  final Ref ref;

  ServiceServiceProvider(this.ref);

  Future<Response> getAllServices() async {
    try {
      final response =
          await ref.read(apiClientProvider).get(AppConstants.getAllServiceBySM);
      return response;
    } catch (e) {
      debugPrint('Error in getAllServices: $e');
      rethrow;
    }
  }

  Future<Response> createService(FormData data) async {
    return ref.read(apiClientProvider).post(
      AppConstants.createService,
      data: data,
      headers: {
        'accept': '*/*',
        'Content-Type': 'multipart/form-data',
      },
    );
  }

  Future<Response> updateService({
  required int id,
  required int serviceTypeId,
  required String name,
  required File? image,
  required Duration duration,
  required double cost,
  required String description,
}) async {
  try {
    final token = await ref.read(hiveStoreService).getAuthToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    Map<String, dynamic> formMap = {
      'ServiceTypeId': serviceTypeId.toString(),
      'Name': name,
      'Duration': duration.toString(),
      'Cost': cost.toString(),
      'Description': description,
    };

    if (image != null && image.path.isNotEmpty) {
      String contentType;
      String extension = image.path.split('.').last.toLowerCase();
      
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        default:
          contentType = 'image/jpeg';
      }

      formMap['Image'] = await MultipartFile.fromFile(
        image.path,
        filename: image.path.split('/').last,
        contentType: DioMediaType.parse(contentType),
      );
    }

    final response = await ref.read(apiClientProvider).patch(
      '${AppConstants.updateService}/$id',
      data: formMap,
      headers: {
        'accept': '*/*',
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      },
    );

    return response;
  } catch (e) {
    debugPrint('Error in updateService: $e');
    rethrow;
  }
}
  Future<Response> createCertificate(FormData data) async {
    try {
        final token = await ref.read(hiveStoreService).getAuthToken();
        
        if (token == null) {
            throw Exception('Authentication token not found');
        }

        return ref.read(apiClientProvider).post(
            AppConstants.createCertificate,
            data: data,
            headers: {
                'accept': '*/*',
                'Content-Type': 'multipart/form-data',
                'Authorization': 'Bearer $token',
            },
        );
    } catch (e) {
        debugPrint('Error in createCertificate: $e');
        rethrow;
    }
}
  Future<Response> getCertificatesByServiceId(int serviceId) async {
    return ref.read(apiClientProvider).get(
      '${AppConstants.getCertificatesByServiceId}/$serviceId',
      
    );
  }
  Future<Response> deleteCertificate(int id) async {
    final response = await ref.read(apiClientProvider).delete(
      '${AppConstants.deleteCertificate}/$id'
    );
    return response;
  }
}

final serviceServiceProvider = Provider((ref) => ServiceServiceProvider(ref));
