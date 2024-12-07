import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:fluffypawsm/data/models/service/store_service.dart';
import 'package:fluffypawsm/data/repositories/service_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceController extends StateNotifier<bool> {
  final Ref ref;

  List<Service>? services;
  List<StoreService>? listTimeService;
  List<ServiceModel>? _servicesBrand;
  List<ServiceModel>? get servicesBrand => _servicesBrand;
  StoreService? currentService;
  
  ServiceController(this.ref) : super(false);

  Future<void> getAllServiceByBrandId() async {
    try {
      state = true;
      // Get user info for brandId
      final userInfo = await ref.read(hiveStoreService).getUserInfo();
      if (userInfo == null) {
        state = false;
        return;
      }

      // Load cached data first if available
      final cachedServices = await ref.read(hiveStoreService).getServices();
      if (cachedServices != null) {
        _servicesBrand = cachedServices;
        state = false;
      }

      // Fetch new data from API
      final response = await ref.read(storeServiceProvider).getAllServiceByBrandId(userInfo.brandId);
      final newServices = ServiceModel.fromMapList(response.data['data']);
      
      // Update cache and state with new data
      if (newServices.isNotEmpty) {
        await ref.read(hiveStoreService).saveServices(services: newServices);
        _servicesBrand = newServices;
      }
      
      state = false;
    } catch (e) {
      debugPrint('Error getting services: ${e.toString()}');
      state = false;
    }
  }

  Future<void> refreshServices() async {
    try {
      state = true;
      final userInfo = await ref.read(hiveStoreService).getUserInfo();
      if (userInfo == null) {
        state = false;
        return;
      }

      final response = await ref.read(storeServiceProvider).getAllServiceByBrandId(userInfo.brandId);
      final newServices = ServiceModel.fromMapList(response.data['data']);
      
      if (newServices.isNotEmpty) {
        await ref.read(hiveStoreService).saveServices(services: newServices);
        _servicesBrand = newServices;
      }
      
      state = false;
    } catch (e) {
      debugPrint('Error refreshing services: ${e.toString()}');
      state = false;
    }
  }

  // Other existing methods remain the same
  Future<StoreServiceResponse?> createStoreService({
    required CreateStoreServiceRequest request
  }) async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).createStoreService(
        request: request
      );
      final result = StoreServiceResponse.fromMap(response.data);
      state = false;
      return result;
    } catch (e) {
      state = false;
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> deleteStoreService(int id) async {
    try {
      state = true;
      await ref.read(storeServiceProvider).deleteStoreService(id);
      state = false;
      return true;
    } catch (e) {
      state = false;
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> getAllStoreServices(int storeId) async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getAllStoreService(storeId);
      
      final responseData = response.data as Map<String, dynamic>;
      if (responseData['data'] != null) {
        services = (responseData['data'] as List<dynamic>)
            .map((item) => Service.fromMap(item as Map<String, dynamic>))
            .toList();
      }
      
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting store services: ${e.toString()}');
    }
  }

  Future<bool> updateStoreService({
    required int id,
    required DateTime startTime,
    required int limitPetOwner
  }) async {
    try {
      state = true;
      await ref.read(storeServiceProvider).updateStoreService(
        id,
        startTime,
        limitPetOwner
      );
      state = false;
      return true;
    } catch (e) {
      state = false;
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> getAllStoreServiceByServiceId(int serviceId) async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getAllStoreServiceByServiceId(serviceId);
      
      final responseData = response.data as Map<String, dynamic>;
      final storeServices = StoreServiceResponse.fromMap(responseData);
      
      listTimeService = storeServices.data;
      if (listTimeService?.isNotEmpty == true) {
        currentService = listTimeService!.first;
      }
      
      state = false;
    } catch (e) {
      debugPrint('Error getting store services: ${e.toString()}');
      state = false;
    }
  }
  bool isServiceExistsInBranch(int serviceId) {
    return services?.any((s) => s.id == serviceId) ?? false;
  }
}

final serviceController = StateNotifierProvider<ServiceController, bool>(
  (ref) => ServiceController(ref)
);