import 'dart:io';

import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/addess_picker.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_upload_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class ShopDetailsWidget extends ConsumerWidget {
  final List<FocusNode> shopFNode;
  const ShopDetailsWidget(this.shopFNode, {super.key});

  void _showImageSourceDialog(BuildContext context, WidgetRef ref, ImageType imageType) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Chọn nguồn tệp'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Chọn từ thư viện ảnh'),
            onTap: () {
              Navigator.pop(context);
              GlobalFunction.pickImageFromGallery(
                ref: ref,
                imageType: imageType,
                imageSource: ImageSource.gallery,
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.folder_open),
            title: Text('Chọn từ tệp'),
            onTap: () {
              Navigator.pop(context);
              GlobalFunction.pickFileFromSystem(
                ref: ref,
                imageType: imageType,
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Future<void> _openAddressPicker(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerScreen(
          initialLocation: ref.watch(selectedLocationProvider),
        ),
      ),
    );

    if (result != null && context.mounted) {
      final details = result['addressDetails'] as Map<String, dynamic>;

      // Cập nhật location
      ref.read(selectedLocationProvider.notifier).state =
          result['location'] as LatLng;

      // Giữ nguyên số nhà, đường đã nhập (nếu có)
      if (ref.read(streetProvider).text.isEmpty) {
        ref.read(streetProvider).text = details['street'] as String;
      }

      // Cập nhật các thành phần địa chỉ khác
      ref.read(wardProvider).text = details['ward'] as String;
      ref.read(districtProvider).text = details['district'] as String;
      ref.read(cityProvider).text = details['city'] as String;

      // Cập nhật địa chỉ đầy đủ
      _updateFullAddress(ref);

      // Debug logs
      debugPrint('Street: ${ref.read(streetProvider).text}');
      debugPrint('Ward: ${ref.read(wardProvider).text}');
      debugPrint('District: ${ref.read(districtProvider).text}');
      debugPrint('City: ${ref.read(cityProvider).text}');
      debugPrint('Full Address: ${ref.read(addressProvider).text}');
    }
  }

  Widget _buildPreviewImage(String imagePath) {
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      height: 120.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _updateFullAddress(WidgetRef ref) {
    final street = ref.read(streetProvider).text;
    final ward = ref.read(wardProvider).text;
    final district = ref.read(districtProvider).text;
    final city = ref.read(cityProvider).text;

    // Tạo địa chỉ đầy đủ từ các thành phần
    List<String> addressParts = [];
    if (street.isNotEmpty) addressParts.add(street);
    if (ward.isNotEmpty) addressParts.add(ward);
    if (district.isNotEmpty) addressParts.add(district);
    if (city.isNotEmpty) addressParts.add(city);

    // Cập nhật vào addressProvider
    ref.read(addressProvider).text = addressParts.join(', ');
  }
  Widget _buildIdCardSection(BuildContext context, WidgetRef ref) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        S.of(context).identitycard,
        style: AppTextStyle(context).subTitle,
      ),
      Gap(16.h),
      // Front ID
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomUploadButton(
            buttonText: ref.watch(frontIdProvider) != null
                ? "Thay đổi mặt trước"
                : S.of(context).frontside,
            icon: ref.watch(frontIdProvider) != null
                ? Icons.check_circle
                : Icons.credit_card,
            buttonColor: ref.watch(frontIdProvider) != null
                ? colors(context).primaryColor?.withOpacity(0.1)
                : null,
            onPressed: () => _showImageSourceDialog(
              context,
              ref,
              ImageType.frontId,
            ),
          ),
          if (ref.watch(frontIdProvider) != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                "Đã tải lên mặt trước",
                style: AppTextStyle(context).bodyText.copyWith(
                      color: colors(context).primaryColor,
                      fontSize: 12.sp,
                    ),
              ),
            ),
            _buildPreviewImage(ref.watch(frontIdProvider)!.path),
          ],
        ],
      ),
      Gap(16.h),
      // Back ID
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomUploadButton(
            buttonText: ref.watch(backIdProvider) != null
                ? "Thay đổi mặt sau"
                : S.of(context).backside,
            icon: ref.watch(backIdProvider) != null
                ? Icons.check_circle
                : Icons.credit_card_off,
            buttonColor: ref.watch(backIdProvider) != null
                ? colors(context).primaryColor?.withOpacity(0.1)
                : null,
            onPressed: () => _showImageSourceDialog(
              context,
              ref,
              ImageType.backId,
            ),
          ),
          if (ref.watch(backIdProvider) != null) ...[
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                "Đã tải lên mặt sau",
                style: AppTextStyle(context).bodyText.copyWith(
                      color: colors(context).primaryColor,
                      fontSize: 12.sp,
                    ),
              ),
            ),
            _buildPreviewImage(ref.watch(backIdProvider)!.path),
          ],
        ],
      ),
    ],
  );
}

  Widget _buildAddressSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              S.of(context).address,
              style: AppTextStyle(context).subTitle,
            ),
            Icon(Icons.star, color: Colors.red, size: 9.r)
          ],
        ),
        Gap(8.h),
        // Số nhà, đường có thể chỉnh sửa
        CustomTextFormField(
          name: 'streetAddress',
          hintText: 'Số nhà, Đường',
          textInputType: TextInputType.text,
          controller: ref.watch(streetProvider),
          textInputAction: TextInputAction.next,
          validator: (value) => GlobalFunction.defaultValidator(
            value: value!,
            hintText: 'Số nhà, Đường',
            context: context,
          ),
          onChanged: (value) {
            if (value != null) {
              ref.read(streetProvider).text = value;
              _updateFullAddress(ref);
            }
          },
        ),
        Gap(8.h),
        // Các trường địa chỉ từ map
        CustomTextFormField(
          name: 'ward',
          hintText: 'Phường/Xã',
          textInputType: TextInputType.text,
          controller: ref.watch(wardProvider),
          textInputAction: TextInputAction.next,
          readOnly: true,
          validator: (value) => GlobalFunction.defaultValidator(
            value: value!,
            hintText: 'Phường/Xã',
            context: context,
          ),
        ),
        Gap(8.h),
        CustomTextFormField(
          name: 'district',
          hintText: 'Quận/Huyện',
          textInputType: TextInputType.text,
          controller: ref.watch(districtProvider),
          textInputAction: TextInputAction.next,
          readOnly: true,
          validator: (value) => GlobalFunction.defaultValidator(
            value: value!,
            hintText: 'Quận/Huyện',
            context: context,
          ),
        ),
        Gap(8.h),
        CustomTextFormField(
          name: 'city',
          hintText: 'Tỉnh/Thành phố',
          textInputType: TextInputType.text,
          controller: ref.watch(cityProvider),
          textInputAction: TextInputAction.next,
          readOnly: true,
          validator: (value) => GlobalFunction.defaultValidator(
            value: value!,
            hintText: 'Tỉnh/Thành phố',
            context: context,
          ),
        ),
        Gap(8.h),
        // Trường ẩn để lưu địa chỉ đầy đủ cho API
        CustomTextFormField(
          name: 'address',
          hintText: 'Chọn địa chỉ trên bản đồ',
          textInputType: TextInputType.text,
          controller: ref.watch(addressProvider),
          textInputAction: TextInputAction.next,
          readOnly: true,
          widget: IconButton(
            icon: Icon(Icons.map),
            onPressed: () => _openAddressPicker(context, ref),
          ),
          onTap: () => _openAddressPicker(context, ref),
          validator: (value) => GlobalFunction.defaultValidator(
            value: value!,
            hintText: S.of(context).address,
            context: context,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormBuilder(
      key: ref.read(shopDetailsFormKey),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
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
                              ? FileImage(File(ref
                                  .watch(selectedShopLogo.notifier)
                                  .state!
                                  .path))
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
                                  ref: ref,
                                  imageType: ImageType.shopLogo,
                                );
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
                  _buildAddressSection(context, ref),
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
                          onPressed: () => _showImageSourceDialog(
                            context,
                            ref,
                            ImageType.businessLicense,
                          ),
                        ),
                        if (ref.watch(businessLicenseProvider) != null) ...[
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
                          _buildPreviewImage(
                              ref.watch(businessLicenseProvider)!.path),
                        ],
                      ],
                    ),
                  ),
                  Gap(16.h),
                  // Text(
                  //   S.of(context).identitycard,
                  //   style: AppTextStyle(context).subTitle,
                  // ),
                  _buildIdCardSection(context, ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
