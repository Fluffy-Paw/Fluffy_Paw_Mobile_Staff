import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StoreProvider {
  Future<Response> getAllStores();
}

class StoreServiceProvider implements StoreProvider {
  final Ref ref;

  StoreServiceProvider(this.ref);

  @override
  Future<Response> getAllStores() async {
    final response = await ref.read(apiClientProvider).get(AppConstants.getAlStoreSM);
    return response;
  }
}

final storeServiceProvider = Provider((ref) => StoreServiceProvider(ref));