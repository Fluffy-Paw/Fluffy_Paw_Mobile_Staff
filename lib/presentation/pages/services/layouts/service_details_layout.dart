import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/service_controller.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/data/models/service/store_service.dart';
import 'package:fluffypawsm/presentation/pages/services/create_store_service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ServiceDetailsLayout extends ConsumerStatefulWidget {
  //final int serviceId;
  final Service service;

  const ServiceDetailsLayout(
      {Key? key,
      //required this.serviceId,
      required this.service})
      : super(key: key);

  @override
  ConsumerState<ServiceDetailsLayout> createState() =>
      _ServiceDetailsLayoutState();
}

class _ServiceDetailsLayoutState extends ConsumerState<ServiceDetailsLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(serviceController.notifier)
          .getAllStoreServiceByServiceId(widget.service.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    final isLoading = ref.watch(serviceController);
    final currentService = ref.watch(serviceController.notifier).currentService;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        title: Text(widget.service.name),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Text(
              GlobalFunction.getRidersStatusLocalizationText(
                status:
                    currentService?.isAvailable == true ? 'Active' : 'Inactive',
                context: context,
              ),
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: currentService?.isAvailable == true
                      ? AppColor.processing
                      : AppColor.blackColor.withOpacity(0.5),
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentService == null
              ? const Center(child: Text('No data'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(2.h),
                      _buildInfoCardWidget(
                          context: context, rider: currentService),
                      Gap(30.h),
                      // Trong ServiceDetailsLayout, thêm button bên cạnh nút Edit

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              S.of(context).serviceschedule,
                              style: AppTextStyle(context).title,
                            ),
                            Row(
                              children: [
                                // Nút Create mới
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreServiceView(
                                          serviceId: widget.service.id,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.add_circle_outline,
                                        color: AppColor.violetColor,
                                      ),
                                      Gap(5.w),
                                      Container(
                                        width: 150
                                            .w, // Điều chỉnh chiều rộng phù hợp
                                        child: Text(
                                          S.of(context).createnewschedule,
                                          style: AppTextStyle(context)
                                              .bodyText
                                              .copyWith(
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColor.violetColor),
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Gap(16.w),
                                // // Nút Edit hiện tại
                                // GestureDetector(
                                //   onTap: () {},
                                //   child: Row(
                                //     children: [
                                //       SvgPicture.asset(Assets.svg.edit),
                                //       Gap(5.w),
                                //       Text(
                                //         S.of(context).edit,
                                //         style: AppTextStyle(context)
                                //             .bodyText
                                //             .copyWith(
                                //                 fontWeight: FontWeight.w500,
                                //                 color: AppColor.violetColor),
                                //       )
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Gap(20.h),
                      _buildPersonalInfoCard(
                          context: context, rider: currentService),
                      Gap(20.h),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCardWidget(
      {required BuildContext context, required StoreService rider}) {
    final currentService = ref.watch(serviceController.notifier).currentService;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 20.h,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(14.r),
          bottomRight: Radius.circular(14.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: rider.id,
                child: CircleAvatar(
                  radius: 45.r,
                  backgroundImage: CachedNetworkImageProvider(
                    widget.service.image,
                  ),
                ),
              ),
              Gap(16.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.service.name,
                    style: AppTextStyle(context).title,
                  ),
                  Gap(5.h),
                  Text(
                    widget.service.serviceTypeName,
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.w500,
                          color:
                              colors(context).bodyTextColor!.withOpacity(0.7),
                        ),
                  ),
                  Gap(5.h),
                  Text(
                    'Trạng thái ${rider.status}',
                    style: AppTextStyle(context)
                        .bodyText
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              )
            ],
          ),
          Gap(20.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCard(
                  type: 'job',
                  text: S.of(context).completeJobIn,
                  icon: Assets.svg.done,
                  count: GlobalFunction.numberLocalization(widget.service.cost),
                  color: AppColor.lime500,
                  context: context,
                ),
                Gap(10.w),
                _buildCard(
                  type: 'cash',
                  text: S.of(context).cashCollectedIn,
                  icon: Assets.svg.doller,
                  count: GlobalFunction.numberLocalization(
                      widget.service.duration),
                  color: AppColor.violetColor,
                  context: context,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCard({
    required String type,
    required String text,
    required String icon,
    required String count,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Wrap(
                direction: Axis.vertical,
                children: [
                  Text(
                    text,
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontSize: 13.sp),
                  ),
                  Text(
                    DateFormat.MMMM().format(DateTime.now()),
                    style: AppTextStyle(context)
                        .bodyTextSmall
                        .copyWith(fontSize: 13.sp),
                  ),
                ],
              ),
              Gap(10.w),
              SvgPicture.asset(
                icon,
                height: 30,
                color: type == 'cash' ? AppColor.violetColor : null,
              )
            ],
          ),
          Gap(10.h),
          Text(
            type == 'cash' ? '\$$count' : count.toString(),
            style: AppTextStyle(context).title,
          )
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(
      {required BuildContext context, required StoreService rider}) {
    // Lấy danh sách services từ controller
    final listTimeService =
        ref.watch(serviceController.notifier).listTimeService ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...listTimeService
              .map((timeService) => Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Store ID',
                                          value: timeService.storeId.toString(),
                                          context: context),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Service ID',
                                          value:
                                              timeService.serviceId.toString(),
                                          context: context),
                                    ),
                                  ],
                                ),
                                Gap(16.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Start Time',
                                          value: DateFormat('dd/MM/yyyy HH:mm')
                                              .format(timeService.startTime),
                                          context: context),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Status',
                                          value: timeService.status,
                                          context: context),
                                    ),
                                  ],
                                ),
                                Gap(16.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Limit Pet Owner',
                                          value: timeService.limitPetOwner
                                              .toString(),
                                          context: context),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: _buildInfoColumn(
                                          title: 'Current Pet Owner',
                                          value: timeService.currentPetOwner
                                              .toString(),
                                          context: context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Nút Edit
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoreServiceView(
                                    serviceId: rider.id,
                                    scheduleToEdit: CreateScheduleRequest(
                                      startTime: timeService.startTime,
                                      limitPetOwner: timeService.limitPetOwner,
                                    ),
                                    onUpdate: (updatedSchedule) async {
                                      // Gọi API update schedule
                                      final success = await ref
                                          .read(serviceController.notifier)
                                          .updateStoreService(
                                            id: timeService
                                                .id, // ID của schedule cần update
                                            startTime:
                                                updatedSchedule.startTime,
                                            limitPetOwner:
                                                updatedSchedule.limitPetOwner,
                                          );

                                      if (!context.mounted) return;

                                      if (success) {
                                        // Nếu update thành công
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Schedule updated successfully')),
                                        );

                                        // Refresh lại danh sách
                                        await ref
                                            .read(serviceController.notifier)
                                            .getAllStoreServiceByServiceId(
                                                rider.id);

                                        // Pop back về màn hình trước
                                        Navigator.pop(context);
                                      } else {
                                        // Nếu update thất bại
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Failed to update schedule')),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              );
                              debugPrint(
                                  'Edit time service ID: ${timeService.id}');
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColor.violetColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: SvgPicture.asset(
                                Assets.svg.edit,
                                width: 20.w,
                                height: 20.w,
                                color: AppColor.violetColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              // Hiện dialog xác nhận trước khi xóa
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Confirm Delete'),
                                  content: Text(
                                      'Are you sure you want to delete this schedule?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                // Gọi API xóa schedule
                                final success = await ref
                                    .read(serviceController.notifier)
                                    .deleteStoreService(timeService.id);

                                if (!context.mounted) return;

                                if (success) {
                                  // Nếu xóa thành công
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Schedule deleted successfully')),
                                  );

                                  // Refresh lại danh sách
                                  await ref
                                      .read(serviceController.notifier)
                                      .getAllStoreServiceByServiceId(
                                          widget.service.id);
                                } else {
                                  // Nếu xóa thất bại
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Failed to delete schedule')),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                size: 20.w,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (timeService != listTimeService.last)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Divider(
                            color: AppColor.blackColor.withOpacity(0.1),
                            height: 1,
                          ),
                        ),
                    ],
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
      {required String title,
      required String value,
      required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle(context).bodyText.copyWith(
              color: colors(context).bodyTextSmallColor,
              fontWeight: FontWeight.w500),
        ),
        Gap(10.h),
        Text(
          value,
          style: AppTextStyle(context)
              .bodyText
              .copyWith(fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
