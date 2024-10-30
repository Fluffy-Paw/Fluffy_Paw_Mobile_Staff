import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/repositories/profile_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileController extends StateNotifier<bool> {
  final Ref ref;
  ProfileController(this.ref) : super(false);


  // get acccount details
  Future<void> getAccountDetails() async {
    try {
      final response =
          await ref.read(profileServiceProvider).getAccountDetails();
      final userInfo = User.fromMap(response.data['data']);
      ref.read(hiveStoreService).saveUserInfo(userInfo: userInfo);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

}

final profileController = StateNotifierProvider<ProfileController, bool>(
    (ref) => ProfileController(ref));