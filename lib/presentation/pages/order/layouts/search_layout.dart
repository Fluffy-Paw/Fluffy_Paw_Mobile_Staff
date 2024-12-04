import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/order_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/order/layouts/order_details_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class SearchLayout extends ConsumerStatefulWidget {
  const SearchLayout({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchLayout> createState() => _SearchLayoutState();
}

class _SearchLayoutState extends ConsumerState<SearchLayout> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  Order? _searchResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final searches = await ref.read(orderController.notifier).getRecentSearches();
    setState(() {
      _recentSearches = searches;
    });
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResult = null;
    });

    try {
      final result = await ref.read(orderController.notifier).searchOrderById(query);
      
      if (result != null) {
        await ref.read(orderController.notifier).saveRecentSearch(query);
        await _loadRecentSearches();
      }

      setState(() {
        _searchResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),

          // Search header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            height: 56.h,
            child: Row(
              children: [
                // Back button
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColor.violetColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      size: 20.sp,
                      color: AppColor.violetColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Gap(12.w),
                // Search box
                Expanded(
                  child: Container(
                    height: 40.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.w),
                          child: Icon(
                            Icons.search,
                            size: 20.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: AppTextStyle(context).bodyText.copyWith(
                              fontSize: 14.sp,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter booking ID...',
                              hintStyle: AppTextStyle(context).bodyText.copyWith(
                                color: Colors.grey[500],
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                            ),
                            onSubmitted: (query) async {
                              if (query.isNotEmpty) {
                                setState(() => _isLoading = true);
                                final result = await ref
                                    .read(orderController.notifier)
                                    .searchOrderById(query);
                                if (result != null) {
                                  await ref
                                      .read(orderController.notifier)
                                      .saveRecentSearch(query);
                                  await _loadRecentSearches();
                                }
                                setState(() {
                                  _searchResult = result;
                                  _isLoading = false;
                                });
                              }
                            },
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              size: 20.sp,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchResult = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recent searches header
          if (!_isLoading && _searchResult == null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: AppTextStyle(context).bodyText.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  if (_recentSearches.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await ref.read(hiveStoreService).saveRecentSearches([]);
                        setState(() {
                          _recentSearches.clear();
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                      ),
                      child: Text(
                        'Clear All',
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.violetColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColor.violetColor,
                    ),
                  )
                : _searchResult != null
                    ? _buildSearchResult()
                    : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }


  Widget _buildSearchResult() {
  if (_searchResult == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48.sp,
            color: Colors.grey.withOpacity(0.5),
          ),
          Gap(8.h),
          Text(
            'No booking found',
            style: AppTextStyle(context).bodyText.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  return Padding(
    padding: EdgeInsets.all(16.w),
    child: Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${_searchResult!.id}',
                  style: AppTextStyle(context).bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                _buildStatusChip(_searchResult!.status),
              ],
            ),
            Gap(8.h),
            _buildInfoRow('Customer', _searchResult!.fullName),
            _buildInfoRow('Phone', _searchResult!.phone),
            _buildInfoRow('Service', _searchResult!.serviceName),
            _buildInfoRow(
              'Date', 
              DateFormat('dd/MM/yyyy').format(_searchResult!.startTime)
            ),
            _buildInfoRow('Payment', _searchResult!.paymentMethod),
            _buildInfoRow('Cost', '${_searchResult!.cost} VND'),
            Gap(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Đóng search layout
                  Navigator.pop(context);
                  
                  // Navigate to OrderDetailsLayout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsLayout(
                        order: _searchResult!,
                      ),
                    ),
                  ).then((_) {
                    // Refresh order list when returning from details
                    ref.read(orderController.notifier).getOrderListWithFilter(
                      ref.read(selectedOrderStatus),
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.violetColor,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'View Details',
                  style: AppTextStyle(context).buttonText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Hàm helper để hiển thị status với màu sắc tương ứng
Widget _buildStatusChip(String status) {
  final statusColors = {
    'Pending': Colors.orange,
    'Accepted': Colors.green,
    'Canceled': Colors.red,
    'Denied': Colors.grey,
    'OverTime': Colors.purple,
    'Ended': Colors.blue,
  };

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: (statusColors[status] ?? Colors.grey).withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      status,
      style: AppTextStyle(context).bodyTextSmall.copyWith(
        color: statusColors[status] ?? Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget _buildInfoRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            '$label:',
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

  // Widget _buildStatusChip(String status) {
  //   final statusColors = {
  //     'Pending': Colors.orange,
  //     'Accepted': Colors.green,
  //     'Canceled': Colors.red,
  //     'Denied': Colors.grey,
  //     'OverTime': Colors.purple,
  //     'Ended': Colors.blue,
  //   };

  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
  //     decoration: BoxDecoration(
  //       color: (statusColors[status] ?? Colors.grey).withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12.r),
  //     ),
  //     child: Text(
  //       status,
  //       style: AppTextStyle(context).bodyTextSmall.copyWith(
  //         color: statusColors[status] ?? Colors.grey,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildInfoRow(String label, String value) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(vertical: 4.h),
  //     child: Row(
  //       children: [
  //         Text(
  //           '$label: ',
  //           style: AppTextStyle(context).bodyTextSmall.copyWith(
  //             color: Colors.grey,
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: AppTextStyle(context).bodyTextSmall,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48.sp,
              color: Colors.grey.withOpacity(0.5),
            ),
            Gap(12.h),
            Text(
              'No recent searches',
              style: AppTextStyle(context).bodyText.copyWith(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _recentSearches.length,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemBuilder: (context, index) {
        final search = _recentSearches[index];
        return InkWell(
          onTap: () async {
            _searchController.text = search;
            setState(() => _isLoading = true);
            final result = await ref
                .read(orderController.notifier)
                .searchOrderById(search);
            setState(() {
              _searchResult = result;
              _isLoading = false;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.history,
                    size: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Text(
                    search,
                    style: AppTextStyle(context).bodyText.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.sp,
                    color: Colors.grey[500],
                  ),
                  onPressed: () async {
                    setState(() {
                      _recentSearches.removeAt(index);
                    });
                    await ref
                        .read(hiveStoreService)
                        .saveRecentSearches(_recentSearches);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}