import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/models/profile/store_manager.dart';
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

  Future<void> getProfile() async {
    try {
      final response =
          await ref.read(profileServiceProvider).getStoreManagerInfo();

      if (response.statusCode == 200) {
        final profile = StoreManagerProfileModel.fromMap(response.data['data']);
        //state = profile;

        // Save to Hive storage
        await ref.read(hiveStoreService).saveUserInfo(userInfo: profile);
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      rethrow;
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? avatar,
  }) async {
    try {
      state = true;
      final response =
          await ref.read(profileServiceProvider).updateStoreManagerProfile(
                fullName: fullName,
                email: email,
                avatar: avatar,
              );

      if (response.statusCode == 200) {
        await getProfile();
        state = false;
        return true;
      }
      state = false;
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      state = false;
      return false;
    }
  }
}

final profileController = StateNotifierProvider<ProfileController, bool>(
    (ref) => ProfileController(ref));
