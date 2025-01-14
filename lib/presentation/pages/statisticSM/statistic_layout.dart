import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/statistics_controller.dart';
import 'package:fluffypawsm/data/models/static/statistics_model.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/components/pending_order_card.dart';
import 'package:fluffypawsm/presentation/widgets/component/home_shimmer.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DashboardSMLayout extends ConsumerStatefulWidget {
  const DashboardSMLayout({super.key});

  @override
  ConsumerState<DashboardSMLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends ConsumerState<DashboardSMLayout> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(statisticsController.notifier).getStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsController.notifier).statistics;
    final isLoading = ref.watch(statisticsController);

    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
              ? AppColor.blackColor
              : AppColor.offWhiteColor,
      body: isLoading
          ? const ShimmerWidget()
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(statisticsController.notifier).getStatistics();
              },
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(20.h),
                          _buildStatisticsCards(statistics),
                          Gap(24.h),
                          if (statistics != null) ...[
                            _buildRevenueChart(statistics),
                            Gap(24.h),
                            _buildTopServices(statistics),
                            Gap(24.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColor.violetColor,
                AppColor.violetColor.withOpacity(0.8),
                AppColor.violetColor.withOpacity(0.6),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -50.h,
                right: -50.w,
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -60.h,
                left: -30.w,
                child: Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Thống kê doanh thu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Chào mừng trở lại! Đây là doanh thu của bạn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
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

  Widget _buildStatisticsCards(Statistics? statistics) {
  if (statistics == null) return const SizedBox.shrink();

  final stats = [
    {
      'title': 'Tổng số đơn hàng',
      'value': statistics.numOfAll,
      'icon': Icons.shopping_bag_outlined,
      'color': AppColor.violetColor,
    },
    {
      'title': 'Chờ xử lý',
      'value': statistics.numOfPending,
      'icon': Icons.pending_outlined,
      'color': Colors.orange,
    },
    {
      'title': 'Đã đồng ý',
      'value': statistics.numOfAccepted,
      'icon': Icons.check_circle_outline,
      'color': Colors.green,
    },
    {
      'title': 'Đã huỷ',
      'value': statistics.numOfCanceled,
      'icon': Icons.cancel_outlined,
      'color': Colors.red,
    },
  ];

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16.w,
      mainAxisSpacing: 16.h,
      // Điều chỉnh tỷ lệ và chiều cao cố định
      childAspectRatio: 1.5,
      mainAxisExtent: 90.h, // Giảm chiều cao xuống
    ),
    itemCount: stats.length,
    itemBuilder: (context, index) {
      final stat = stats[index];
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (stat['color'] as Color).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 80.w, // Giảm kích thước pattern trang trí
                height: 80.w,
                decoration: BoxDecoration(
                  color: (stat['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(12.w), // Giảm padding
              child: Row(
                children: [
                  Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 20.sp, // Giảm size icon
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Thêm này để column chỉ lấy không gian cần thiết
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['value'].toString(),
                          style: TextStyle(
                            fontSize: 18.sp, // Giảm font size
                            fontWeight: FontWeight.bold,
                            color: stat['color'] as Color,
                          ),
                        ),
                        Text(
                          stat['title'].toString(),
                          style: TextStyle(
                            fontSize: 12.sp, // Giảm font size
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildRevenueChart(Statistics statistics) {
 final now = DateTime.now();
 final recentMonths = List.generate(3, (index) {
   final month = DateTime(now.year, now.month - (2 - index));
   return DateFormat('MMM').format(month);
 });

 final currentMonthIndex = now.month - 1;
 final startIndex = currentMonthIndex - 2;
 final recentRevenues = statistics.revenues
     .sublist(startIndex < 0 ? 0 : startIndex, currentMonthIndex + 1)
     .map((e) => e.toDouble())
     .toList();
 
 while (recentRevenues.length < 3) {
   recentRevenues.insert(0, 0);
 }

 final maxValue = recentRevenues.reduce((a, b) => a > b ? a : b);

 return Container(
   padding: EdgeInsets.all(20.w),
   decoration: BoxDecoration(
     color: Colors.white,
     borderRadius: BorderRadius.circular(20.r),
     boxShadow: [BoxShadow(
       color: Colors.grey.withOpacity(0.08),
       blurRadius: 20,
       offset: const Offset(0, 4),
     )],
   ),
   child: Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text('Thống kê doanh thu', 
         style: TextStyle(
           fontSize: 20.sp,
           fontWeight: FontWeight.bold,
         )
       ),
       SizedBox(height: 30.h),
       SizedBox(
         height: 200.h,
         child: Row(
           children: [
             SizedBox(
               width: 50.w,
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(NumberFormat.compact().format(maxValue),
                     style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                   Text(NumberFormat.compact().format(maxValue/2),
                     style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                   Text('0',
                     style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                 ],
               ),
             ),
             Expanded(
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 crossAxisAlignment: CrossAxisAlignment.end,
                 children: List.generate(3, (index) {
                   final height = maxValue == 0 ? 0 : 
                     (recentRevenues[index] / maxValue * 150.h);
                   return Column(
                     mainAxisAlignment: MainAxisAlignment.end,
                     children: [
                       Container(
                         width: 40.w,
                         height: height.toDouble(),
                         decoration: BoxDecoration(
                           gradient: LinearGradient(
                             begin: Alignment.topCenter,
                             end: Alignment.bottomCenter,
                             colors: [
                               AppColor.violetColor,
                               AppColor.violetColor.withOpacity(0.5),
                             ],
                           ),
                           borderRadius: BorderRadius.vertical(
                             top: Radius.circular(6.r)
                           ),
                         ),
                       ),
                       SizedBox(height: 8.h),
                       Text(recentMonths[index],
                         style: TextStyle(
                           fontSize: 12.sp,
                           color: Colors.grey[600]
                         ),
                       ),
                     ],
                   );
                 }),
               ),
             ),
           ],
         ),
       ),
     ],
   ),
 );
}

  Widget _buildTopServices(Statistics statistics) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Các dịch vụ được ưa chuộng',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Gap(16.h),
          ...statistics.topServices
              .map((service) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColor.violetColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            Icons.medical_services_outlined,
                            color: AppColor.violetColor,
                            size: 24.sp,
                          ),
                        ),
                        Gap(16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.serviceName,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                service.storeName,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: AppColor.violetColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            '${service.numberOfBooking} số đặt chỗ',
                            style: TextStyle(
                              color: AppColor.violetColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }
}
