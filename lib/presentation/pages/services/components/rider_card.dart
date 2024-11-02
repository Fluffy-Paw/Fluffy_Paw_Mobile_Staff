import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class RiderCard extends StatelessWidget {
  final Service rider;
  const RiderCard({
    Key? key,
    required this.rider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Consumer(builder: (context, ref, _) {
        return ListTile(
          onTap: () {
            ref.read(riderIdProvider.notifier).state = rider.id;
            context.nav.pushNamed(Routes.serviceDetails, arguments: rider);
          },
          contentPadding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          leading: Hero(
            tag: rider.id,
            child: CircleAvatar(
              backgroundColor: AppColor.violetColor,
              radius: 28,
              backgroundImage: CachedNetworkImageProvider(
                rider.image,
                errorListener: (e) {
                  debugPrint(e.toString());
                },
              ),
            ),
          ),
          trailing: Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: Text(
              GlobalFunction.getRidersStatusLocalizationText(
                context: context,
                status: rider.status ? 'Active' : 'Inactive',
              ),
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: rider.status
                        ? AppColor.processing
                        : AppColor.blackColor.withOpacity(0.5),
                  ),
            ),
          ),
          title: Text(
            rider.name,
            style: AppTextStyle(context)
                .subTitle
                .copyWith(fontSize: 16, color: AppColor.blackColor),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Row(
              children: [
                Text(
                  rider.duration,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.blackColor.withOpacity(0.5),
                      ),
                ),
                Gap(5.w),
                CircleAvatar(
                  radius: 3,
                  backgroundColor: AppColor.blackColor.withOpacity(0.2),
                ),
                Gap(5.w),
                Text(
                  rider.id.toString(),
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.blackColor.withOpacity(0.5),
                      ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
