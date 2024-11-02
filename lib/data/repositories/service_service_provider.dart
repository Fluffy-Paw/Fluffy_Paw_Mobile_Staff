import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/domain/repositories/service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ServiceServiceProvider implements ServiceProvider {
  final Ref ref;

  ServiceServiceProvider(this.ref);

  @override
Future<Response> createStoreService({
  required CreateStoreServiceRequest request
}) async {
  final response = await ref.read(apiClientProvider).post(
    AppConstants.createStoreService,
    data: request.toJson(),
    
  );
  return response;
}

  @override
  Future<Response> deleteStoreService(int id) async {
    final response = await ref.read(apiClientProvider).delete(
      '${AppConstants.deleteStoreService}/$id'
    );
    return response;
  }

  @override
  Future<Response> getAllStoreService(int storeId) async{
    // TODO: implement getAllStoreService
    final response = await ref.read(apiClientProvider).get(
      '${AppConstants.getStoreServiceForStaffbyStoreId}/$storeId'
    );
    return response;
  }

  @override
  Future<Response> updateStoreService(int id, DateTime startTime, int limitPetOwner) async{
    final response = await ref.read(apiClientProvider).patch(
      '${AppConstants.updateStoreService}/$id',
      data: {
        'startTime': startTime,
        'limitPetOwner': limitPetOwner
      }
    );
    return response;
  }

  @override
  Future<Response> getAllStoreServiceByServiceId(int serviceId) async{
    // TODO: implement getAllStoreServiceByServiceId
    final response = await ref.read(apiClientProvider).get(
      '${AppConstants.getAllStoreServiceByServiceId}/$serviceId'
    );
    return response;
  }
}

final storeServiceProvider = Provider((ref) => ServiceServiceProvider(ref));
