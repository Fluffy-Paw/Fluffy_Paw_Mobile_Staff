import 'package:dio/src/response.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileService implements ProfileProvider{
  final Ref ref;

  ProfileService(this.ref);
  @override
  Future<Response> getAccountDetails() async{
    final response =
        await ref.read(apiClientProvider).get(AppConstants.getAccountDetails);
    return response;
  }

}

final profileServiceProvider = Provider((ref) => ProfileService(ref));