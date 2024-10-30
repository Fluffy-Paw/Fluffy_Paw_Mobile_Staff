import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusCard extends StatelessWidget {
  final String orderStatus;
  const OrderStatusCard({
    Key? key,
    required this.orderStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: GlobalFunction.getStatusCardColor(status: orderStatus),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Center(
        child: Text(
          GlobalFunction.getOrderStatusLocalizationText(
              status: orderStatus, context: context),
          style: AppTextStyle(context).bodyTextSmall.copyWith(
            color: AppColor.whiteColor,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}