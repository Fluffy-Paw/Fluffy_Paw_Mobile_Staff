import 'dart:convert';
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
        );
  }

  Future<Response> getAllServiceTypes() async {
    try {
      final response = await ref.read(apiClientProvider).get(
            'https://fluffypaw.azurewebsites.net/api/ServiceType/GetAllServiceType',
          );
      return response;
    } catch (e) {
      debugPrint('Error in getAllServiceTypes: $e');
      rethrow;
    }
  }

  // In service_brand_provider.dart
  Future<Response> updateService(FormData data, int id) async {
    return ref.read(apiClientProvider).patch(
          '${AppConstants.updateService}/$id',
          data: data,
        );
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
    final response = await ref
        .read(apiClientProvider)
        .delete('${AppConstants.deleteCertificate}/$id');
    return response;
  }
}

final serviceServiceProvider = Provider((ref) => ServiceServiceProvider(ref));
