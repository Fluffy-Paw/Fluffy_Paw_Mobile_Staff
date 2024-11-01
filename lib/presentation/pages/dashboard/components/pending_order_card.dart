import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/widgets/component/confirmation_dialog.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class PendingOrderCard extends StatelessWidget {
  final Order order;
  const PendingOrderCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Material(
        color: AppColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Consumer(builder: (context, ref, _) {
          return ListTile(
            contentPadding: EdgeInsets.zero.copyWith(left: 20.w),
            onTap: () {
              // // Đặt order ID và điều hướng đến trang chi tiết order
              // ref.read(orderIdProvider.notifier).state = order.id;
              // final orderData = orderModel.Order.fromMap(order.toMap());
              // Navigator.of(context).pushNamed(Routes.orderDetailsView, arguments: orderData);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            title: Text(
              order.fullName.toString(),
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColor.blackColor,
                  fontStyle: FontStyle.italic),
            ),
            subtitle: _buildSubTitle(context: context),
            trailing: _buildTrailing(context: context, ref: ref),
          );
        }),
      ),
    );
  }

  Widget _buildSubTitle({required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: Row(
        children: [
          Text(
            '${GlobalFunction.numberLocalization(1)} ${S.of(context).items}',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColor.blackColor,
            ),
          ),
          Gap(5.w),
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.blackColor.withOpacity(0.2),
            ),
          ),
          Gap(5.w),
          Text(
            GlobalFunction.getOrderStatusLocalizationText(
                status: order.phone, context: context),
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColor.blackColor,
              fontSize: 13.sp,
            ),
          ),
          Gap(5.w),
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.blackColor.withOpacity(0.3),
            ),
          ),
          Gap(5.w),
          // Consumer(builder: (context, ref, _) {
          //   return Text(
          //     "${ref.read(authController.notifier).settings.currency}${GlobalFunction.numberLocalization(order.payableAmount)}",
          //     style: AppTextStyle(context).bodyTextSmall.copyWith(
          //           fontWeight: FontWeight.w500,
          //           color: AppColor.blackColor,
          //         ),
          //   );
          // }),
        ],
      ),
    );
  }

  Widget _buildTrailing({required BuildContext context, required WidgetRef ref}) {
    final cancelMessage = S.of(context).orderCancelDes;
    final confirmMessage = S.of(context).confirmOrder;
    
    // Lưu các function cần thiết
    final orderControllerNotifier = ref.read(orderController.notifier);
    final showSnackbar = (String message) => GlobalFunction.showCustomSnackbar(
      message: message,
      isSuccess: true,
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.3,
      height: 50.h,
      child: Row(
        children: [
          VerticalDivider(
            thickness: 1,
            color: AppColor.blackColor.withOpacity(0.2),
            indent: 15,
            endIndent: 15,
          ),
          Gap(6.w),
          InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () {
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => ConfirmationDialog(
                    isLoading: ref.watch(orderController),
                    text: cancelMessage,
                    cancelTapAction: () {
                      Navigator.of(dialogContext).pop();
                    },
                    applyTapAction: () async {
                      final success = await orderControllerNotifier.deniedBooking(order.id);
                      if (success && dialogContext.mounted) {
                        showSnackbar(cancelMessage);
                        await orderControllerNotifier.getOrderListWithFilter('Pending');
                      }
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                    image: Assets.image.alert.image(width: 90.w),
                  ),
                );
              }
            },
            child: CircleAvatar(
              radius: 18.sp,
              backgroundColor: AppColor.red100,
              child: const Icon(
                Icons.close,
                color: AppColor.redColor,
              ),
            ),
          ),
          Gap(10.w),
          InkWell(
            borderRadius: BorderRadius.circular(50.0),
            onTap: () async {
              if (context.mounted) {
                final success = await orderControllerNotifier.acceptBooking(order.id);
                if (success && context.mounted) {
                  showSnackbar(confirmMessage);
                  await orderControllerNotifier.getOrderListWithFilter('Pending');
                }
              }
            },
            child: CircleAvatar(
              radius: 18.sp,
              backgroundColor: AppColor.lime100,
              child: const Icon(
                Icons.done,
                color: AppColor.lime500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
