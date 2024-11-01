import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/order_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderController extends StateNotifier<bool> {
  final Ref ref;
  OrderController(this.ref) : super(false);
  DashboardInfo? _dashboard;

  DashboardInfo? get dashboard => _dashboard;

  // Hàm helper để update status counts
  Future<void> _updateStatusCounts() async {
    final currentCounts = await ref.read(hiveStoreService).getOrderStatuses();
    
    // Lấy số lượng mới từ dashboard hiện tại
    if (_dashboard != null) {
      await ref.read(hiveStoreService).saveOrderStatuses(
        acceptedOrders: _dashboard!.acceptedOrders,
        pendingOrders: _dashboard!.pendingOrders,
        canceledOrders: _dashboard!.canceledOrders,
        deniedOrders: _dashboard!.deniedOrders,
        overTimeOrders: _dashboard!.overTimeOrders,
        endedOrders: _dashboard!.endedOrders,
      );
    }
  }

  Future<bool> getOrderListWithFilter(String status) async {
    try {
      state = true;
      final response =
          await ref.read(orderServiceProvider).getOrderListWithFilter(status);
      switch (response.statusCode) {
        case 200:
          _dashboard = DashboardInfo.fromMap(response.data);
      if (status == 'Pending') {
        ref.read(pendingOrdersProvider.notifier).state = _dashboard?.orders ?? [];
      }
      await _updateStatusCounts();
      state = false;
      return true;
          
        case 404:
          _dashboard = DashboardInfo.empty();
          await _updateStatusCounts(); // Update status counts ngay cả khi không có data
          state = false;
          return true;
          
        default:
          debugPrint('Unexpected status code: ${response.statusCode}');
          state = false;
          return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }

  Future<bool> acceptBooking(int id) async {
    try {
      state = true;
      final response = await ref.read(orderServiceProvider).acceptBooking(id);
      if (response.statusCode == 200) {
        // Update status counts sau khi accept thành công
        await getOrderListWithFilter('Pending'); // Refresh pending list
        await ref.read(dashboardController.notifier).getDashboardInfo(); // Refresh dashboard data
        await _updateStatusCounts(); // Update status counts
        state = false;
        return true;
      } else {
        debugPrint('Failed to accept booking with status code: ${response.statusCode}');
        state = false;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }

  Future<bool> deniedBooking(int id) async {
    try {
      state = true;
      final response = await ref.read(orderServiceProvider).deniedBooking(id);
      if (response.statusCode == 200) {
        // Update status counts sau khi deny thành công
        await getOrderListWithFilter('Pending'); // Refresh pending list
        await ref.read(dashboardController.notifier).getDashboardInfo(); // Refresh dashboard data
        await _updateStatusCounts(); // Update status counts
        state = false;
        return true;
      } else {
        debugPrint('Failed to deny booking with status code: ${response.statusCode}');
        state = false;
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      return false;
    }
  }
}

final orderController =
StateNotifierProvider<OrderController, bool>((ref) => OrderController(ref));
final pendingOrdersProvider = StateProvider<List<Order>>((ref) => []);
// final orderStatusController =
// StateNotifierProvider<OrderStatusController, bool>(
//       (ref) => OrderStatusController(ref),
// );
