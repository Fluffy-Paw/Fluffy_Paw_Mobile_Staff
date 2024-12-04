import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/components/app_bottom_navbar.dart';
import 'package:fluffypawsm/presentation/pages/conversation/layout/conversation_list_layout.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/dashboard_view.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/layouts/dashboard_layout.dart';
import 'package:fluffypawsm/presentation/pages/order/order_view.dart';
import 'package:fluffypawsm/presentation/pages/profile/profile_view.dart';
import 'package:fluffypawsm/presentation/pages/services/service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomItem {
  final String icon;
  final String activeIcon;
  final String name;
  BottomItem({
    required this.icon,
    required this.activeIcon,
    required this.name,
  });
}
class BottomNavigationLayout extends ConsumerStatefulWidget {
  const BottomNavigationLayout({super.key});

  @override
  ConsumerState<BottomNavigationLayout> createState() =>
      _BottomNavigationLayoutState();
}

class _BottomNavigationLayoutState
    extends ConsumerState<BottomNavigationLayout> {
  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(bottomTabControllerProvider);
    return Scaffold(
      bottomNavigationBar: AppBottomNavbar(
        bottomItem: getBottomItems(context: context),
        onSelect: (index) {
          if (index != null) {
            pageController.jumpToPage(index);
          }
        },
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) {
          ref.watch(selectedIndexProvider.notifier).state = index;
        },
        children: const [
          DashboardView(),
          OrderView(),
          ServiceView(),
          ConversationScreen(),
          ProfileView(),
        ],
      ),
    );
  }

  List<BottomItem> getBottomItems({required BuildContext context}) {
    return [
      BottomItem(
        icon: Assets.svg.dashboard,
        activeIcon: Assets.svg.activeDashboard,
        name: S.of(context).dashboard,
      ),
      BottomItem(
        icon: Assets.svg.bag,
        activeIcon: Assets.svg.activeBag,
        name: S.of(context).orders,
      ),
      BottomItem(
        icon: Assets.svg.rider,
        activeIcon: Assets.svg.activeRider,
        name: S.of(context).riders,
      ),
      BottomItem(
        icon: Assets.svg.communicationsNotactive,
        activeIcon: Assets.svg.communicationsActive,
        name: S.of(context).inbox,
      ),
      BottomItem(
        icon: Assets.svg.profile,
        activeIcon: Assets.svg.activeProfile,
        name: S.of(context).profile,
      ),
    ];
  }
}