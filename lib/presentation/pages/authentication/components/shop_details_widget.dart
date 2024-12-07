import 'dart:io';

import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class ShopDetailsWidget extends ConsumerWidget {
  final List<FocusNode> shopFNode;
  const ShopDetailsWidget(this.shopFNode, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormBuilder(
      key: ref.read(shopDetailsFormKey),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
        ),
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    )),
                children: [
                  Gap(20.h),
                  CustomTextFormField(
                    name: 'shopName',
                    focusNode: shopFNode[0],
                    hintText: S.of(context).shopName,
                    textInputType: TextInputType.text,
                    controller: ref.watch(shopNameProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.shopNameValidator(
                      value: value!,
                      hintText: S.of(context).shopName,
                      context: context,
                    ),
                  ),
                  
                  Gap(16.h),
                  Row(
                    children: [
                      Text(
                        S.of(context).shopLogo,
                        style: AppTextStyle(context).subTitle,
                      ),
                      Icon(Icons.star, color: Colors.red, size: 9.r)
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50.r,
                          backgroundImage: ref.watch(selectedShopLogo) != null
                              ? FileImage(
                                  File(ref
                                      .watch(selectedShopLogo.notifier)
                                      .state!
                                      .path),
                                )
                              : AssetImage(Assets.image.shopLogo.keyName)
                                  as ImageProvider,
                        ),
                        Gap(16.w),
                        Flexible(
                          flex: 2,
                          child: SizedBox(
                            child: CustomUploadButton(
                              buttonText: S.of(context).uploadLogo,
                              icon: Icons.photo,
                              onPressed: () {
                                GlobalFunction.pickImageFromGallery(
                                    ref: ref, imageType: ImageType.shopLogo);
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1.5,
                    color: colors(context).bodyTextColor!.withOpacity(0.5),
                  ),
                  Gap(16.h),
                  Row(
                    children: [
                      Text(
                        S.of(context).bannerImage,
                        style: AppTextStyle(context).subTitle,
                      ),
                      Icon(Icons.star, color: Colors.red, size: 9.r)
                    ],
                  ),
                  Gap(16.h),
                  CustomTextFormField(
                    name: 'mst',
                    focusNode: shopFNode[3],
                    hintText: S.of(context).taxNumber,
                    textInputType: TextInputType.text,
                    controller: ref.watch(mstProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.defaultValidator(
                      value: value!,
                      hintText: S.of(context).taxNumber,
                      context: context,
                    ),
                  ),
                  Gap(16.h),
                  CustomTextFormField(
                    name: 'brandEmail',
                    focusNode: shopFNode[4],
                    hintText: S.of(context).brandEmail,
                    textInputType: TextInputType.emailAddress,
                    controller: ref.watch(brandEmailProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.emailValidator(
                      value: value!,
                      hintText: S.of(context).brandEmail,
                      context: context,
                    ),
                  ),
                  Gap(16.h),
                  CustomTextFormField(
                    name: 'address',
                    focusNode: shopFNode[5],
                    hintText: S.of(context).address,
                    textInputType: TextInputType.text,
                    controller: ref.watch(addressProvider),
                    textInputAction: TextInputAction.next,
                    validator: (value) => GlobalFunction.defaultValidator(
                      value: value!,
                      hintText: S.of(context).address,
                      context: context,
                    ),
                  ),
                  Gap(16.h),
                  Text(
                    S.of(context).businessLicense,
                    style: AppTextStyle(context).subTitle,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        CustomUploadButton(
                          buttonText: ref.watch(businessLicenseProvider) != null
                              ? "Change License"
                              : S.of(context).uploadLicense,
                          icon: ref.watch(businessLicenseProvider) != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          buttonColor: ref.watch(businessLicenseProvider) !=
                                  null
                              ? colors(context).primaryColor?.withOpacity(0.1)
                              : null,
                          onPressed: () {
                            GlobalFunction.pickImageFromGallery(
                              ref: ref,
                              imageType: ImageType.businessLicense,
                            );
                          },
                        ),
                        if (ref.watch(businessLicenseProvider) != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              "License uploaded successfully",
                              style: AppTextStyle(context).bodyText.copyWith(
                                    color: colors(context).primaryColor,
                                    fontSize: 12.sp,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Gap(16.h),
                  Text(
                    S.of(context).identitycard,
                    style: AppTextStyle(context).subTitle,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            CustomUploadButton(
                              buttonText: ref.watch(frontIdProvider) != null
                                  ? "Change Front"
                                  : S.of(context).frontside,
                              icon: ref.watch(frontIdProvider) != null
                                  ? Icons.check_circle
                                  : Icons.credit_card,
                              buttonColor: ref.watch(frontIdProvider) != null
                                  ? colors(context)
                                      .primaryColor
                                      ?.withOpacity(0.1)
                                  : null,
                              onPressed: () {
                                GlobalFunction.pickImageFromGallery(
                                  ref: ref,
                                  imageType: ImageType.frontId,
                                );
                              },
                            ),
                            if (ref.watch(frontIdProvider) != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  "Front ID uploaded",
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            color: colors(context).primaryColor,
                                            fontSize: 12.sp,
                                          ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: Column(
                          children: [
                            CustomUploadButton(
                              buttonText: ref.watch(backIdProvider) != null
                                  ? "Change Back"
                                  : S.of(context).backside,
                              icon: ref.watch(backIdProvider) != null
                                  ? Icons.check_circle
                                  : Icons.credit_card_off,
                              buttonColor: ref.watch(backIdProvider) != null
                                  ? colors(context)
                                      .primaryColor
                                      ?.withOpacity(0.1)
                                  : null,
                              onPressed: () {
                                GlobalFunction.pickImageFromGallery(
                                  ref: ref,
                                  imageType: ImageType.backId,
                                );
                              },
                            ),
                            if (ref.watch(backIdProvider) != null)
                              Padding(
                                padding: EdgeInsets.only(top: 8.h),
                                child: Text(
                                  "Back ID uploaded",
                                  style:
                                      AppTextStyle(context).bodyText.copyWith(
                                            color: colors(context).primaryColor,
                                            fontSize: 12.sp,
                                          ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
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
