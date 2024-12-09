import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:fluffypawsm/data/models/service/service_type_model.dart';
import 'package:fluffypawsm/data/repositories/service_brand_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceController extends StateNotifier<bool> {
  final Ref ref;
  List<ServiceModel>? _services;
  List<ServiceModel>? get services => _services;
  List<ServiceTypeModel>? _serviceTypes;
  List<ServiceTypeModel>? get serviceTypes => _serviceTypes;
  bool _loadingServiceTypes = false;
  bool get loadingServiceTypes => _loadingServiceTypes;

  ServiceController(this.ref) : super(false);

  Future<void> getAllServices() async {
    try {
      state = true;
      final response = await ref.read(serviceServiceProvider).getAllServices();
      _services = ServiceModel.fromMapList(response.data['data']);
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting services: $e');
      rethrow;
    }
  }

  List<ServiceModel> getServicesByType(int typeId) {
    return _services
            ?.where((service) => service.serviceTypeId == typeId)
            .toList() ??
        [];
  }

  List<ServiceModel> getServicesByBrand(int brandId) {
    return _services?.where((service) => service.brandId == brandId).toList() ??
        [];
  }

  ServiceModel? getServiceById(int id) {
    return _services?.firstWhere(
      (service) => service.id == id,
      orElse: () => throw Exception('Service not found'),
    );
  }

  // In ServiceController class
  Future<int?> createService({
    required int serviceTypeId,
    required String name,
    required File image,
    required Duration duration,
    required double cost,
    required String description,
  }) async {
    try {
      state = true;
      FormData formData = FormData.fromMap({
        'ServiceTypeId': serviceTypeId.toString(),
        'Name': name,
        'Duration': duration.toString(),
        'Cost': cost.toString(),
        'Description': description,
        'Image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      final response =
          await ref.read(serviceServiceProvider).createService(formData);
      await getAllServices(); // Refresh services list after creation
      state = false;

      if (response.statusCode == 200) {
        // Assuming the response contains the created service ID in data
        return response.data['data']['id'] as int;
      }
      return null;
    } catch (e) {
      state = false;
      debugPrint('Error creating service: $e');
      return null;
    }
  }

  Future<bool> updateService({
  required int id,
  required int serviceTypeId, 
  required String name,
  required File? image,
  required String duration,
  required double cost,
  required String description,
}) async {
  try {
    state = true;
    FormData formData = FormData.fromMap({
      'ServiceTypeId': serviceTypeId.toString(),
      'Name': name,
      'Duration': duration,
      'Cost': cost.toString(), 
      'Description': description,
    });

    if (image != null) {
      formData.files.add(
        MapEntry(
          'Image',
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    final response = await ref.read(serviceServiceProvider).updateService(formData, id);
    await getAllServices(); // Refresh services list after update
    state = false;

    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    return false;

  } catch (e) {
    state = false;
    debugPrint('Error updating service: $e');
    rethrow;
  }
}

  Future<List<Certificate>> getCertificatesByServiceId(int serviceId) async {
    try {
      state = true;
      final response = await ref
          .read(serviceServiceProvider)
          .getCertificatesByServiceId(serviceId);
      state = false;
      if (response.statusCode == 200) {
        return Certificate.fromMapList(response.data['data']);
      }
      return [];
    } catch (e) {
      state = false;
      debugPrint('Error getting certificates: $e');
      return [];
    }
  }

  Future<bool> createCertificate({
    required int serviceId,
    required File certificateFile,
    required String title,
    required String description,
  }) async {
    try {
      state = true;
      FormData formData = FormData.fromMap({
        'ServiceId': serviceId.toString(),
        'Name': title,
        'Description': description,
        'File': await MultipartFile.fromFile(
          certificateFile.path,
          filename: certificateFile.path.split('/').last,
        ),
      });

      final response =
          await ref.read(serviceServiceProvider).createCertificate(formData);
      if (response.statusCode == 200) {
        await getAllServices(); // Refresh all services first
      }
      state = false;
      return response.statusCode == 200;
    } catch (e) {
      state = false;
      debugPrint('Error creating certificate: $e');
      return false;
    }
  }

  Future<bool> deleteCertificate(int certificateId) async {
    try {
      state = true;
      final response = await ref
          .read(serviceServiceProvider)
          .deleteCertificate(certificateId);
      if (response.statusCode == 200) {
        await getAllServices(); // Refresh all services first
      }
      state = false;
      return response.statusCode == 200;
    } catch (e) {
      state = false;
      debugPrint('Error deleting certificate: $e');
      return false;
    }
  }

  Future<void> getAllServiceTypes() async {
    try {
      _loadingServiceTypes = true;
      state = true;
      final response =
          await ref.read(serviceServiceProvider).getAllServiceTypes();
      if (response.statusCode == 200) {
        _serviceTypes = ServiceTypeModel.fromMapList(response.data['data']);
      }
      _loadingServiceTypes = false;
      state = false;
    } catch (e) {
      _loadingServiceTypes = false;
      state = false;
      debugPrint('Error getting service types: $e');
      rethrow;
    }
  }

  ServiceTypeModel? getServiceTypeById(int id) {
    return _serviceTypes?.firstWhere(
      (type) => type.id == id,
      orElse: () => throw Exception('Service type not found'),
    );
  }
}

final serviceController = StateNotifierProvider<ServiceController, bool>(
  (ref) => ServiceController(ref),
);
