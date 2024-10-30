import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/dashboard_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardController extends StateNotifier<bool> {
  final Ref ref;
  DashboardController(this.ref) : super(false);

  DashboardInfo? _dashboard;

  DashboardInfo? get dashboard => _dashboard;

  // login
  Future<bool> getDashboardInfo() async {
    try {
      state = true;
      final response =
      await ref.read(dashboardServiceProvider).getDashboardInfo();
      if(response.statusCode!=200){
        state = false;
        ref.read(hiveStoreService).removeUserAuthToken();
        return false;
      }

      _dashboard = DashboardInfo.fromMap(response.data);

      state = false;
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      rethrow;
    }
  }

}

final dashboardController = StateNotifierProvider<DashboardController, bool>(
        (ref) => DashboardController(ref));