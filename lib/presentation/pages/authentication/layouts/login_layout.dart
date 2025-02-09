import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/authentication_controller.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class LoginLayout extends ConsumerStatefulWidget {
  const LoginLayout({super.key});

  @override
  ConsumerState<LoginLayout> createState() => _LoginLayoutState();
}

class _LoginLayoutState extends ConsumerState<LoginLayout> {
  final List<FocusNode> fNodes = [FocusNode(), FocusNode()];

  final TextEditingController contactController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).scaffoldBackgroundColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Thay đổi từ false sang true
        body: SafeArea(
          child: SingleChildScrollView(
            // Wrap toàn bộ content trong SingleChildScrollView
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 40.h,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    20.h, // Thêm padding bottom để tránh bàn phím
              ),
              child: Column(
                children: [
                  FormBuilder(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SvgPicture.asset(
                          themeColor == AppColor.blackColor
                              ? Assets.svg.fluffypawLogo
                              : Assets.svg.fluffyPawDarl,
                          width: 200.w,
                        ),
                        Gap(30.h),
                        Text(
                          S.of(context).loginTitle,
                          style: AppTextStyle(context).title,
                        ),
                        Gap(30.h),
                        CustomTextFormField(
                          name: 'emailOrPhone',
                          focusNode: fNodes[0],
                          hintText: S.of(context).emailOrPhone,
                          textInputType: TextInputType.text,
                          controller: contactController,
                          textInputAction: TextInputAction.next,
                          validator: (value) => GlobalFunction.shopDesValidator(
                            value: value!,
                            hintText: S.of(context).emailOrPhone,
                            context: context,
                          ),
                        ),
                        Gap(30.h),
                        CustomTextFormField(
                          name: 'password',
                          focusNode: fNodes[1],
                          hintText: S.of(context).password,
                          textInputType: TextInputType.text,
                          controller: passwordController,
                          textInputAction: TextInputAction.done,
                          obscureText: ref.watch(obscureText1),
                          widget: IconButton(
                            splashColor: Colors.transparent,
                            onPressed: () {
                              ref.read(obscureText1.notifier).state =
                                  !ref.read(obscureText1.notifier).state;
                            },
                            icon: Icon(
                              !ref.read(obscureText1.notifier).state
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          validator: (value) =>
                              GlobalFunction.passwordValidator(
                            value: value!,
                            hintText: S.of(context).password,
                            context: context,
                          ),
                        ),
                        Gap(20.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () =>
                                context.nav.pushNamed(Routes.forgotPassword),
                            child: Text(
                              'Quên mật khẩu?',
                              style: AppTextStyle(context).bodyText.copyWith(
                                    color: colors(context).primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ),
                        Gap(30.h),
                        ref.watch(authController)
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                buttonText: S.of(context).login,
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (formKey.currentState!.validate()) {
                                    ref
                                        .read(authController.notifier)
                                        .login(
                                          contact: contactController.text,
                                          password: passwordController.text,
                                        )
                                        .then((isSuccess) async {
                                      if (isSuccess) {
                                        context.nav.pushNamedAndRemoveUntil(
                                            Routes.core, (route) => false);
                                      }
                                    });
                                  }
                                },
                              ),
                        Gap(20.h),
                      ],
                    ),
                  ),
                  // Phần bottom text
                  SizedBox(
                    height: 50.h,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: S.of(context).dontHaveAnAccount,
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                  ),
                            ),
                            TextSpan(
                              text: S.of(context).register,
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: colors(context).primaryColor,
                                    fontSize: 14.sp,
                                  ),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    () => context.nav.pushNamed(Routes.signUp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
