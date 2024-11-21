import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrackingStatusText extends StatelessWidget {
  final bool isSending;
  final bool isSuccess;
  final String? errorMessage;

  const TrackingStatusText({
    Key? key,
    this.isSending = false,
    this.isSuccess = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.w,
            height: 12.w,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.violetColor),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Đang gửi...',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.grey,
              fontSize: 11.sp,
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 12.sp,
            color: Colors.red,
          ),
          SizedBox(width: 4.w),
          Text(
            'Gửi lỗi',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.red,
              fontSize: 11.sp,
            ),
          ),
        ],
      );
    }

    if (isSuccess) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check,
            size: 12.sp,
            color: Colors.grey,
          ),
          SizedBox(width: 4.w),
          Text(
            'Đã gửi',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.grey,
              fontSize: 11.sp,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}