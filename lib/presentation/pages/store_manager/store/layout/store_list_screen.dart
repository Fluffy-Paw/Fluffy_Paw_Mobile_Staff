import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/store_controller.dart';
import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/store/layout/create_store_screen.dart';
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(storeController.notifier).getAllStores();
    });
  }

  Widget build(BuildContext context) {
    final stores = ref.watch(storeController.notifier).stores;
    final isLoading = ref.watch(storeController);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateStoreScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add),
        label: const Text('Add Store'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(stores ?? []),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Management',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Browse all stores',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {},
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildContent(List<StoreModel> stores) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _StoreCard(store: stores[index]),
              childCount: stores.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  final StoreModel store;

  const _StoreCard({required this.store});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoreDetailScreen(store: store),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: AspectRatio(
                aspectRatio: 16/9,
                child: Image.network(
                  store.logo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.store,
                      size: 40.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              store.brandName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 16.sp,
                              color: Colors.amber,
                            ),
                            Gap(4.w),
                            Text(
                              store.totalRating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.location_on,
                        store.address,
                      ),
                      Gap(12.w),
                      _buildInfoChip(
                        Icons.phone,
                        store.phone,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: 4.h,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: const Color(0xFF8B5CF6),
            ),
            Gap(4.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF8B5CF6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}