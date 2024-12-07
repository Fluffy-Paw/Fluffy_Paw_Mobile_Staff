import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

class PinPutWidget extends ConsumerStatefulWidget {
  final void Function(String)? onCompleted;
  final String? Function(String?)? validator;
  final TextEditingController pinCodeController;
  const PinPutWidget({
    Key? key,
    required this.onCompleted,
    required this.validator,
    required this.pinCodeController,
  }) : super(key: key);

  @override
  ConsumerState<PinPutWidget> createState() => _PinputExampleState();
}

class _PinputExampleState extends ConsumerState<PinPutWidget> {
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  void _handleCompleted(String pin) {
    if (widget.onCompleted != null) {
      widget.onCompleted!(pin);
    }
  }

  String? _validatePin(String? value) {
    return widget.validator!(value);
  }

  @override
  void dispose() {
    widget.pinCodeController.clear();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 70.w,
      height: 56.h,
      textStyle: const TextStyle(
        fontSize: 22,
        color: AppColor.blackColor,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors(context).bodyTextSmallColor!.withOpacity(
                0.1,
              ),
          width: 2,
        ),
      ),
    );

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Pinput(
              length: 6,
              preFilledWidget: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.h),
                    width: 12,
                    height: 2,
                    color: colors(context).bodyTextColor!.withOpacity(0.5),
                  ),
                ],
              ),
              keyboardType: TextInputType.text,
              controller: widget.pinCodeController,
              focusNode: focusNode,
              // androidSmsAutofillMethod:
              //     AndroidSmsAutofillMethod.smsUserConsentApi,
              // listenForMultipleSmsOnAndroid: true,
              defaultPinTheme: defaultPinTheme,
              separatorBuilder: (index) => SizedBox(width: 22.w),
              validator: _validatePin,
              hapticFeedbackType: HapticFeedbackType.lightImpact,
              onCompleted: _handleCompleted,
              onChanged: (pinCode) {
                if (ref.watch(isPinCodeComplete) && pinCode.length < 6) {
                  ref.watch(isPinCodeComplete.notifier).state = false;
                }
              },
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20.h),
                    width: 2,
                    height: 12,
                    color: colors(context).primaryColor,
                  ),
                ],
              ),
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors(context).primaryColor ?? AppColor.violetColor,
                  ),
                ),
              ),
              submittedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  color: colors(context).accentColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyBorderWith(
                border: Border.all(color: AppColor.redColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
