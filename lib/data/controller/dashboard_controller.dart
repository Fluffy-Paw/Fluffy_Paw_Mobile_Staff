import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/dashboard_service_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardController extends StateNotifier<bool> {
  final Ref ref;
  DashboardInfo? _dashboard;

  DashboardController(this.ref) : super(false);

  DashboardInfo? get dashboard => _dashboard;

  // Lấy thông tin Dashboard từ API và lưu vào Hive
  Future<bool> getDashboardInfo() async {
    try {
      state = true; // Đặt state thành true khi bắt đầu tải dữ liệu

      // Gọi API để lấy thông tin dashboard
      final response = await ref.read(dashboardServiceProvider).getDashboardInfo();
      
      // Kiểm tra phản hồi từ API
      if (response.statusCode != 200) {
        state = false; 
        // Nếu không thành công, xóa token và trả về false
        ref.read(hiveStoreService).removeUserAuthToken();
        return false;
      }

      // Chuyển đổi dữ liệu từ response thành DashboardInfo
      _dashboard = DashboardInfo.fromMap(response.data);

      // Lưu trữ các trạng thái đơn hàng vào Hive thông qua HiveService
      await ref.read(hiveStoreService).saveOrderStatuses(
        acceptedOrders: _dashboard!.acceptedOrders,
        pendingOrders: _dashboard!.pendingOrders,
        canceledOrders: _dashboard!.canceledOrders,
        deniedOrders: _dashboard!.deniedOrders,
        overTimeOrders: _dashboard!.overTimeOrders,
        endedOrders: _dashboard!.endedOrders,
      );

      state = false; // Đặt state thành false khi tải dữ liệu xong
      return true;
    } catch (e) {
      debugPrint(e.toString());
      state = false;
      rethrow;
    }
  }
}

final dashboardController = StateNotifierProvider<DashboardController, bool>(
  (ref) => DashboardController(ref),
);
