import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:shimmer/shimmer.dart';

class OrderTabCardShimmerWidget extends StatelessWidget {
  const OrderTabCardShimmerWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Container(
        width: 100.w,
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColor.offWhiteColor,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Shimmer.fromColors(
                baseColor: AppColor.whiteColor,
                highlightColor: AppColor.offWhiteColor,
                child: Container(
                  height: 10.h,
                  width: 30.w,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              Gap(10.h),
              Shimmer.fromColors(
                baseColor: AppColor.whiteColor,
                highlightColor: AppColor.offWhiteColor,
                child: Container(
                  height: 10.h,
                  width: 50.w,
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
