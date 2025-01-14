import 'dart:convert';

import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/controller/order_controller.dart';
import 'package:fluffypawsm/data/controller/pet_controller.dart';
import 'package:fluffypawsm/data/models/conversation/conversation_model.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/repositories/conversation_service_provider.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/check_in_check_out/checkin_confirmation_screen.dart';
import 'package:fluffypawsm/presentation/pages/conversation/layout/chat_screen.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_status_card.dart';
import 'package:fluffypawsm/presentation/pages/pet/pet_detail_screen.dart';
import 'package:fluffypawsm/presentation/pages/tracking/tracking_screen.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
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
                child: FadeInAnimation(child: widget),
              ),
              children: [
                Gap(2.h),
                _buildHeaderWidget(context: context),
                _buildShippingInfoCard(context: context),
                _buildCustomerInfoCardWidget(context: context),
                _buildPetCard(context: context), // Add this line
                _buildCheckInOutStatus(context: context),
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
    // Case 1: Pending Order - Show Accept/Deny buttons
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
            Gap(12.w),
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

    // Case 2: Accepted Order but not checked in
    if (widget.order.status == 'Accepted' && !widget.order.checkin) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomButton(
          buttonText: 'Check-in',
          onPressed: () => _showQRScanner(),
        ),
      );
    }

    // Case 3: Show checkout for both active and ended orders if not checked out
    if ((widget.order.status == 'Accepted' || widget.order.status == 'Ended') &&
        widget.order.checkin &&
        !widget.order.checkout) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                buttonText: 'Check-out',
                onPressed: widget.order.status == 'Accepted'
                    ? () => _showQRScanner()
                    : null,
                // Disable the button if status is not 'Ended'
              ),
            ),
            Gap(12.w),
            Expanded(
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
                    ref.read(orderController.notifier).getOrderListWithFilter(
                          ref.read(selectedOrderStatus),
                        );
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    // Case 4: If order is checked out, only show tracking
    if ((widget.order.status == 'Accepted' || widget.order.status == 'Ended') &&
        widget.order.checkout) {
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
              ref.read(orderController.notifier).getOrderListWithFilter(
                    ref.read(selectedOrderStatus),
                  );
            });
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _showQRScanner() async {
    final status = await Permission.camera.request();
    if (status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cần quyền truy cập camera để quét mã QR')),
        );
      }
      return;
    }

    _cameraController?.dispose();
    _cameraController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
      returnImage: false,
    );

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: AppColor.violetColor,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24.r)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      Gap(16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _cameraController?.dispose();
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            widget.order.checkin
                                ? 'Scan to Check-out'
                                : 'Scan to Check-in',
                            style: AppTextStyle(context).title.copyWith(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isFlashOn ? Icons.flash_on : Icons.flash_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _isFlashOn = !_isFlashOn;
                                _cameraController?.toggleTorch();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      if (_cameraController != null)
                        MobileScanner(
                          controller: _cameraController!,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            if (barcodes.isNotEmpty) {
                              final qrData = barcodes.first.rawValue;
                              if (qrData != null) {
                                _handleQRData(qrData);
                              }
                            }
                          },
                        ),
                      Center(
                        child: Container(
                          width: 200.w,
                          height: 200.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColor.violetColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
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
  }

  Widget _buildPetCard({required BuildContext context}) {
    final petDetails =
        ref.watch(petDetailControllerProvider(widget.order.petId));

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      margin: EdgeInsets.symmetric(horizontal: 20.w).copyWith(top: 10.h),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet Information',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                color: AppColor.blackColor, fontWeight: FontWeight.w700),
          ),
          Gap(10.h),
          petDetails.when(
            data: (pet) => InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailScreen(petId: widget.order.petId),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: AppColor.violetColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: pet.image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(pet.image!, fit: BoxFit.cover),
                          )
                        : Icon(Icons.pets,
                            color: AppColor.violetColor, size: 24.sp),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: AppTextStyle(context)
                              .bodyText
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Gap(4.h),
                        Text(
                          '${pet.petType.name} • ${pet.age}',
                          style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: AppColor.blackColor.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: AppColor.blackColor.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Center(
              child: Text('Error: ${error.toString()}'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleQRData(String qrData) async {
    try {
      final qrContent = jsonDecode(qrData);
      if (qrContent['requiresStaffAuth'] == true) {
        // Close QR scanner first
        _cameraController?.stop();
        Navigator.pop(context);

        // Check if it's a checkout operation by looking at the URL
        final bool isCheckout =
            qrContent['url'].toString().toLowerCase().contains('checkout');

        // Navigate to confirmation screen
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => CheckinConfirmationScreen(
              orderId: widget.order.id,
              apiUrl: qrContent['url'] as String,
              requestData: qrContent['data'] as Map<String, dynamic>,
              isCheckout:
                  isCheckout, // Pass the correct flag based on the operation
              serviceTypeId: widget.order.serviceTypeId,
            ),
          ),
        );

        // If check-in/out was successful, refresh the data
        if (result == true) {
          await ref.read(orderController.notifier).getOrderListWithFilter(
                ref.read(selectedOrderStatus),
              );
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      }
    }
  }

  void _showSuccessAnimation(bool isCheckin) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: AppColor.violetColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCheckin ? Icons.login : Icons.logout,
                              color: AppColor.violetColor,
                              size: 40.sp,
                            ),
                          ),
                        );
                      },
                    ),
                    Gap(16.h),
                    Text(
                      isCheckin
                          ? 'Check-in successful!'
                          : 'Check-out successful!',
                      style: AppTextStyle(context).title.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.violetColor,
                          ),
                    ),
                    Gap(8.h),
                    Text(
                      'Operation has been processed',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    Gap(24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Return to order detail
                          // Refresh the order detail page
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.violetColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Close',
                          style: AppTextStyle(context).buttonText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).then((_) {
      // Auto close after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
          // Refresh order detail
          setState(() {});
        }
      });
    });
  }

// Add these properties to the state class
  MobileScannerController? _cameraController;
  bool _isFlashOn = false;

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
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
                    '#${widget.order.code}',
                    style: AppTextStyle(context).bodyText.copyWith(
                        color: AppColor.blackColor,
                        fontWeight: FontWeight.w500),
                  ),
                  Gap(5.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
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
                DateFormat("d MMM, y - hh:mm a")
                    .format(widget.order.createDate),
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
          //Gap(8.h),
          // Text(
          //   '${S.of(context).address}:',
          //   style: AppTextStyle(context).bodyTextSmall.copyWith(
          //         color: AppColor.blackColor.withOpacity(0.5),
          //       ),
          // ),
          // Gap(8.h),
          // const Text(
          //   'Default Address', // Giá trị mặc định cho address
          //   style: TextStyle(
          //     color: Colors.black,
          //     fontWeight: FontWeight.w500,
          //   ),
          // ),
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
        children: [
          Expanded(
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
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        DateFormat("d MMM, y").format(widget.order.startTime),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              children: List.generate(
                5,
                (index) => Container(
                  margin: EdgeInsets.only(top: 5.h),
                  height: 3,
                  width: 1,
                  color: AppColor.blackColor.withOpacity(0.2),
                ),
              ),
            ),
          ),
          Expanded(
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
                      size: 18.sp,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        DateFormat("d MMM, y").format(widget.order.endDate),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.blackColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: AppColor.violetColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () async {
                    try {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      // Check existing conversation
                      final existingConv = await ref
                          .read(conversationServiceProvider)
                          .getExistingConversation(widget.order.petOwnerAccountId);

                      if (existingConv != null) {
                        // Use existing conversation
                        final conversation = ConversationModel.fromMap(existingConv.data['data']);
                        if (mounted) {
                          Navigator.pop(context); // Close loading
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: conversation.id,
                                poAccountId: conversation.staffAccountId,
                                storeName: widget.order.fullName,
                              ),
                            ),
                          );
                        }
                      } else {
                        // Create new conversation
                        final response = await ref
                            .read(conversationServiceProvider)
                            .createConversation(widget.order.petOwnerAccountId);

                        if (response.statusCode == 200) {
                          final newConversation = ConversationModel.fromMap(response.data['data']);
                          if (mounted) {
                            Navigator.pop(context); // Close loading
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  conversationId: newConversation.id,
                                  poAccountId: newConversation.staffAccountId,
                                  storeName: widget.order.fullName,
                                ),
                              ),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      Navigator.pop(context); // Close loading
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error starting conversation: $e')),
                      );
                    }
                  },
                  child: Container(
                    height: 45.h,
                    width: 45.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: const Center(
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              Gap(8.w),
              // Material(
              //   color: AppColor.violetColor,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(100),
              //   ),
              //   child: InkWell(
              //     borderRadius: BorderRadius.circular(100),
              //     onTap: () {
              //       // Handle call
              //     },
              //     child: Container(
              //       height: 45.h,
              //       width: 45.w,
              //       decoration: const BoxDecoration(shape: BoxShape.circle),
              //       child: const Center(
              //         child: Icon(
              //           Icons.call,
              //           color: AppColor.whiteColor,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
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
                '${widget.order.cost}VND',
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
