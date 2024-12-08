// booking_dashboard_screen.dart
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/booking_controller.dart';
import 'package:fluffypawsm/data/models/booking/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BookingDashboardScreen extends ConsumerStatefulWidget {
  const BookingDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BookingDashboardScreen> createState() =>
      _BookingDashboardScreenState();
}

class _BookingDashboardScreenState
    extends ConsumerState<BookingDashboardScreen> {
  String selectedStatus = 'All';
  int selectedStoreIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isDropdownOpen = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingController.notifier).getAllBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> bookings) {
    if (selectedStatus == 'All') {
      return bookings;
    }
    return bookings
        .where((booking) => booking.status == selectedStatus)
        .toList();
  }

  List<dynamic> _getFilteredStores(List<dynamic> stores) {
    if (_searchQuery.isEmpty) {
      return stores;
    }
    return stores
        .where((store) => 'Store #${store.storeId}'
            .toLowerCase()
            .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
Widget build(BuildContext context) {
  final bookingsData = ref.watch(bookingController.notifier).bookings;
  final isLoading = ref.watch(bookingController);

  if (isLoading) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColor.violetColor),
      ),
    );
  }

  if (bookingsData == null || bookingsData.isEmpty) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80.sp,
              color: AppColor.gray,
            ),
            Gap(16.h),
            Text(
              'No bookings found',
              style: AppTextStyle(context).bodyText.copyWith(
                    color: AppColor.gray,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  final currentStore = bookingsData[selectedStoreIndex];
  final List<String> statuses = [
    'All',
    'Pending',
    'Accepted',
    'Ended',
    'Canceled',
    'Denied',
    'OverTime'
  ];
  final filteredBookings = _getFilteredBookings(currentStore.bookings);

  return Scaffold(
    backgroundColor: AppColor.offWhiteColor,
    body: Column(
      children: [
        // Header with revenue info and store dropdown
        _buildStoreHeader(currentStore, bookingsData),
        
        // Status filter
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: statuses.map((status) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(status),
                    selected: selectedStatus == status,
                    onSelected: (bool selected) {
                      setState(() {
                        selectedStatus = selected ? status : 'All';
                      });
                    },
                    backgroundColor: AppColor.offWhiteColor,
                    selectedColor: AppColor.violetColor.withOpacity(0.2),
                    labelStyle: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: selectedStatus == status
                              ? AppColor.violetColor
                              : AppColor.blackColor,
                        ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Booking list
        Expanded(
          child: filteredBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 60.sp,
                        color: AppColor.gray,
                      ),
                      Gap(16.h),
                      Text(
                        'No ${selectedStatus.toLowerCase()} bookings found',
                        style: AppTextStyle(context).bodyText.copyWith(
                              color: AppColor.gray,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(20.w),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    return BookingCard(booking: filteredBookings[index]);
                  },
                ),
        ),
      ],
    ),
  );
}

  Widget _buildStoreHeader(dynamic currentStore, List<dynamic> bookingsData) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.violetColor,
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Store Revenue',
                  style: AppTextStyle(context).bodyText.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
                Gap(8.h),
                Text(
                  'VND ${NumberFormat('#,###').format(currentStore.storeRevenue)}',
                  style: AppTextStyle(context).title.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          // New Store Dropdown
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDropdownOpen = !_isDropdownOpen;
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.store,
                          color: AppColor.violetColor,
                          size: 20.sp,
                        ),
                        Gap(8.w),
                        Expanded(
                          child: Text(
                            'Store #${currentStore.storeId}',
                            style: AppTextStyle(context).bodyText.copyWith(
                                  color: AppColor.blackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(
                          _isDropdownOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: AppColor.violetColor,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isDropdownOpen)
                  Container(
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search stores...',
                              prefixIcon:
                                  Icon(Icons.search, color: AppColor.gray),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                    color: AppColor.gray.withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                    color: AppColor.gray.withOpacity(0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide:
                                    BorderSide(color: AppColor.violetColor),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 8.h),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxHeight: 200.h),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            itemCount: _getFilteredStores(bookingsData).length,
                            itemBuilder: (context, index) {
                              final store =
                                  _getFilteredStores(bookingsData)[index];
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedStoreIndex =
                                        bookingsData.indexOf(store);
                                    _isDropdownOpen = false;
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedStoreIndex ==
                                            bookingsData.indexOf(store)
                                        ? AppColor.violetColor.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.store,
                                        color: selectedStoreIndex ==
                                                bookingsData.indexOf(store)
                                            ? AppColor.violetColor
                                            : AppColor.gray,
                                        size: 20.sp,
                                      ),
                                      Gap(8.w),
                                      Text(
                                        'Store #${store.storeId}',
                                        style: AppTextStyle(context)
                                            .bodyText
                                            .copyWith(
                                              color: selectedStoreIndex ==
                                                      bookingsData
                                                          .indexOf(store)
                                                  ? AppColor.violetColor
                                                  : AppColor.blackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      Spacer(),
                                      if (selectedStoreIndex ==
                                          bookingsData.indexOf(store))
                                        Icon(
                                          Icons.check,
                                          color: AppColor.violetColor,
                                          size: 20.sp,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Gap(16.h),
        ],
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final BookingModel booking;

  const BookingCard({Key? key, required this.booking}) : super(key: key);

  Color _getStatusColor() {
    switch (booking.status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'ended':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      case 'denied':
        return Colors.red.shade700;
      case 'overtime':
        return Colors.purple;
      default:
        return AppColor.gray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      booking.status,
                      style: AppTextStyle(context).bodyTextSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Gap(8.w),
                  Text(
                    '#${booking.code}',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: AppColor.gray,
                          fontFamily: 'Monospace',
                        ),
                  ),
                  Spacer(),
                  Text(
                    'VND ${NumberFormat('#,###').format(booking.cost)}',
                    style: AppTextStyle(context).bodyText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Gap(12.h),
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    icon: Icons.access_time,
                    label: 'Duration',
                    value: '${DateFormat('HH:mm').format(booking.startTime)} - '
                        '${DateFormat('HH:mm').format(booking.endTime)}',
                  ),
                  Gap(16.w),
                  _buildInfoItem(
                    context,
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: DateFormat('MMM dd, yyyy').format(booking.startTime),
                  ),
                  Gap(16.w),
                  _buildInfoItem(
                    context,
                    icon: Icons.payment,
                    label: 'Payment',
                    value: booking.paymentMethod,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: AppColor.gray,
              ),
              Gap(4.w),
              Text(
                label,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.gray,
                      fontSize: 12.sp,
                    ),
              ),
            ],
          ),
          Gap(2.h),
          Text(
            value,
            style: AppTextStyle(context).bodyTextSmall.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Custom painter for decorative dashboard pattern
class DashboardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final cellSize = 30.0;

    for (double x = 0; x < size.width + cellSize; x += cellSize) {
      for (double y = 0; y < size.height + cellSize; y += cellSize) {
        path.addOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 4,
            height: 4,
          ),
        );
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Booking Detail Screen
class BookingDetailScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingDetailScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.offWhiteColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: AppColor.violetColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColor.violetColor,
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: DashboardPatternPainter(),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Booking Details',
                              style: AppTextStyle(context).title.copyWith(
                                    color: Colors.white,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Gap(8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                '#${booking.code}',
                                style: AppTextStyle(context).bodyText.copyWith(
                                      color: Colors.white,
                                      fontFamily: 'Monospace',
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -20.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                ),
                child: Column(
                  children: [
                    // Status and Amount Card
                    Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppColor.offWhiteColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                      color: AppColor.gray,
                                    ),
                              ),
                              Gap(4.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(booking.status)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  booking.status,
                                  style: AppTextStyle(context)
                                      .bodyText
                                      .copyWith(
                                        color: _getStatusColor(booking.status),
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Amount',
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(
                                      color: AppColor.gray,
                                    ),
                              ),
                              Gap(4.h),
                              Text(
                                'VND ${NumberFormat('#,###').format(booking.cost)}',
                                style: AppTextStyle(context).title.copyWith(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Booking Information
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Information',
                            style: AppTextStyle(context).title.copyWith(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Gap(16.h),
                          _buildDetailCard(
                            context,
                            [
                              _buildDetailItem(
                                context,
                                icon: Icons.calendar_today,
                                title: 'Date',
                                value: DateFormat('MMMM dd, yyyy')
                                    .format(booking.startTime),
                              ),
                              _buildDetailItem(
                                context,
                                icon: Icons.access_time,
                                title: 'Time',
                                value:
                                    '${DateFormat('HH:mm').format(booking.startTime)} - '
                                    '${DateFormat('HH:mm').format(booking.endTime)}',
                              ),
                              _buildDetailItem(
                                context,
                                icon: Icons.payment,
                                title: 'Payment Method',
                                value: booking.paymentMethod,
                              ),
                              _buildDetailItem(
                                context,
                                icon: Icons.history,
                                title: 'Created',
                                value: DateFormat('MMM dd, yyyy HH:mm')
                                    .format(booking.createDate),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (booking.description.isNotEmpty) ...[
                      Gap(24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Description',
                              style: AppTextStyle(context).title.copyWith(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Gap(16.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: AppColor.offWhiteColor,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Text(
                                booking.description,
                                style: AppTextStyle(context).bodyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Gap(20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'ended':
        return Colors.blue;
      case 'canceled':
        return Colors.red;
      case 'denied':
        return Colors.red.shade700;
      case 'overtime':
        return Colors.purple;
      default:
        return AppColor.gray;
    }
  }

  Widget _buildDetailCard(BuildContext context, List<Widget> items) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.offWhiteColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: AppColor.violetColor,
              size: 20.sp,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                        color: AppColor.gray,
                      ),
                ),
                Gap(4.h),
                Text(
                  value,
                  style: AppTextStyle(context).bodyText.copyWith(
                        fontWeight: FontWeight.w500,
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
