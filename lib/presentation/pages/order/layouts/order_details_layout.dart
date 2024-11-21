import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/controller/order_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_status_card.dart';
import 'package:fluffypawsm/presentation/pages/tracking/tracking_screen.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';


class OrderDetailsLayout extends ConsumerStatefulWidget {
  final Order order;
  const OrderDetailsLayout({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  ConsumerState<OrderDetailsLayout> createState() => _OrderDetailsLayoutState();
}
class _OrderDetailsLayoutState extends ConsumerState<OrderDetailsLayout> {
  // final Order order;
  
  // const OrderDetailsLayout({
  //   Key? key,
  //   required this.order,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(S.of(context).orderDetails),
        toolbarHeight: 70.h,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 22.h).copyWith(right: 20.w),
            child: OrderStatusCard(
              orderStatus: widget.order.status,
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildBottomWidget(context),
      body: SingleChildScrollView(
        child: AnimationLimiter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget)),
              children: [
                Gap(2.h),
                _buildHeaderWidget(context: context),
                _buildShippingInfoCard(context: context),
                _buildCustomerInfoCardWidget(context: context),
                _buildCheckInOutStatus(context: context), // Thêm widget mới
                _buildItemCardWidget(context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildCheckInOutStatus({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Check-in/out Status:',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: AppColor.blackColor, fontWeight: FontWeight.w700),
          ),
          Gap(10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem(
                context: context,
                title: 'Check-in',
                isCompleted: widget.order.checkin,
              ),
              Container(
                height: 40.h,
                width: 1,
                color: AppColor.blackColor.withOpacity(0.1),
              ),
              _buildStatusItem(
                context: context,
                title: 'Check-out',
                isCompleted: widget.order.checkout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem({
    required BuildContext context,
    required String title,
    required bool isCompleted,
  }) {
    return Column(
      children: [
        Icon(
          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompleted ? AppColor.greenCheckin : AppColor.gray,
          size: 24.sp,
        ),
        Gap(5.h),
        Text(
          title,
          style: AppTextStyle(context).bodyTextSmall.copyWith(
            color: isCompleted ? AppColor.greenCheckin : AppColor.gray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  Widget _buildBottomWidget(BuildContext context) {
    // Nếu đã check-in và status là 'Accepted', hiển thị nút Tracking
    if (widget.order.checkin && widget.order.status == 'Accepted') {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: CustomButton(
        buttonText: 'Track Order',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrackingScreen(
                bookingId: widget.order.id,
              ),
            ),
          ).then((_) {
            // Optional: Refresh order data when returning from tracking screen
            ref.read(orderController.notifier).getOrderListWithFilter(
              ref.read(selectedOrderStatus),
            );
          });
        },
      ),
    );
  }
    
    // Nếu status là Pending, giữ nguyên logic cũ
    if (widget.order.status == 'Pending') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Material(
                color: AppColor.red100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: InkWell(
                  onTap: () async {
                    final result = await ref
                        .read(orderController.notifier)
                        .deniedBooking(widget.order.id);
                    
                    if (result) {
                      if (mounted) {
                        GlobalFunction.showCustomSnackbar(
                          message: 'Order has been denied successfully',
                          isSuccess: true,
                        );
                        context.nav.pop();
                      }
                    } else {
                      GlobalFunction.showCustomSnackbar(
                        message: 'Failed to deny order',
                        isSuccess: false,
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    height: 50.h,
                    width: 50.w,
                    child: const Center(
                      child: Icon(
                        Icons.close,
                        color: AppColor.redColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: CustomButton(
                buttonText: S.of(context).accepAndAssignRider,
                onPressed: ref.watch(orderController)
                    ? null
                    : () async {
                        final result = await ref
                            .read(orderController.notifier)
                            .acceptBooking(widget.order.id);
                        
                        if (result) {
                          if (mounted) {
                            GlobalFunction.showCustomSnackbar(
                              message: 'Order has been accepted successfully',
                              isSuccess: true,
                            );
                            context.nav.pop();
                          }
                        } else {
                          GlobalFunction.showCustomSnackbar(
                            message: 'Failed to accept order',
                            isSuccess: false,
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildHeaderWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      color: AppColor.whiteColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#${widget.order.id}',
                    style: AppTextStyle(context).bodyText.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Gap(5.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColor.blackColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      widget.order.paymentMethod,
                      style: AppTextStyle(context)
                          .bodyTextSmall
                          .copyWith(color: AppColor.offWhiteColor),
                    ),
                  )
                ],
              ),
              Gap(5.h),
              Text(
                DateFormat("d MMM, y - hh:mm a").format(widget.order.createDate),
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                    fontSize: 12.sp,
                    color: AppColor.blackColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 16.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).shippingInfo}:',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: AppColor.blackColor, fontWeight: FontWeight.w700),
          ),
          Gap(8.h),
          Text(
            '${S.of(context).address}:',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.blackColor.withOpacity(0.5),
                ),
          ),
          Gap(8.h),
          const Text(
            'Default Address', // Giá trị mặc định cho address
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          Gap(8.h),
          _buildInfoDateCardWidget(context: context),
        ],
      ),
    );
  }
  Container _buildInfoDateCardWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColor.offWhiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${S.of(context).pickUpDate}:',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.blackColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500),
                ),
                Gap(5.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 20.sp,
                    ),
                    Gap(5.w),
                    Text(
                      DateFormat("d MMM, y").format(widget.order.startTime),
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            ),
          ),
          Column(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(top: 5),
                height: 3,
                width: 1,
                color: AppColor.blackColor.withOpacity(0.2),
              ),
            ),
          ),
          Gap(10.w),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${S.of(context).deliveryDate}:',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.blackColor.withOpacity(0.6),
                      fontWeight: FontWeight.w500),
                ),
                Gap(5.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 20.sp,
                    ),
                    Gap(5.w),
                    Text(
                      // Delivery date mặc định = startTime + 2 ngày
                      DateFormat("d MMM, y").format(
                        widget.order.startTime.add(const Duration(days: 2)),
                      ),
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCardWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)
          .copyWith(bottom: 10.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${S.of(context).customerInfo}:',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: AppColor.blackColor, fontWeight: FontWeight.w700),
          ),
          Gap(5.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 24.sp,
              child: Text(
                widget.order.fullName[0].toUpperCase(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              widget.order.fullName,
              style: AppTextStyle(context).bodyText.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColor.blackColor,
                  ),
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Text(
                widget.order.phone,
                style: AppTextStyle(context).bodyText.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.blackColor.withOpacity(0.7),
                    ),
              ),
            ),
            trailing: Material(
              color: AppColor.violetColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              // child: InkWell(
              //   borderRadius: BorderRadius.circular(100),
              //   onTap: () {
              //     // UrlLauncher.launchUrl(
              //     //   Uri.parse("tel://${widget.order.phone}"),
              //     // );
              //   },
              //   child: Container(
              //     height: 45.h,
              //     width: 45.w,
              //     decoration: const BoxDecoration(shape: BoxShape.circle),
              //     child: const Center(
              //       child: Icon(
              //         Icons.call,
              //         color: AppColor.whiteColor,
              //       ),
              //     ),
              //   ),
              // ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildItemCardWidget({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h)
          .copyWith(bottom: 10.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 10.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 ${S.of(context).items}', // Set mặc định là 1 item
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: AppColor.blackColor, fontWeight: FontWeight.w700),
              ),
              Text(
                '\$${widget.order.cost}',
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: AppColor.blackColor, fontWeight: FontWeight.w700),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.serviceName,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.blackColor.withOpacity(0.5),
                      fontSize: 12.sp),
                ),
                Gap(2.h),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 2,
                      backgroundColor: AppColor.blackColor,
                    ),
                    Gap(5.w),
                    Text(
                      "1 x ${widget.order.serviceName}", // Mặc định quantity = 1
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    if (widget.order.status.toLowerCase() == 'pending') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFE9E9),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                onPressed: () {
                  // Handle cancel order
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Handle accept order
                },
                child: const Text(
                  'Accept & Assign for Booking',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}