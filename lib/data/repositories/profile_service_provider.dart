import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/data/models/profile/store_manager.dart';
import 'package:fluffypawsm/domain/repositories/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService implements ProfileProvider {
  final Ref ref;

  ProfileService(this.ref);
  @override
  Future<Response> getAccountDetails() async {
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getAccountDetails);
    return response;
  }

  Future<Response> getStoreManagerInfo() async {
    final response = await ref.read(apiClientProvider).get(
          AppConstants.getStoreManagerInfo,
        );
    return response;
  }

  Future<Response> updateStoreManagerProfile({
    String? fullName,
    String? email,
    String? avatar,
  }) async {
    final formData = FormData.fromMap({
      'FullName': fullName,
      'Email': email,
      if (avatar != null) 'Avatar': await MultipartFile.fromFile(avatar),
    });

    return await ref.read(apiClientProvider).patch(
          AppConstants.updateStoreManagerProfile,
          data: formData,
        );
  }

  Future<Response> updateStaff({
    required String id,
    required FormData data,
  }) async {
    return await ref.read(apiClientProvider).patch(
        '${AppConstants.baseUrl}/api/StoreManager/UpdateStaff/$id',
        data: data);
  }
}

final profileServiceProvider = Provider((ref) => ProfileService(ref));
