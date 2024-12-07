import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/service_controller.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:fluffypawsm/presentation/pages/services/layouts/create_store_service_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(serviceController.notifier).getAllServiceByBrandId();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    final isLoading = ref.watch(serviceController);
    final services = ref.watch(serviceController.notifier).servicesBrand;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(S.of(context).service),
        toolbarHeight: 70.h,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(serviceController.notifier).refreshServices();
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : services == null || services.isEmpty
                ? Center(
                    child: Text(
                      S.of(context).noServicesAvailable,
                      style: AppTextStyle(context).bodyText,
                    ),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 10.h),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: ServiceBrandCard(service: services[index]),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class ServiceBrandCard extends ConsumerWidget {
 final ServiceModel service;

 const ServiceBrandCard({
   Key? key,
   required this.service,
 }) : super(key: key);

 @override
 Widget build(BuildContext context, WidgetRef ref) {
   final existingServices = ref.watch(serviceController.notifier).services ?? [];
   final isServiceExists = existingServices.any((s) => s.serviceTypeId == service.id);

   if (isServiceExists) return const SizedBox.shrink();

   return Container(
     margin: EdgeInsets.only(bottom: 16.h),
     decoration: BoxDecoration(
       color: AppColor.whiteColor,
       borderRadius: BorderRadius.circular(12.r),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0, 5),
         ),
       ],
     ),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         // Service Image
         ClipRRect(
           borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
           child: Image.network(
             service.image,
             height: 180.h,
             width: double.infinity,
             fit: BoxFit.cover,
             errorBuilder: (context, error, stackTrace) => Container(
               height: 180.h,
               color: AppColor.gray,
               child: Icon(Icons.error, size: 40.sp, color: AppColor.whiteColor),
             ),
           ),
         ),

         Padding(
           padding: EdgeInsets.all(16.w),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Service Type Badge
               Container(
                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                 decoration: BoxDecoration(
                   color: AppColor.violetColor.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(100),
                 ),
                 child: Text(
                   service.serviceTypeName,
                   style: AppTextStyle(context).bodyTextSmall.copyWith(
                         color: AppColor.violetColor,
                         fontWeight: FontWeight.w500,
                       ),
                 ),
               ),

               Gap(12.h),

               // Service Name
               Text(
                 service.name,
                 style: AppTextStyle(context).title.copyWith(
                       fontSize: 18.sp,
                       fontWeight: FontWeight.w600,
                     ),
               ),

               Gap(8.h),

               // Duration and Price Row
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     children: [
                       Icon(
                         Icons.access_time,
                         size: 18.sp,
                         color: AppColor.gray,
                       ),
                       Gap(6.w),
                       Text(
                         service.duration,
                         style: AppTextStyle(context).bodyTextSmall.copyWith(
                               color: AppColor.gray,
                               fontWeight: FontWeight.w500,
                             ),
                       ),
                     ],
                   ),
                   Text(
                     '${service.cost.toStringAsFixed(0)}đ',
                     style: AppTextStyle(context).title.copyWith(
                           color: AppColor.violetColor,
                           fontWeight: FontWeight.w600,
                         ),
                   ),
                 ],
               ),

               Gap(12.h),

               // Rating and Booking Count
               Row(
                 children: [
                   // Rating
                   Row(
                     children: [
                       Icon(
                         Icons.star,
                         color: Colors.amber,
                         size: 18.sp,
                       ),
                       Gap(4.w),
                       Text(
                         service.totalRating.toString(),
                         style: AppTextStyle(context).bodyTextSmall.copyWith(
                               fontWeight: FontWeight.w500,
                             ),
                       ),
                     ],
                   ),
                   Gap(16.w),
                   // Booking Count
                   Text(
                     '${service.bookingCount} bookings',
                     style: AppTextStyle(context).bodyTextSmall.copyWith(
                           color: AppColor.gray,
                         ),
                   ),
                 ],
               ),

               Gap(16.h),

               // Add Service Button
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: AppColor.violetColor,
                     padding: EdgeInsets.symmetric(vertical: 12.h),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8.r),
                     ),
                   ),
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => StoreServiceFormLayout(
                           serviceId: service.id,
                         ),
                       ),
                     );
                   },
                   child: Text(
                     'Add to Your Branch',
                     style: AppTextStyle(context).bodyText.copyWith(
                       color: Colors.white,
                       fontWeight: FontWeight.bold,
                     ),
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
}