import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/store_controller.dart';
import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/store/layout/store_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class StoreListScreen extends ConsumerStatefulWidget {
  const StoreListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends ConsumerState<StoreListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storeController.notifier).getAllStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stores = ref.watch(storeController.notifier).stores;
    final isLoading = ref.watch(storeController);

    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.whiteColor,
        title: Text(
          'Our Stores',
          style: AppTextStyle(context).title.copyWith(
            color: AppColor.blackColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20.r),
                bottomRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search stores...',
                hintStyle: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.gray,
                ),
                prefixIcon: Icon(Icons.search, color: AppColor.violetColor),
                filled: true,
                fillColor: AppColor.offWhiteColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor.violetColor,
                    ),
                  )
                : stores == null || stores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store_mall_directory_outlined,
                              size: 80.sp,
                              color: AppColor.gray,
                            ),
                            Gap(16.h),
                            Text(
                              'No stores found',
                              style: AppTextStyle(context).bodyText.copyWith(
                                color: AppColor.gray,
                                fontSize: 16.sp,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          if (_searchQuery.isNotEmpty &&
                              !store.name
                                  .toLowerCase()
                                  .contains(_searchQuery.toLowerCase())) {
                            return SizedBox.shrink();
                          }
                          return StoreCard(store: store);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class StoreCard extends StatelessWidget {
  final StoreModel store;

  const StoreCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StoreDetailScreen(store: store),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Hero(
                  tag: 'store_logo_${store.id}',
                  child: Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        store.logo,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColor.gray.withOpacity(0.1),
                            child: Icon(
                              Icons.store,
                              color: AppColor.gray,
                              size: 40.sp,
                            ),
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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.blackColor,
                        ),
                      ),
                      Gap(4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.violetColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              store.brandName,
                              style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: AppColor.violetColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Gap(8.w),
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.sp,
                          ),
                          Gap(4.w),
                          Text(
                            store.totalRating.toStringAsFixed(1),
                            style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Gap(8.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16.sp,
                            color: AppColor.gray,
                          ),
                          Gap(4.w),
                          Expanded(
                            child: Text(
                              store.address,
                              style: AppTextStyle(context).bodyTextSmall.copyWith(
                                color: AppColor.gray,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColor.gray,
                  size: 16.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}