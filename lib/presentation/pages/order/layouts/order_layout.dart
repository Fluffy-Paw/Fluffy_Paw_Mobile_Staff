import 'dart:convert';

import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/controller/order_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_card.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_tab_card.dart';
import 'package:fluffypawsm/presentation/pages/order/layouts/search_layout.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/earning_history_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class OrderLayout extends ConsumerStatefulWidget {
  const OrderLayout({super.key});

  @override
  ConsumerState<OrderLayout> createState() => _OrderLayoutState();
}

class _OrderLayoutState extends ConsumerState<OrderLayout> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollController scrollController = ScrollController();
  MobileScannerController? _cameraController;
  bool _isFlashOn = false;

  int page = 1;
  final int perPage = 20;
  bool scrollLoading = false;

  // Hardcoded statuses
  final List<String> orderStatuses = [
    'Accepted',
    'Pending',
    'Canceled',
    'Denied',
    'OverTime',
    'Ended'
  ];

  Map<String, int> orderCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Reset page và tab state
      page = 1;
      ref.read(activeOrderTab.notifier).state = 0;
      ref.read(selectedOrderStatus.notifier).state = 'Accepted';

      // Refresh counts và load data đồng thời
      await Future.wait([
        ref.read(orderController.notifier).refreshAllOrderCounts(),
        ref.read(orderController.notifier).getOrderListWithFilter(
              ref.read(selectedOrderStatus),
            ),
      ]);
    });
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      if ((ref.watch(orderController.notifier).dashboard?.orders.length ?? 0) <
              (ref.watch(orderController.notifier).dashboard?.todayOrders ??
                  0) &&
          !scrollLoading) {
        scrollLoading = true;
        page++;
        ref.read(orderController.notifier).getOrderListWithFilter(
              ref.read(selectedOrderStatus),
            );
      }
    }
  }

  int getOrderCountByStatus(List<Order?> orders, String status) {
    return orders.where((order) => order?.status == status).length;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
              ? AppColor.blackColor
              : AppColor.offWhiteColor,
      body: Column(
        children: [
          buildHeader(context: context, ref: ref),
          Flexible(
            flex: 5,
            child: ref.watch(orderController) && !scrollLoading
                ? const EarningHistoryShimmerWidget()
                : buildBody(ref: ref),
          )
        ],
      ),
    );
  }

  Widget buildHeader({required BuildContext context, required WidgetRef ref}) {
    // Watch orderCountsProvider để rebuild khi counts thay đổi
    final orders = ref.watch(orderController.notifier).dashboard?.orders ?? [];
    final counts = ref.watch(orderCountsProvider);

    return Container(
      padding: EdgeInsets.only(top: 50.h, bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                S.of(context).orders,
                style: AppTextStyle(context).subTitle,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  'Today-${DateFormat('dd MMM,yyyy').format(DateTime.now().toLocal())}',
                  style: AppTextStyle(context)
                      .bodyTextSmall
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
              ),
              trailing: Container(
                width: 150.w,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildHeaderButton(
                      onTap: _showQRScanner,
                      icon: Icons.qr_code_scanner,
                      backgroundColor: AppColor.violetColor.withOpacity(0.1),
                      iconColor: AppColor.violetColor,
                    ),
                    SizedBox(width: 8.w),
                    _buildHeaderButton(
                      onTap: () => _showSearchLayout(context),
                      icon: Icons.search,
                      backgroundColor: AppColor.offWhiteColor,
                    ),
                    SizedBox(width: 8.w),
                    _buildHeaderButton(
                      onTap: () {},
                      icon: Icons.calendar_month,
                      backgroundColor: AppColor.offWhiteColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Gap(10.h),
          Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 12,
              ),
              child: ScrollablePositionedList.builder(
                shrinkWrap: true,
                padding: EdgeInsets.only(left: 20.w),
                initialScrollIndex: ref.watch(activeOrderTab),
                itemScrollController: itemScrollController,
                itemCount: orderStatuses.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final status = orderStatuses[index];
                  // Lấy số lượng từ orderCountsProvider
                  final counts = ref.watch(orderCountsProvider);
                  final currentCount = counts[status] ?? 0;

                  return AbsorbPointer(
                    absorbing: ref.watch(orderController),
                    child: InkWell(
                      onTap: () async {
                        page = 1;
                        ref.read(activeOrderTab.notifier).state = index;
                        ref.read(selectedOrderStatus.notifier).state = status;

                        await ref
                            .read(orderController.notifier)
                            .getOrderListWithFilter(
                              status,
                            );
                      },
                      child: OrderTabCard(
                        isActiveTab: ref.watch(activeOrderTab) == index,
                        orderCount: currentCount,
                        orderStatus:
                            GlobalFunction.getOrderStatusLocalizationText(
                          context: context,
                          status: status,
                        ),
                      ),
                    ),
                  );
                },
              )),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color backgroundColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: CircleAvatar(
        radius: 20,
        backgroundColor: backgroundColor,
        child: Icon(
          icon,
          color: iconColor ?? Colors.black87,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget buildBody({required WidgetRef ref}) {
    final orders = ref.watch(orderController.notifier).dashboard?.orders;

    final nonNullOrders =
        orders?.where((order) => order != null).toList() ?? [];

    return nonNullOrders.isNotEmpty
        ? AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                page = 1;
                ref.read(activeOrderTab.notifier).state = 0;
                ref.read(selectedOrderStatus.notifier).state = 'Pending';
                final result = await ref
                    .read(orderController.notifier)
                    .getOrderListWithFilter(
                      ref.read(selectedOrderStatus),
                    );
                debugPrint(result.toString());

                if (result == false) {
                  debugPrint("false");
                  Center(
                    child: Text(
                      S.of(context).orderNotFound,
                      style: AppTextStyle(context)
                          .bodyText
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ); // Ensures orders list is empty
                } else if (itemScrollController.isAttached) {
                  itemScrollController.scrollTo(
                    index: 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                itemCount: nonNullOrders.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 50.0.w,
                      child: FadeInAnimation(
                        child: OrderCard(
                          order: nonNullOrders[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : Center(
            child: Text(
              S.of(context).orderNotFound,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          );
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
                            'Quét mã QR',
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
                          errorBuilder: (context, error, child) {
                            return Center(
                              child: Text(
                                'Lỗi camera: ${error.errorCode}',
                                style: AppTextStyle(context).bodyText.copyWith(
                                      color: Colors.red,
                                    ),
                              ),
                            );
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

  void _showSearchLayout(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchLayout(),
    );
  }

  Future<void> _handleQRData(String qrData) async {
    try {
      final qrContent = jsonDecode(qrData);
      if (qrContent['requiresStaffAuth'] == true) {
        final apiUrl = qrContent['url'];
        final requestBody = jsonEncode(qrContent['data']);

        // Tạm dừng scanner để tránh nhấp nháy
        _cameraController?.stop();

        final result = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Ngăn việc tap ra ngoài
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Column(
              children: [
                Icon(
                  apiUrl.contains('Checkin') ? Icons.login : Icons.logout,
                  size: 48.sp,
                  color: AppColor.violetColor,
                ),
                Gap(12.h),
                Text(
                  apiUrl.contains('Checkin')
                      ? 'Xác nhận Check-in'
                      : 'Xác nhận Check-out',
                  style: AppTextStyle(context).title.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Text(
              'Bạn có chắc chắn muốn ${apiUrl.contains('Checkin') ? 'check-in' : 'check-out'} tại địa điểm này?',
              style: AppTextStyle(context).bodyText,
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: AppColor.violetColor),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                        _cameraController?.start(); // Khởi động lại scanner
                      },
                      child: Text(
                        'Hủy',
                        style: AppTextStyle(context).buttonText.copyWith(
                              color: AppColor.violetColor,
                            ),
                      ),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.violetColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Xác nhận',
                        style: AppTextStyle(context).buttonText.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          ),
        );

        if (result == true) {
          final apiClient = ref.read(apiClientProvider);
          final authToken = await ref.read(hiveStoreService).getAuthToken();

          if (authToken == null) {
            throw Exception('Không tìm thấy token xác thực');
          }

          final response = await apiClient.patch(
            apiUrl,
            data: json.decode(requestBody),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          );

          if (response.statusCode == 200) {
            // Đóng màn hình scanner
            Navigator.pop(context);
            _showSuccessAnimation(apiUrl.contains('Checkin'));
            await ref.read(orderController.notifier).getOrderListWithFilter(
                  ref.read(selectedOrderStatus),
                );
          }
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      _cameraController?.start(); // Khởi động lại scanner nếu có lỗi
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
                          ? 'Check-in thành công!'
                          : 'Check-out thành công!',
                      style: AppTextStyle(context).title.copyWith(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColor.violetColor,
                          ),
                    ),
                    Gap(8.h),
                    Text(
                      'Thao tác đã được xử lý',
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    Gap(24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
                          'Đóng',
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
      // Tự động đóng dialog sau 2 giây
      Future.delayed(const Duration(seconds: 2), () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    });
  }
}
