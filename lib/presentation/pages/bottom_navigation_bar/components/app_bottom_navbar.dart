import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class AppBottomNavbar extends ConsumerWidget {
  const AppBottomNavbar({
    super.key,
    required this.bottomItem,
    required this.onSelect,
  });

  final List<BottomItem> bottomItem;
  final Function(int? index) onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          if (Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor)
            const BoxShadow(
              color: AppColor.offWhiteColor,
              spreadRadius: -2,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              bottomItem.length,
              (index) => _buildNavItem(
                bottomItem: bottomItem[index],
                index: index,
                context: context,
                ref: ref,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BottomItem bottomItem,
    required int index,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final int selectedIndex = ref.watch(selectedIndexProvider);
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: () => onSelect(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 36.h,
              width: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? (colors(context).primaryColor ?? Colors.blue).withOpacity(0.1)
                    : Colors.transparent,
              ),
              child: Center(
                child: SvgPicture.asset(
                  isSelected ? bottomItem.activeIcon : bottomItem.icon,
                  height: 24.h,
                  width: 24.w,
                  colorFilter: ColorFilter.mode(
                    isSelected
                        ? (colors(context).primaryColor ?? Colors.blue)
                        : (colors(context).bodyTextSmallColor ?? Colors.grey),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              bottomItem.name,
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (colors(context).primaryColor ?? Colors.blue)
                    : (colors(context).bodyTextSmallColor ?? Colors.grey),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}