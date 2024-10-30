import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/dashboard_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardService implements DashboardProvider {
  final Ref ref;
  DashboardService(this.ref);

  @override
  Future<Response> getDashboardInfo() async {
    final response = await ref.read(apiClientProvider).get(
      AppConstants.dashboardInfo,
    );
    return response;
  }
}
final dashboardServiceProvider = Provider((ref) => DashboardService(ref));