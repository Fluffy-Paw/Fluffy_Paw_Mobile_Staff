import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class SellerAccountLayout extends ConsumerStatefulWidget {
  const SellerAccountLayout({super.key});

  @override
  ConsumerState<SellerAccountLayout> createState() =>
      _SellerAccountLayoutState();
}

class _SellerAccountLayoutState extends ConsumerState<SellerAccountLayout> {
  final List<FocusNode> fNodeList = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(hiveStoreService).getUserInfo().then(
        (userInformation) {
          setState(() {
            profileImage = userInformation!.account.avatar;
          });
          setUserInfo(userInfo: userInformation);
        },
      );
    });
    super.initState();
  }

  void setUserInfo({required User? userInfo}) {
    ref.read(firstNameProvider).text = userInfo!.account.username;
    ref.read(lastNameProvider).text = userInfo!.account.roleName;
    ref.read(emailProvider).text = userInfo.account.status.toString();
    //ref.read(genderProvider).text = userInfo.gender;
    ref.read(dateOfBirthProvider).text = userInfo.account.createDate;
    //ref.read(phoneProvider).text = userInfo.mobile;
  }

  @override
  void dispose() {
    for (var node in fNodeList) {
      node.dispose();
    }
    super.dispose();
  }

  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor:
            isDark ? AppColor.offWhiteColor : AppColor.offWhiteColor,
        appBar: AppBar(
          title: Text(S.of(context).sellerProfile),
          surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        bottomNavigationBar:
            _buildBottomWidget(isDark: isDark, context: context, ref: ref),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(2),
              _buildHeaderWidget(context: context, ref: ref, isDark: isDark),
              Gap(10.h),
              _buildFormWidget(context: context, ref: ref, isDark: isDark)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomWidget(
      {required bool isDark,
      required BuildContext context,
      required WidgetRef ref}) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        border: Border(
          top: BorderSide(
              color: colors(context).bodyTextSmallColor!.withOpacity(0.1),
              width: 2),
        ),
      ),
      child: Center(
        child: ref.watch(profileController)
            ? const CircularProgressIndicator()
            : SizedBox(
                height: 50.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomButton(
                    buttonText: 'Update',
                    buttonColor: colors(context).primaryColor,
                    onPressed: () {
                      // if (ref.read(ridersFormKey).currentState!.validate()) {
                      //   SellerInfoUpdateModel sellerInfo =
                      //       SellerInfoUpdateModel(
                      //     firstName: ref.read(firstNameProvider).text,
                      //     lastName: ref.read(lastNameProvider).text,
                      //     email: ref.read(emailProvider).text,
                      //     gender: ref.read(genderProvider).text,
                      //     dateOfBirth: ref.read(dateOfBirthProvider).text,
                      //   );
                      //   ref
                      //       .read(profileController.notifier)
                      //       .updateSellerProfile(
                      //           sellerInfo: sellerInfo,
                      //           file: ref.read(selectedUserProfileImage) != null
                      //               ? File(ref
                      //                   .read(selectedUserProfileImage)!
                      //                   .path)
                      //               : null)
                      //       .then((response) {
                      //     GlobalFunction.showCustomSnackbar(
                      //         message: response.message,
                      //         isSuccess: response.isSuccess);
                      //   });
                      //   debugPrint(sellerInfo.toJson());
                      // }
                    },
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeaderWidget({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
  }) {
    return Container(
      color: isDark ? AppColor.blackColor : AppColor.whiteColor,
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
              child: CircleAvatar(
                radius: 90.r,
                backgroundImage: ref.watch(selectedUserProfileImage) != null
                    ? FileImage(
                        File(ref
                            .watch(selectedUserProfileImage.notifier)
                            .state!
                            .path),
                      )
                    : CachedNetworkImageProvider(profileImage) as ImageProvider,
              ),
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

  Widget _buildFormWidget(
      {required BuildContext context,
      required WidgetRef ref,
      required bool isDark}) {
    return Container(
      constraints:
          BoxConstraints(minHeight: MediaQuery.of(context).size.height / 1.5),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
        child: FormBuilder(
          key: ref.read(ridersFormKey),
          child: AnimationLimiter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: CustomTextFormField(
                            name: 'firstName',
                            focusNode: fNodeList[0],
                            hintText: S.of(context).firstName,
                            textInputType: TextInputType.text,
                            controller: ref.watch(firstNameProvider),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                GlobalFunction.firstNameValidator(
                              value: value!,
                              hintText: S.of(context).firstName,
                              context: context,
                            ),
                          ),
                        ),
                        Gap(16.w),
                        Flexible(
                          flex: 1,
                          child: CustomTextFormField(
                            name: 'lastName',
                            focusNode: fNodeList[1],
                            hintText: S.of(context).lastName,
                            textInputType: TextInputType.text,
                            controller: ref.watch(lastNameProvider),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                GlobalFunction.lastNameNameValidator(
                              value: value!,
                              hintText: S.of(context).lastName,
                              context: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(20.h),
                    CustomTextFormField(
                      name: 'email',
                      focusNode: fNodeList[2],
                      hintText: S.of(context).email,
                      textInputType: TextInputType.text,
                      controller: ref.watch(emailProvider),
                      textInputAction: TextInputAction.next,
                      validator: (value) => GlobalFunction.emailValidator(
                        value: value!,
                        hintText: S.of(context).email,
                        context: context,
                      ),
                    ),
                    Gap(20.w),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              // showModalBottomSheet(
                              //   isDismissible: false,
                              //   backgroundColor:
                              //       Theme.of(context).scaffoldBackgroundColor,
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.only(
                              //       topLeft: Radius.circular(12.r),
                              //       topRight: Radius.circular(12.r),
                              //     ),
                              //   ),
                              //   context: context,
                              //   builder: (BuildContext context) {
                              //     return ShowGenderMenu();
                              //   },
                              // );
                            },
                            // child: CustomTextFormField(
                            //   name: 'gender',
                            //   focusNode: fNodeList[3],
                            //   hintText: S.of(context).gender,
                            //   textInputType: TextInputType.text,
                            //   controller: ref.read(genderProvider),
                            //   textInputAction: TextInputAction.next,
                            //   readOnly: true,
                            //   widget: Icon(
                            //     Icons.keyboard_arrow_down,
                            //     size: 35.sp,
                            //     color: AppColor.blackColor.withOpacity(0.6),
                            //   ),
                            //   validator: (value) =>
                            //       GlobalFunction.defaultValidator(
                            //     value: value!,
                            //     hintText: S.of(context).gender,
                            //     context: context,
                            //   ),
                            // ),
                          ),
                        ),
                        Gap(16.w),
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => GlobalFunction.datePicker(
                                context: context, ref: ref),
                            child: CustomTextFormField(
                              name: 'dateOfBirth',
                              focusNode: fNodeList[4],
                              hintText: S.of(context).dateOfBirth,
                              textInputType: TextInputType.text,
                              controller: ref.watch(dateOfBirthProvider),
                              textInputAction: TextInputAction.next,
                              readOnly: true,
                              widget: Icon(
                                Icons.calendar_month,
                                size: 24.sp,
                                color: AppColor.blackColor.withOpacity(0.6),
                              ),
                              validator: (value) =>
                                  GlobalFunction.dateOfBirthValidator(
                                value: value!,
                                hintText: S.of(context).dateOfBirth,
                                context: context,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap(20.h),
                    // CustomTextFormField(
                    //   readOnly: true,
                    //   name: 'phone',
                    //   focusNode: fNodeList[5],
                    //   hintText: S.of(context).phone,
                    //   textInputType: TextInputType.text,
                    //   controller: ref.watch(phoneProvider),
                    //   textInputAction: TextInputAction.next,
                    //   validator: (value) {
                    //     return null;
                    //   },
                    // ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }

  String profileImage =
      "https://as2.ftcdn.net/v2/jpg/03/64/21/11/1000_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg";
}
