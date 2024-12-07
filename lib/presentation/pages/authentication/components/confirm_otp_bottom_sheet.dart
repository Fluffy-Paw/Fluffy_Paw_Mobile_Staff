// confirm_otp_bottom_sheet.dart

import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/authentication_controller.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/pin_put.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ConfirmOTPBottomSheet extends ConsumerWidget {
  final TextEditingController pinCodeController;
  final TabController tabController;

  const ConfirmOTPBottomSheet({
    Key? key,
    required this.pinCodeController,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 30.h,
      ).copyWith(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).enterCode,
                style: AppTextStyle(context).title,
              ),
              GestureDetector(
                onTap: () {
                  ref.watch(isPinCodeComplete.notifier).state = false;
                  context.nav.pop(context);
                },
                child: Icon(Icons.close),
              )
            ],
          ),
          Gap(16.h),
          Text(
            '${S.of(context).otpDes}\n${ref.read(phoneProvider).text}',
            style: AppTextStyle(context).bodyText.copyWith(
                color: colors(context).bodyTextColor!.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                height: 1.5),
          ),
          Gap(20.h),
          PinPutWidget(
            onCompleted: (v) {
              ref.watch(isPinCodeComplete.notifier).state = true;
            },
            validator: (v) => null,
            pinCodeController: pinCodeController,
          ),
          Gap(24.h),
          AbsorbPointer(
            absorbing: !ref.watch(isPinCodeComplete),
            child: ref.watch(authController)
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    buttonText: S.of(context).confirm,
                    onPressed: () async {
                      final result =
                          await ref.read(authController.notifier).verifyOTP(
                                otp: pinCodeController.text,
                              );

                      if (result['success']) {
                        GlobalFunction.showCustomSnackbar(
                          message: result['message'],
                          isSuccess: true,
                          isTop: true,
                        );

                        ref.read(isPhoneNumberVerified.notifier).state = true;
                        ref.read(isPinCodeComplete.notifier).state = false;

                        // Set state và animateTo phải đi cùng nhau
                        ref.read(activeTabIndex.notifier).state = 1;
                        tabController.animateTo(1);

                        // Pop sheet ra sau khi đã set xong state
                        context.nav.pop(context);
                      } else {
                        GlobalFunction.showCustomSnackbar(
                          message: result['message'],
                          isSuccess: false,
                          isTop: true,
                        );
                      }
                    },
                    buttonColor: ref.watch(isPinCodeComplete)
                        ? colors(context).primaryColor
                        : AppColor.violet100,
                  ),
          ),
          Gap(20.h),
        ],
      ),
    );
  }
}
