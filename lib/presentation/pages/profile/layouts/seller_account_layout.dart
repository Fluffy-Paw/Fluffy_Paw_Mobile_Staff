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
  ConsumerState<SellerAccountLayout> createState() => _SellerAccountLayoutState();
}

class _SellerAccountLayoutState extends ConsumerState<SellerAccountLayout> {
  final List<FocusNode> fNodeList = List.generate(6, (_) => FocusNode());
  String profileImage = "https://as2.ftcdn.net/v2/jpg/03/64/21/11/1000_F_364211147_1qgLVxv1Tcq0Ohz3FawUfrtONzz8nq3e.jpg";
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final userInfo = await ref.read(hiveStoreService).getUserInfo();
    if (mounted) {
      setState(() => profileImage = userInfo!.account.avatar);
      setUserInfo(userInfo: userInfo);
    }
  }

  void setUserInfo({required User? userInfo}) {
    ref.read(firstNameProvider).text = userInfo!.account.username;
    ref.read(lastNameProvider).text = userInfo.account.roleName;
    ref.read(emailProvider).text = userInfo.account.status.toString();
    ref.read(dateOfBirthProvider).text = userInfo.account.createDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    return Scaffold(
      backgroundColor: isDark ? AppColor.offWhiteColor : AppColor.offWhiteColor,
      appBar: AppBar(
        title: Text(S.of(context).sellerProfile),
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderWidget(context, ref, isDark)),
            SliverToBoxAdapter(child: Gap(10.h)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildFormWidget(context, ref, isDark),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, isDark),
    );
  }

  Widget _buildHeaderWidget(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 45.r,
            backgroundImage: ref.watch(selectedUserProfileImage) != null
                ? FileImage(File(ref.watch(selectedUserProfileImage.notifier).state!.path))
                : CachedNetworkImageProvider(profileImage) as ImageProvider,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.of(context).addProfile, style: AppTextStyle(context).title),
                Gap(12.h),
                Row(
                  children: [
                    _buildImageButton(
                      onTap: () => GlobalFunction.pickImageFromCamera(ref: ref),
                      icon: Icons.photo_camera,
                      isPrimary: true,
                    ),
                    Gap(12.w),
                    _buildImageButton(
                      onTap: () => GlobalFunction.pickImageFromGallery(
                        ref: ref,
                        imageType: ImageType.userProfile,
                      ),
                      icon: Icons.image_outlined,
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required VoidCallback onTap,
    required IconData icon,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary 
                ? colors(context).primaryColor ?? AppColor.violetColor
                : colors(context).bodyTextColor!.withOpacity(0.5),
          ),
        ),
        child: Icon(
          icon,
          color: isPrimary ? colors(context).primaryColor : colors(context).bodyTextColor,
        ),
      ),
    );
  }

  Widget _buildFormWidget(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: FormBuilder(
        key: ref.read(ridersFormKey),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFormFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                name: 'firstName',
                focusNode: fNodeList[0],
                hintText: S.of(context).firstName,
                controller: ref.watch(firstNameProvider),
                validator: (v) => GlobalFunction.firstNameValidator(
                  value: v!,
                  hintText: S.of(context).firstName,
                  context: context,
                ),
              ),
            ),
            Gap(16.w),
            Expanded(
              child: _buildTextField(
                name: 'lastName',
                focusNode: fNodeList[1],
                hintText: S.of(context).lastName,
                controller: ref.watch(lastNameProvider),
                validator: (v) => GlobalFunction.lastNameNameValidator(
                  value: v!,
                  hintText: S.of(context).lastName,
                  context: context,
                ),
              ),
            ),
          ],
        ),
        Gap(20.h),
        _buildTextField(
          name: 'email',
          focusNode: fNodeList[2],
          hintText: S.of(context).email,
          controller: ref.watch(emailProvider),
          validator: (v) => GlobalFunction.emailValidator(
            value: v!,
            hintText: S.of(context).email,
            context: context,
          ),
        ),
        Gap(20.h),
        Row(
          children: [
            Expanded(child: SizedBox()), // Placeholder for gender field
            Gap(16.w),
            Expanded(
              child: GestureDetector(
                onTap: () => GlobalFunction.datePicker(context: context, ref: ref),
                child: _buildTextField(
                  name: 'dateOfBirth',
                  focusNode: fNodeList[4],
                  hintText: S.of(context).dateOfBirth,
                  controller: ref.watch(dateOfBirthProvider),
                  readOnly: true,
                  suffix: Icon(
                    Icons.calendar_month,
                    size: 24.sp,
                    color: AppColor.blackColor.withOpacity(0.6),
                  ),
                  validator: (v) => GlobalFunction.dateOfBirthValidator(
                    value: v!,
                    hintText: S.of(context).dateOfBirth,
                    context: context,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String name,
    required FocusNode focusNode,
    required String hintText,
    required TextEditingController controller,
    bool readOnly = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return CustomTextFormField(
      name: name,
      focusNode: focusNode,
      hintText: hintText,
      textInputType: TextInputType.text,
      controller: controller,
      textInputAction: TextInputAction.next,
      readOnly: readOnly,
      widget: suffix,
      validator: validator,
    );
  }

  Widget _buildBottomBar(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      height: 80.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColor.blackColor : AppColor.whiteColor,
        border: Border(
          top: BorderSide(
            color: colors(context).bodyTextSmallColor!.withOpacity(0.1),
            width: 2,
          ),
        ),
      ),
      child: ref.watch(profileController)
          ? const Center(child: CircularProgressIndicator())
          : CustomButton(
              buttonText: 'Update',
              buttonColor: colors(context).primaryColor,
              onPressed: () {},
            ),
    );
  }

  @override
  void dispose() {
    for (var node in fNodeList) {
      node.dispose();
    }
    super.dispose();
  }
}