import 'package:fluffypawsm/data/models/pet/pet_model.dart';
import 'package:fluffypawsm/data/repositories/pet_detail_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PetDetailController extends StateNotifier<AsyncValue<PetDetail>> {
  final Ref ref;
  final int petId;

  PetDetailController(this.ref, this.petId) : super(const AsyncValue.loading()) {
    getPetDetail();
  }

  Future<void> getPetDetail() async {
    try {
      state = const AsyncValue.loading();
      final response = await ref.read(petDetailServiceProvider).getPetDetail(petId);
      final petDetail = PetDetail.fromMap(response.data['data']);
      state = AsyncValue.data(petDetail);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      debugPrint('Error getting pet detail: $e');
    }
  }
}

final petDetailControllerProvider = StateNotifierProvider.family<PetDetailController, AsyncValue<PetDetail>, int>(
  (ref, petId) => PetDetailController(ref, petId),
);