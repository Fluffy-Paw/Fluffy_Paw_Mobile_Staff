import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class AccountDetailScreen extends StatelessWidget {
  final AccountModel account;

  const AccountDetailScreen({Key? key, required this.account}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.violetColor,
                          Color(0xFF8B5CF6),
                          Color(0xFF7C3AED),
                        ],
                      ),
                    ),
                  ),
                  // Decorative patterns
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CirclePatternPainter(),
                    ),
                  ),
                  // Profile content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundImage: NetworkImage(account.avatar),
                            backgroundColor: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        Gap(16.h),
                        Text(
                          account.username,
                          style: AppTextStyle(context).title.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Gap(8.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.white, size: 16.sp),
                              Gap(4.w),
                              Text(
                                account.roleName,
                                style: AppTextStyle(context).bodyTextSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
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
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: Offset(0, -30.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColor.whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                ),
                child: Column(
                  children: [
                    // Status Cards
                    Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          _buildStatusCard(
                            context,
                            icon: Icons.how_to_reg,
                            title: 'Status',
                            value: account.status == 1 ? 'Active' : 'Inactive',
                            color: account.status == 1 ? Colors.green : Colors.red,
                            gradient: LinearGradient(
                              colors: account.status == 1 
                                ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                                : [Colors.red.withOpacity(0.1), Colors.red.withOpacity(0.05)],
                            ),
                          ),
                          Gap(16.w),
                          _buildStatusCard(
                            context,
                            icon: Icons.calendar_today,
                            title: 'Member Since',
                            value: DateFormat('MMM yyyy').format(account.createDate),
                            color: AppColor.violetColor,
                            gradient: LinearGradient(
                              colors: [
                                AppColor.violetColor.withOpacity(0.1),
                                AppColor.violetColor.withOpacity(0.05),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Info Sections
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          _buildSection(
                            context,
                            title: 'Personal Information',
                            items: [
                              _buildInfoTile(
                                context,
                                icon: Icons.email_outlined,
                                title: 'Email',
                                value: account.email,
                              ),
                              _buildInfoTile(
                                context,
                                icon: Icons.badge_outlined,
                                title: 'Account ID',
                                value: '#${account.id}',
                              ),
                              _buildInfoTile(
                                context,
                                icon: Icons.password_outlined,
                                title: 'Password Hash',
                                value: account.password,
                                isPassword: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

  Widget _buildStatusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            Gap(12.h),
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
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle(context).title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(16.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    bool isPassword = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColor.violetColor, size: 20.sp),
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
                if (isPassword)
                  Text(
                    value.substring(0, 20) + '...',
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                      fontFamily: 'Monospace',
                      color: AppColor.blackColor.withOpacity(0.7),
                    ),
                  )
                else
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

// Custom painter for decorative background pattern
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final double gap = 40;
    for (double i = -size.width; i < size.width * 2; i += gap) {
      for (double j = -size.height; j < size.height * 2; j += gap) {
        canvas.drawCircle(Offset(i, j), 20, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}