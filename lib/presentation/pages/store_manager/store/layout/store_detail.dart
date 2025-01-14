import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/store/layout/account_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:carousel_slider/carousel_slider.dart';

class StoreDetailScreen extends StatelessWidget {
  final StoreModel store;

  const StoreDetailScreen({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColor.violetColor,
            elevation: 0,
            stretch: true,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: store.files.isNotEmpty
                  ? CarouselSlider(
                      options: CarouselOptions(
                        height: 250.h,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        autoPlay: true,
                      ),
                      items: store.files.map((file) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Image.network(
                              file.file,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColor.gray.withOpacity(0.1),
                                  child: Icon(Icons.error),
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    )
                  : Image.network(
                      store.logo,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColor.gray.withOpacity(0.1),
                          child: Icon(Icons.store),
                        );
                      },
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  topRight: Radius.circular(30.r),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'store_logo_${store.id}',
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.network(
                              store.logo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColor.gray.withOpacity(0.1),
                                  child: Icon(Icons.store),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Gap(16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: AppTextStyle(context).title.copyWith(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.blackColor,
                                  ),
                            ),
                            Gap(8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.violetColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                store.brandName,
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                      color: AppColor.violetColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(24.h),
                  _buildManagerSection(context),
                  Gap(24.h),
                  _buildRatingSection(context),
                  Gap(24.h),
                  _buildInfoSection(
                    context: context,
                    title: 'Thông tin liên hệ',
                    children: [
                      _buildContactItem(
                        context: context,
                        icon: Icons.phone,
                        title: 'Số điện thoại',
                        content: store.phone,
                      ),
                      _buildContactItem(
                        context: context,
                        icon: Icons.location_on,
                        title: 'Địa chỉ',
                        content: store.address,
                      ),
                    ],
                  ),
                  Gap(24.h),
                  Text(
                    'Giấy phép hoạt động',
                    style: AppTextStyle(context).title.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackColor,
                        ),
                  ),
                  Gap(12.h),
                  Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        store.operatingLicense,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColor.gray.withOpacity(0.1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 40.sp,
                                  color: AppColor.gray,
                                ),
                                Gap(8.h),
                                Text(
                                  'Không có hình ảnh',
                                  style: AppTextStyle(context)
                                      .bodyTextSmall
                                      .copyWith(
                                        color: AppColor.gray,
                                      ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagerSection(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountDetailScreen(store: store.account),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.offWhiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.r,
                backgroundImage: NetworkImage(store.account.avatar),
                backgroundColor: AppColor.gray.withOpacity(0.1),
                onBackgroundImageError: (e, s) => Icon(Icons.person),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nhân viên',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.gray,
                          ),
                    ),
                    Gap(4.h),
                    Text(
                      store.account.username,
                      style: AppTextStyle(context).bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      store.account.email,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.gray,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColor.violetColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      store.account.roleName,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: AppColor.violetColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Gap(4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12.sp,
                      color: AppColor.violetColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.offWhiteColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  store.totalRating.toStringAsFixed(1),
                  style: AppTextStyle(context).title.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.blackColor,
                      ),
                ),
                Gap(4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Icon(
                      index < store.totalRating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 20.sp,
                    );
                  }),
                ),
              ],
            ),
          ),
          Container(
            height: 50.h,
            width: 1,
            color: AppColor.gray.withOpacity(0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Trạng thái',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.gray,
                      ),
                ),
                Gap(4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: store.status
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    store.status ? 'Hoạt động' : 'Ngừng hoạt động',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: store.status ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle(context).title.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.blackColor,
              ),
        ),
        Gap(12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.offWhiteColor,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppColor.violetColor,
              size: 20.sp,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.gray,
                      ),
                ),
                Gap(4.h),
                Text(
                  content,
                  style: AppTextStyle(context).bodyText.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
