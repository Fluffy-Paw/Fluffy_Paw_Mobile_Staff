// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';


class CustomUploadButton extends StatelessWidget {
  final String buttonText;
  final Color? buttonColor;
  final IconData icon;
  final void Function()? onPressed;

  const CustomUploadButton({
    Key? key,
    required this.buttonText,
    this.buttonColor,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
            buttonColor ?? Theme.of(context).scaffoldBackgroundColor),
        minimumSize: MaterialStateProperty.all(
          Size(double.infinity, 50.h),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(
              color: colors(context)
                  .bodyTextColor!
                  .withOpacity(0.6), // Set border color
              width: 1.5, // Set border width
            ),
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: colors(context).bodyTextColor!.withOpacity(0.7),
            size: 25.sp,
          ),
          Gap(5.w),
          Text(
            buttonText,
            style: AppTextStyle(context).bodyText.copyWith(
                  color: colors(context).bodyTextColor!.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
