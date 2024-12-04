import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderTabCard extends ConsumerWidget {
  final int orderCount;
  final String orderStatus;
  final bool isActiveTab;
  
  const OrderTabCard({
    Key? key,
    required this.orderCount,
    required this.orderStatus,
    required this.isActiveTab,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    final isLoading = ref.watch(isLoadingCountsProvider);

    return IntrinsicHeight(
      child: Container(
        width: 100.w,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isActiveTab
              ? AppColor.violetColor.withOpacity(0.1)
              : isDark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : AppColor.offWhiteColor,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isActiveTab ? AppColor.violetColor : AppColor.offWhiteColor,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isActiveTab ? AppColor.violetColor : AppColor.gray,
                    ),
                  ),
                )
              else
                Text(
                  GlobalFunction.numberLocalization(orderCount.toString()),
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isActiveTab 
                            ? AppColor.violetColor
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
              Text(
                orderStatus,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: isActiveTab 
                          ? AppColor.violetColor 
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }
}