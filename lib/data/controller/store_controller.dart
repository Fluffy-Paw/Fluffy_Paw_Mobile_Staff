import 'dart:io';

import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/data/repositories/store_provider.dart';
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
  Future<bool> createStore({
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
      state = true;
      
      final response = await ref.read(storeProvider).createStore(
        operatingLicense: operatingLicense,
        name: name,
        phone: phone,
        address: address,
        userName: userName,
        password: password,
        confirmPassword: confirmPassword,
        email: email,
        certificates: certificates,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await getAllStores(); // Refresh stores list
        state = false;
        return true;
      }

      state = false;
      return false;
    } catch (e) {
      state = false;
      debugPrint('Error creating store: $e');
      rethrow;
    }
  }
}

final storeController = StateNotifierProvider<StoreController, bool>(
  (ref) => StoreController(ref),
);