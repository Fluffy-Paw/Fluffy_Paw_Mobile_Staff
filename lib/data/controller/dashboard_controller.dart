import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/dashboard_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardController extends StateNotifier<bool> {
  final Ref ref;
  DashboardInfo? _dashboard;

  DashboardController(this.ref) : super(false);

  DashboardInfo? get dashboard => _dashboard ?? DashboardInfo.empty();

  Future<bool> getDashboardInfo() async {
    try {
      state = true;

      final response = await ref.read(dashboardServiceProvider).getDashboardInfo();
      
      if (response.statusCode == 200) {
        // Handle empty data case
        if (response.data == null || (response.data['data'] as List).isEmpty) {
          _dashboard = DashboardInfo.empty();
        } else {
          _dashboard = DashboardInfo.fromMap(response.data);
        }

        // Save order statuses even if they're all zero
        await ref.read(hiveStoreService).saveOrderStatuses(
          acceptedOrders: _dashboard!.acceptedOrders,
          pendingOrders: _dashboard!.pendingOrders,
          canceledOrders: _dashboard!.canceledOrders,
          deniedOrders: _dashboard!.deniedOrders,
          overTimeOrders: _dashboard!.overTimeOrders,
          endedOrders: _dashboard!.endedOrders,
        );

        state = false;
        return true;
      }

      state = false;
      return false;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      // Don't remove token on dashboard error
      // Instead return empty dashboard
      _dashboard = DashboardInfo.empty();
      return false;
    }
  }
}

final dashboardController = StateNotifierProvider<DashboardController, bool>(
  (ref) => DashboardController(ref),
);
