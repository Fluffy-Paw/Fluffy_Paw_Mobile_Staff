import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/data/models/service/store_service.dart';
import 'package:fluffypawsm/data/repositories/service_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceController extends StateNotifier<bool>{
  final Ref ref;

  List<Service>? services;
  List<StoreService>? listTimeService;
  StoreService? currentService;
  ServiceController(this.ref) : super(false);

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
      
      // Parse response và lưu vào services
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
}


final serviceController = StateNotifierProvider<ServiceController, bool>((ref) => ServiceController(ref));