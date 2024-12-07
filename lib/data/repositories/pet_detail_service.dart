import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


abstract class PetDetailServiceBase {
  Future<Response> getPetDetail(int id);
}

class PetDetailService implements PetDetailServiceBase {
  final Ref ref;

  PetDetailService(this.ref);

  @override
  Future<Response> getPetDetail(int id) async {
    try {
      final response = await ref.read(apiClientProvider).get(
            '${AppConstants.getPetById}/$id',
          );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}

final petDetailServiceProvider = Provider((ref) => PetDetailService(ref));