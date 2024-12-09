import 'package:dio/dio.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/controller/store_controller.dart';
import 'package:fluffypawsm/data/repositories/profile_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountController extends StateNotifier<bool> {
 final Ref ref;
 AccountController(this.ref) : super(false);

 Future<bool> updateStaff({
   required String id,
   String? password,
   String? confirmPassword, 
   String? email,
 }) async {
   try {
     state = true;
     
     final formData = FormData.fromMap({
       'Password': password,
       'ConfirmPassword': confirmPassword,
       'Email': email
     });

     final response = await ref.read(profileServiceProvider).updateStaff(
       id: id,
       data: formData
     );

     if (response.statusCode == 200) {
       await ref.read(storeController.notifier).getAllStores();
       state = false;
       return true;
     }

     state = false;
     return false;

   } catch (e) {
     debugPrint('Update staff error: $e');
     state = false;
     return false;
   }
 }
}

final accountController = StateNotifierProvider<AccountController, bool>(
 (ref) => AccountController(ref)
);