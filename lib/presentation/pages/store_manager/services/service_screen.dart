import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/service_brand_controller.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/services/create_service.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/services/service_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ServiceManagementScreen extends ConsumerStatefulWidget {
  const ServiceManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceManagementScreen> createState() => _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends ConsumerState<ServiceManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Delay provider modification
    Future.microtask(() {
      ref.read(serviceController.notifier).getAllServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(serviceController);
    final services = ref.watch(serviceController.notifier).services;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: _buildAppBar(),
      floatingActionButton: _buildAddButton(),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildContent(services ?? []),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý dịch vụ',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            'Quản lý dịch vụ của thương hiệu',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // Show filter options
          },
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildContent(List<ServiceModel> services) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ServiceCard(
                service: services[index],
                onEdit: () => _handleEdit(services[index]),
                onDelete: () => _handleDelete(services[index].id),
                onToggleStatus: () => _handleToggleStatus(services[index]),
              ),
              childCount: services.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return FloatingActionButton.extended(
      onPressed: _handleAdd,
      backgroundColor: const Color(0xFF8B5CF6),
      icon: const Icon(Icons.add),
      label: const Text('Thêm dịch vụ'),
    );
  }

  void _handleAdd() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CreateServiceScreen(),
    ),
  );
}

  void _handleEdit(ServiceModel service) {
    // Navigate to edit service screen
  }

  Future<void> _handleDelete(int serviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoá dịch vụ'),
        content: const Text('Bạn có chắc chắn muốn xoá dịch vụ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Call delete API
    }
  }

  void _handleToggleStatus(ServiceModel service) {
    // Toggle service status API call
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
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
                child: Stack(
                  children: [
                    Image.network(
                      service.image,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            onPressed: onEdit,
                          ),
                          Gap(8.w),
                          _buildActionButton(
                            icon: Icons.delete,
                            color: Colors.red,
                            onPressed: onDelete,
                          ),
                        ],
                      ),
                    ),
                  ],
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
                              service.name,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              service.serviceTypeName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: service.status,
                        onChanged: (_) => onToggleStatus(),
                        activeColor: const Color(0xFF8B5CF6),
                      ),
                    ],
                  ),
                  Gap(12.h),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.access_time,
                        service.duration,
                      ),
                      Gap(12.w),
                      _buildInfoChip(
                        Icons.attach_money,
                        '\$${service.cost.toStringAsFixed(2)}',
                      ),
                      Gap(12.w),
                      _buildInfoChip(
                        Icons.book,
                        '${service.bookingCount} đặt chỗ',
                      ),
                    ],
                  ),
                  if (service.certificate.isNotEmpty) ...[
                    Gap(12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 16.sp,
                          color: Colors.green,
                        ),
                        Gap(4.w),
                        Text(
                          '${service.certificate.length} Chứng chỉ',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: Icon(
            icon,
            size: 20.sp,
            color: color ?? Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16.sp,
            color: const Color(0xFF8B5CF6),
          ),
          Gap(4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }
}