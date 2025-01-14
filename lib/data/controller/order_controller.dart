import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/dashboard_service_provider.dart';
import 'package:fluffypawsm/data/repositories/order_service_provider.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class OrderController extends StateNotifier<bool> {
  final Ref ref;
  OrderController(this.ref) : super(false);
  DashboardInfo? _dashboard;

  DashboardInfo? get dashboard => _dashboard;

  // Hàm helper để update status counts
  Future<void> _updateStatusCounts() async {
    if (_dashboard != null) {
      // Đếm lại số lượng từ danh sách orders hiện tại
      final Map<String, int> currentCounts =
          _countOrdersByStatus(_dashboard!.orders);

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
      // Lấy token từ Hive
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token != null) {
        // Decode token để lấy role
        final decodedToken = JwtDecoder.decode(token);
        final role = decodedToken["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
        
        // Kiểm tra nếu là StoreManager thì return false
        if (role == "StoreManager") {
          debugPrint('StoreManager không có quyền truy cập getOrderListWithFilter');
          return false;
        }
      }

      state = true;
      final response =
          await ref.read(orderServiceProvider).getOrderListWithFilter(status);

      switch (response.statusCode) {
        case 200:
          // Parse response data
          final dashboardData = DashboardInfo.fromMap(response.data);

          // Sort orders by createDate
          final sortedOrders = List<Order>.from(dashboardData.orders)
            ..sort((a, b) => b.createDate.compareTo(a.createDate));

          // Create new dashboard with sorted orders
          _dashboard = dashboardData.copyWith(orders: sortedOrders);

          // Update pending orders if needed
          if (status == 'Pending') {
            ref.read(dashboardPendingOrdersProvider.notifier).state =
                _dashboard?.orders ?? [];
            print('Pending orders updated: ${_dashboard?.orders.length}');
          }

          // Update status counts
          await _updateStatusCounts();

          state = false;
          return true;

        case 404:
          _dashboard = DashboardInfo.empty();
          if (status == 'Pending') {
            ref.read(dashboardPendingOrdersProvider.notifier).state = [];
          }
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

  Future<Order?> searchOrderById(String bookingId) async {
    try {
      state = true;
      if (_dashboard?.orders == null) return null;

      // Chuyển bookingId sang số để so sánh
      final searchId = bookingId;
      if (searchId == null) return null;

      // Tìm kiếm trong danh sách orders hiện tại
      final order = _dashboard!.orders.firstWhere(
        (order) => order.code == searchId,
        orElse: () => null as Order, // Thay đổi cách xử lý orElse
      );

      state = false;
      return order;
    } catch (e) {
      debugPrint('Error searching order: $e');
      state = false;
      return null;
    }
  }

  Future<void> saveRecentSearch(String bookingId) async {
    try {
      final recentSearches =
          await ref.read(hiveStoreService).getRecentSearches() ?? [];
      if (!recentSearches.contains(bookingId)) {
        recentSearches.insert(0, bookingId);
        if (recentSearches.length > 5) {
          recentSearches.removeLast();
        }
        await ref.read(hiveStoreService).saveRecentSearches(recentSearches);
      }
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  Future<List<String>> getRecentSearches() async {
    try {
      return await ref.read(hiveStoreService).getRecentSearches() ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  Future<void> refreshAllOrderCounts() async {
    try {
      ref.read(isLoadingCountsProvider.notifier).state = true;

      // Đếm từ danh sách orders hiện tại nếu có
      if (_dashboard != null) {
        final counts = _countOrdersByStatus(_dashboard!.orders);

        // Cập nhật state
        ref.read(orderCountsProvider.notifier).state = counts;

        // Lưu vào Hive
        await ref.read(hiveStoreService).saveOrderStatuses(
              acceptedOrders: counts['Accepted'] ?? 0,
              pendingOrders: counts['Pending'] ?? 0,
              canceledOrders: counts['Canceled'] ?? 0,
              deniedOrders: counts['Denied'] ?? 0,
              overTimeOrders: counts['OverTime'] ?? 0,
              endedOrders: counts['Ended'] ?? 0,
            );

        debugPrint('Updated order counts from dashboard: $counts');
      } else {
        // Nếu chưa có dashboard data, load từ API
        final response =
            await ref.read(dashboardServiceProvider).getDashboardInfo();

        if (response.statusCode == 200 && response.data != null) {
          // Parse dashboard info
          _dashboard = DashboardInfo.fromMap(response.data);

          // Đếm số lượng orders theo status
          final counts = _countOrdersByStatus(_dashboard!.orders);

          // Cập nhật state
          ref.read(orderCountsProvider.notifier).state = counts;

          // Lưu vào Hive
          await ref.read(hiveStoreService).saveOrderStatuses(
                acceptedOrders: counts['Accepted'] ?? 0,
                pendingOrders: counts['Pending'] ?? 0,
                canceledOrders: counts['Canceled'] ?? 0,
                deniedOrders: counts['Denied'] ?? 0,
                overTimeOrders: counts['OverTime'] ?? 0,
                endedOrders: counts['Ended'] ?? 0,
              );

          debugPrint('Updated order counts from API: $counts');
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Error refreshing order counts: $e');
      debugPrint('Stack trace: $stackTrace');

      // Nếu có lỗi, load từ cache
      try {
        final cachedCounts =
            await ref.read(hiveStoreService).getOrderStatuses();
        final counts = {
          'Accepted': cachedCounts[AppConstants.acceptedOrders] ?? 0,
          'Pending': cachedCounts[AppConstants.pendingOrders] ?? 0,
          'Canceled': cachedCounts[AppConstants.canceledOrders] ?? 0,
          'Denied': cachedCounts[AppConstants.deniedOrders] ?? 0,
          'OverTime': cachedCounts[AppConstants.overTimeOrders] ?? 0,
          'Ended': cachedCounts[AppConstants.endedOrders] ?? 0,
        };
        ref.read(orderCountsProvider.notifier).state = counts;
        debugPrint('Loaded counts from cache: $counts');
      } catch (e) {
        debugPrint('Error loading from cache: $e');
      }
    } finally {
      ref.read(isLoadingCountsProvider.notifier).state = false;
    }
  }

  Future<void> updateOrderStatusCount(String status) async {
    try {
      final currentCounts = ref.read(orderCountsProvider);
      final currentCount = currentCounts[status] ?? 0;
      final updatedCount = currentCount + 1;

      // Cập nhật state ngay lập tức
      ref.read(orderCountsProvider.notifier).state = {
        ...currentCounts,
        status: updatedCount,
      };

      // Lưu vào Hive
      switch (status) {
        case 'Pending':
          await ref.read(hiveStoreService).updateOrderStatus(
                AppConstants.pendingOrders,
                updatedCount,
              );
          break;
        case 'Accepted':
          await ref.read(hiveStoreService).updateOrderStatus(
                AppConstants.acceptedOrders,
                updatedCount,
              );
          break;
        // Thêm các case khác tương tự
      }
    } catch (e) {
      print('Error updating order status count: $e');
    }
  }

  void updateCountForStatus(String status, int count) {
    final currentCounts = ref.read(orderCountsProvider);
    ref.read(orderCountsProvider.notifier).state = {
      ...currentCounts,
      status: count,
    };
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
        await ref
            .read(dashboardController.notifier)
            .getDashboardInfo(); // Refresh dashboard data
        await _updateStatusCounts(); // Update status counts
        state = false;
        return true;
      } else {
        debugPrint(
            'Failed to deny booking with status code: ${response.statusCode}');
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
