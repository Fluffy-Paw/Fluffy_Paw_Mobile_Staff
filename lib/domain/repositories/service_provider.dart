import 'package:dio/dio.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';

abstract class ServiceProvider {
  Future<Response> createStoreService({
    required CreateStoreServiceRequest request,
  });
  Future<Response> updateStoreService(int id, DateTime startTime, int limitPetOwner);
  Future<Response> deleteStoreService(int id);
  Future<Response> getAllStoreService(int storeId);
  Future<Response> getAllStoreServiceByServiceId(int serviceId);
  Future<Response> getAllServiceByBrandId(int brandId);
  
}
