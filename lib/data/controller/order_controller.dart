import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/common/common_response.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/models/order/order.dart';
import 'package:fluffypawsm/data/models/order/order_details.dart';
import 'package:fluffypawsm/data/models/order/status_wise_order_count.dart';
import 'package:fluffypawsm/data/repositories/mock_data_repository.dart';
import 'package:fluffypawsm/data/repositories/order_service_provider.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderController extends StateNotifier<bool> {
  final Ref ref;
  OrderController(this.ref) : super(false);
  DashboardInfo? _dashboard;

  DashboardInfo? get dashboard => _dashboard;

  Future<bool> getOrderListWithFilter(String status) async {
    try {
      state = true;
      final response =
      await ref.read(orderServiceProvider).getOrderListWithFilter(status);
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

final orderController =
StateNotifierProvider<OrderController, bool>((ref) => OrderController(ref));

// final orderStatusController =
// StateNotifierProvider<OrderStatusController, bool>(
//       (ref) => OrderStatusController(ref),
// );
