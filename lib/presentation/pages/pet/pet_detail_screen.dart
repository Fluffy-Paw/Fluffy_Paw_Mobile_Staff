import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/pet_controller.dart';
import 'package:fluffypawsm/data/models/pet/pet_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class PetDetailScreen extends ConsumerWidget {
  final int petId;

  const PetDetailScreen({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      body: ref.watch(petDetailControllerProvider(petId)).when(
        data: (pet) => CustomScrollView(
          slivers: [
            _buildAppBar(context, pet),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildPetInfo(context, pet),
                  _buildHealthInfo(context, pet),
                  _buildBehaviorInfo(context, pet),
                  _buildAdditionalInfo(context, pet),
                  Gap(20.h),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PetDetail pet) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: pet.image != null
            ? Image.network(
                pet.image!,
                fit: BoxFit.cover,
              )
            : Container(
                color: AppColor.violetColor.withOpacity(0.1),
                child: Icon(
                  Icons.pets,
                  size: 100.sp,
                  color: AppColor.violetColor,
                ),
              ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildPetInfo(BuildContext context, PetDetail pet) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: AppTextStyle(context).title.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pet.petType.name,
                      style: AppTextStyle(context).bodyText.copyWith(
                        color: AppColor.blackColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: pet.status == 'Available'
                      ? AppColor.greenCheckin.withOpacity(0.1)
                      : AppColor.redColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  pet.status,
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: pet.status == 'Available'
                        ? AppColor.greenCheckin
                        : AppColor.redColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Gap(16.h),
          _buildInfoRow(
            context: context,
            icon: Icons.cake,
            label: 'Age',
            value: pet.age,
          ),
          Gap(8.h),
          _buildInfoRow(
            context: context,
            icon: Icons.monitor_weight,
            label: 'Weight',
            value: '${pet.weight} kg',
          ),
          Gap(8.h),
          _buildInfoRow(
            context: context,
            icon: Icons.medical_services,
            label: 'Microchip',
            value: pet.microchipNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfo(BuildContext context, PetDetail pet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Information',
            style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          Gap(16.h),
          _buildHealthRow(
            context: context,
            icon: Icons.warning_amber,
            label: 'Allergies',
            value: pet.allergy.isEmpty ? 'None' : pet.allergy,
            color: AppColor.redColor,
          ),
          Gap(8.h),
          _buildHealthRow(
            context: context,
            icon: Icons.cut,
            label: 'Neutered',
            value: pet.isNeuter ? 'Yes' : 'No',
            color: AppColor.violetColor,
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorInfo(BuildContext context, PetDetail pet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Behavior',
            style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppColor.violetColor,
                  size: 24.sp,
                ),
                Gap(8.w),
                Text(
                  pet.behaviorCategory.name,
                  style: AppTextStyle(context).bodyText.copyWith(
                    color: AppColor.violetColor,
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

  Widget _buildAdditionalInfo(BuildContext context, PetDetail pet) {
    if (pet.description.isEmpty) return const SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w).copyWith(top: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes',
            style: AppTextStyle(context).bodyText.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          Gap(8.h),
          Text(
            pet.description,
            style: AppTextStyle(context).bodyText.copyWith(
              color: AppColor.blackColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: AppColor.blackColor.withOpacity(0.5),
        ),
        Gap(8.w),
        Text(
          '$label: ',
          style: AppTextStyle(context).bodyText.copyWith(
            color: AppColor.blackColor.withOpacity(0.5),
          ),
        ),
        Text(
          value,
          style: AppTextStyle(context).bodyText.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildHealthRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle(context).bodyTextSmall.copyWith(
                  color: AppColor.blackColor.withOpacity(0.5),
                ),
              ),
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
    );
  }
}