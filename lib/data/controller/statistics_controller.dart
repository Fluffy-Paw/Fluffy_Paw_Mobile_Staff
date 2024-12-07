import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/static/statistics_model.dart';
import 'package:fluffypawsm/data/repositories/statistics_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsController extends StateNotifier<bool> {
  final Ref ref;
  Statistics? _statistics;
  Statistics? get statistics => _statistics;

  StatisticsController(this.ref) : super(false);

  Future<void> getStatistics() async {
    try {
      state = true;
      final response = await ref.read(statisticsServiceProvider).getStatistics();
      _statistics = Statistics.fromMap(response.data['data']);
      //await ref.read(hiveStoreService).saveStatistics(statistics: _statistics!);
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting statistics: ${e.toString()}');
      rethrow;
    }
  }
}

final statisticsController = StateNotifierProvider<StatisticsController, bool>(
  (ref) => StatisticsController(ref),
);