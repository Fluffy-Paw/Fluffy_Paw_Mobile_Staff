import 'package:dio/src/response.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/order_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderService implements OrderProvider{
  final Ref ref;
  OrderService(this.ref);
  @override
  Future<Response> getOrderListWithFilter(String status) async {
    final response = await ref.read(apiClientProvider).get(
      '${AppConstants.dashboardInfo}?Status=$status',
    );
    return response;
  }

}
final orderServiceProvider = Provider((ref) => OrderService(ref));