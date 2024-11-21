import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/order_service_provider.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderController extends StateNotifier<bool> {
  final Ref ref;
  OrderController(this.ref) : super(false);
  DashboardInfo? _dashboard;

  DashboardInfo? get dashboard => _dashboard;

  // Hàm helper để update status counts
  Future<void> _updateStatusCounts() async {
    if (_dashboard != null) {
      // Đếm lại số lượng từ danh sách orders hiện tại
      final Map<String, int> currentCounts = _countOrdersByStatus(_dashboard!.orders);
      
      // Lưu vào Hive với số lượng đã đếm
      await ref.read(hiveStoreService).saveOrderStatuses(
        acceptedOrders: currentCounts['Accepted'] ?? 0,
        pendingOrders: currentCounts['Pending'] ?? 0,
        canceledOrders: currentCounts['Canceled'] ?? 0,
        deniedOrders: currentCounts['Denied'] ?? 0,
        overTimeOrders: currentCounts['OverTime'] ?? 0,
        endedOrders: currentCounts['Ended'] ?? 0,
      );
      
      // Debug log để kiểm tra
      debugPrint('Updated order counts: $currentCounts');
    }
  }
  Map<String, int> _countOrdersByStatus(List<Order> orders) {
    final Map<String, int> counts = {
      'Accepted': 0,
      'Pending': 0, 
      'Canceled': 0,
      'Denied': 0,
      'OverTime': 0,
      'Ended': 0
    };
    
    for (var order in orders) {
      if (counts.containsKey(order.status)) {
        counts[order.status] = (counts[order.status] ?? 0) + 1;
      }
    }
    return counts;
  }

  Future<bool> getOrderListWithFilter(String status) async {
    try {
      state = true;
      final response = await ref.read(orderServiceProvider).getOrderListWithFilter(status);
      
      switch (response.statusCode) {
        case 200:
          _dashboard = DashboardInfo.fromMap(response.data);
          
          // Cập nhật danh sách pending orders nếu đang ở tab Pending
          if (status == 'Pending') {
            ref.read(pendingOrdersProvider.notifier).state = _dashboard?.orders ?? [];
          }
          
          // Cập nhật số lượng trong Hive
          await _updateStatusCounts();
          
          // Debug log
          final hiveCounts = await ref.read(hiveStoreService).getOrderStatuses();
          debugPrint('Hive counts after update: $hiveCounts');
          
          state = false;
          return true;
          
        case 404:
          _dashboard = DashboardInfo.empty();
          await _updateStatusCounts();
          state = false;
          return true;
          
        default:
          debugPrint('Unexpected status code: ${response.statusCode}');
          state = false;
          return false;
      }
    } catch (e) {
      debugPrint('Error in getOrderListWithFilter: ${e.toString()}');
      state = false;
      return false;
    }
  }
  Future<void> refreshAllOrderCounts() async {
    try {
      final response = await ref.read(orderServiceProvider).getAllOrders();
      if (response.statusCode == 200) {
        final dashboardInfo = DashboardInfo.fromMap(response.data);
        final Map<String, int> counts = _countOrdersByStatus(dashboardInfo.orders);
        
        // Lưu vào Hive
        await ref.read(hiveStoreService).saveOrderStatuses(
          acceptedOrders: counts['Accepted'] ?? 0,
          pendingOrders: counts['Pending'] ?? 0,
          canceledOrders: counts['Canceled'] ?? 0,
          deniedOrders: counts['Denied'] ?? 0,
          overTimeOrders: counts['OverTime'] ?? 0,
          endedOrders: counts['Ended'] ?? 0,
        );

        // Cập nhật state provider
        ref.read(orderCountsProvider.notifier).state = counts;
        
        // Debug log
        debugPrint('Updated counts: $counts');
      }
    } catch (e) {
      debugPrint('Error refreshing counts: $e');
    }
  }

  Future<bool> acceptBooking(int id) async {
    try {
      state = true;
      final response = await ref.read(orderServiceProvider).acceptBooking(id);
      if (response.statusCode == 200) {
        // Refresh toàn bộ counts
        await refreshAllOrderCounts();
        // Refresh current list
        await getOrderListWithFilter(ref.read(selectedOrderStatus));
        state = false;
        return true;
      }
      state = false;
      return false;
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
