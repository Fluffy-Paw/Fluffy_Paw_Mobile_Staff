import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/presentation/pages/order/layouts/order_details_layout.dart';
import 'package:flutter/material.dart';

class OrderDetailsView extends StatelessWidget {
  final Order order;
  const OrderDetailsView({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrderDetailsLayout(
      order: order,
    );
  }
}
