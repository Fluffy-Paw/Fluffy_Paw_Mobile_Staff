import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/data/repositories/store_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreController extends StateNotifier<bool> {
  final Ref ref;
  List<StoreModel>? _stores;
  List<StoreModel>? get stores => _stores;

  StoreController(this.ref) : super(false);

  Future<void> getAllStores() async {
    try {
      state = true;
      final response = await ref.read(storeServiceProvider).getAllStores();
      _stores = StoreModel.fromMapList(response.data['data']);
      // if (_stores != null) {
      //   await ref.read(hiveStoreService).saveStoreInfo(stores: _stores!);
      // }
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting store list: ${e.toString()}');
      rethrow;
    }
  }
}

final storeController = StateNotifierProvider<StoreController, bool>(
  (ref) => StoreController(ref),
);