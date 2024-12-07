import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class StatisticsProvider {
  Future<Response> getStatistics();
}

class StatisticsServiceProvider implements StatisticsProvider {
  final Ref ref;

  StatisticsServiceProvider(this.ref);

  @override
  Future<Response> getStatistics() async {
    final response = await ref.read(apiClientProvider).get(
      AppConstants.getStatisticsUrl,
    );
    return response;
  }
}

final statisticsServiceProvider = Provider((ref) => StatisticsServiceProvider(ref));