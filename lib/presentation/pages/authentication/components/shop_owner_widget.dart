// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/gender_menu.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class ShopOwnerWidget extends ConsumerWidget {
  final GlobalKey<FormBuilderState> formKey;
  final List<FocusNode> fNodeList;
  const ShopOwnerWidget({
    super.key,
    required this.formKey,
    required this.fNodeList,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: SizedBox(
        child: Column(
          children: [
            // _buildHeaderWidget(context: context, ref: ref),
            // Gap(20.h),
            _buildFormWidget(context: context, ref: ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget(
      {required BuildContext context, required WidgetRef ref}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 30.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90.h,
            width: 90.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: ref.watch(selectedUserProfileImage) != null
                  ? CircleAvatar(
                      radius: 90.r,
                      backgroundImage: FileImage(
                        File(ref
                            .watch(selectedUserProfileImage.notifier)
                            .state!
                            .path),
                      ),
                    )
                  : Assets.image.avatar.image(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).addProfile,
                  style: AppTextStyle(context).title,
                ),
                Gap(12.h),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        GlobalFunction.pickImageFromCamera(ref: ref);
                      },
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors(context).primaryColor ??
                                AppColor.violetColor,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.photo_camera,
                            color: colors(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    InkWell(
                      onTap: () {
                        GlobalFunction.pickImageFromGallery(
                            ref: ref, imageType: ImageType.userProfile);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 40.h,
                        width: 40.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                colors(context).bodyTextColor!.withOpacity(0.5),
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: colors(context).bodyTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormWidget({required BuildContext context, required WidgetRef ref}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: FormBuilder(
      key: formKey,
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 500),
            childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0, child: FadeInAnimation(child: widget)),
            children: [
              // Username
              CustomTextFormField(
                name: 'username',
                hintText: 'Username',
                textInputType: TextInputType.text,
                controller: ref.watch(usernameProvider),
                textInputAction: TextInputAction.next,
                validator: (value) => GlobalFunction.defaultValidator(
                  value: value!,
                  hintText: 'Username',
                  context: context,
                ),
              ),
              Gap(20.h),

              // First Name and Last Name
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      name: 'firstName',
                      focusNode: fNodeList[0],
                      hintText: S.of(context).firstName,
                      textInputType: TextInputType.text,
                      controller: ref.watch(firstNameProvider),
                      textInputAction: TextInputAction.next,
                      validator: (value) => GlobalFunction.firstNameValidator(
                        value: value!,
                        hintText: S.of(context).firstName,
                        context: context,
                      ),
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    child: CustomTextFormField(
                      name: 'lastName',
                      focusNode: fNodeList[1],
                      hintText: S.of(context).lastName,
                      textInputType: TextInputType.text,
                      controller: ref.watch(lastNameProvider),
                      textInputAction: TextInputAction.next,
                      validator: (value) => GlobalFunction.lastNameNameValidator(
                        value: value!,
                        hintText: S.of(context).lastName,
                        context: context,
                      ),
                    ),
                  ),
                ],
              ),
              Gap(20.h),

              // Phone
              CustomTextFormField(
                readOnly: ref.watch(isPhoneNumberVerified),
                name: 'phone',
                focusNode: fNodeList[2],
                hintText: S.of(context).phone,
                textInputType: TextInputType.phone,
                controller: ref.watch(phoneProvider),
                textInputAction: TextInputAction.next,
                validator: (value) => GlobalFunction.phoneValidator(
                  value: value!,
                  hintText: S.of(context).phone,
                  context: context,
                ),
              ),
              Gap(20.h),

              // Email
              CustomTextFormField(
                name: 'email',
                focusNode: fNodeList[3],
                hintText: S.of(context).email,
                textInputType: TextInputType.emailAddress,
                controller: ref.watch(emailProvider),
                textInputAction: TextInputAction.next,
                validator: (value) => GlobalFunction.emailValidator(
                  value: value!,
                  hintText: S.of(context).email,
                  context: context,
                ),
              ),
              Gap(20.h),

              // Password
              CustomTextFormField(
                name: 'password',
                focusNode: fNodeList[6],
                hintText: S.of(context).password,
                textInputType: TextInputType.text,
                controller: ref.watch(passwordProvider),
                textInputAction: TextInputAction.next,
                obscureText: ref.watch(obscureText1),
                widget: IconButton(
                  splashColor: Colors.transparent,
                  onPressed: () {
                    ref.watch(obscureText1.notifier).state =
                        !ref.watch(obscureText1);
                  },
                  icon: Icon(
                    !ref.watch(obscureText1)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                validator: (value) => GlobalFunction.passwordValidator(
                  value: value!,
                  hintText: S.of(context).password,
                  context: context,
                ),
              ),
              Gap(20.h),

              // Confirm Password
              CustomTextFormField(
                name: 'confirmPassword',
                focusNode: fNodeList[7],
                hintText: S.of(context).confirmPass,
                textInputType: TextInputType.text,
                controller: ref.watch(confirmPassProvider),
                textInputAction: TextInputAction.done,
                obscureText: ref.watch(obscureText2),
                widget: IconButton(
                  splashColor: Colors.transparent,
                  onPressed: () {
                    ref.watch(obscureText2.notifier).state =
                        !ref.watch(obscureText2);
                  },
                  icon: Icon(
                    !ref.watch(obscureText2)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                validator: (value) => GlobalFunction.passwordValidator(
                  value: value!,
                  hintText: S.of(context).confirmPass,
                  context: context,
                ),
              ),
              Gap(20.h),

              // Terms and conditions checkbox with text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    height: 16.h,
                    width: 16.w,
                    child: Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2.sp),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: colors(context).primaryColor,
                      value: ref.watch(isCheckBox),
                      onChanged: (value) {
                        ref.watch(isCheckBox.notifier).state = value ?? false;
                      },
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'I accept and agree to the ',
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                  ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // context.nav.pushNamed(Routes.termsAndconditionsView);
                                },
                                child: Text(
                                  'Terms & Condition',
                                  style: AppTextStyle(context).bodyText.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: colors(context).primaryColor,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: ' and ',
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                  ),
                            ),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () {
                                  // context.nav.pushNamed(Routes.privacyPolicyView);
                                },
                                child: Text(
                                  'Privacy Policy',
                                  style: AppTextStyle(context).bodyText.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: colors(context).primaryColor,
                                        fontSize: 14.sp,
                                      ),
                                ),
                              ),
                            ),
                            TextSpan(
                              text: ' of LaundryMart',
                              style: AppTextStyle(context).bodyText.copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(10.h),
            ],
          ),
        ),
      ),
    ),
  );
}
}
