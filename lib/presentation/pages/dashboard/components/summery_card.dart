import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SummeryCard extends StatelessWidget {
  final String count;
  final String status;
  final String icon;
  const SummeryCard({
    Key? key,
    required this.count,
    required this.status,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: AppColor.offWhiteColor,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                count.toString(),
                style: AppTextStyle(context)
                    .title
                    .copyWith(color: AppColor.blackColor),
              ),
              SvgPicture.asset(icon)
            ],
          ),
          const Spacer(),
          Text(
            status,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              fontWeight: FontWeight.w400,
              color: AppColor.blackColor.withOpacity(0.4),
            ),
          )
        ],
      ),
    );
  }
}