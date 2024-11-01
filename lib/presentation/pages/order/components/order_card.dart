import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_status_card.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12.r,
            ),
          ),
          color: AppColor.whiteColor,
          child: InkWell(
            borderRadius: BorderRadius.circular(
              12.r,
            ),
            onTap: () {
              context.nav.pushNamed(
                Routes.orderDetailsView,
                arguments: order,
              );
            },
            child: Stack(
              children: [
                Padding(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.serviceName,
                        style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColor.blackColor),
                      ),
                      Gap(5.h),
                      Text(
                        order.phone,
                        style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColor.blackColor.withOpacity(0.8),
                          fontSize: 14.sp,
                        ),
                      ),
                      Gap(5.h),
                      buildSubTitle(context: context, order: order),
                    ],
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 16.w,
                  child: OrderStatusCard(orderStatus: order.status),
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildSubTitle({required BuildContext context, required Order order}) {
    return Row(
      children: [
        Container(
          height: 25.h,
          width: 25.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: AppColor.offWhiteColor,
          ),
          child: Center(
            child: Text(
              order.status == 'Accepted' ? 'P' : 'D',
              style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
                color: AppColor.blackColor.withOpacity(0.8),
              ),
            ),
          ),
        ),
        Gap(8.w),
        Text(
          order.fullName,
          style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColor.blackColor.withOpacity(0.8),
              fontSize: 13.sp),
        ),
        Gap(8.w),
        Container(
          height: 5,
          width: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.blackColor.withOpacity(0.2),
          ),
        ),
        Gap(8.w),
        Text(
          order.status,
          style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColor.blackColor.withOpacity(0.8),
            fontSize: 13.sp,
          ),
        ),
        Gap(8.w),
        Container(
          height: 5,
          width: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColor.blackColor.withOpacity(0.3),
          ),
        ),
        Gap(8.w),
        Text(
          '#${order.id}',
          style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColor.blackColor.withOpacity(0.8),
            fontStyle: FontStyle.italic,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
