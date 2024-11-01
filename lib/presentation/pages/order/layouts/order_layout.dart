import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart' as pending_order;
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/components/pending_order_card.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_card.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_tab_card.dart';
import 'package:fluffypawsm/presentation/pages/order/components/order_tab_card_shimmer_widget.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/earning_history_shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class OrderLayout extends ConsumerStatefulWidget {
  const OrderLayout({super.key});

  @override
  ConsumerState<OrderLayout> createState() => _OrderLayoutState();
}

class _OrderLayoutState extends ConsumerState<OrderLayout> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollController scrollController = ScrollController();
  int page = 1;
  final int perPage = 20;
  bool scrollLoading = false;

  // Hardcoded statuses
  final List<String> orderStatuses = [
    'Accepted',
    'Pending',
    'Canceled',
    'Denied',
    'OverTime',
    'Ended'
  ];

  Map<String, int> orderCounts = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      page = 1;
      ref.read(activeOrderTab.notifier).state = 0;
      ref.read(selectedOrderStatus.notifier).state = 'Accepted';
      orderCounts = await ref.read(hiveStoreService).getOrderStatuses();
      print("Order Counts from Hive: $orderCounts");
      setState(() {});
      await ref.read(orderController.notifier).getOrderListWithFilter(ref.read(selectedOrderStatus));
      scrollController.addListener(() {
        scrollListener();
      });
    });
  }

  void scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      if ((ref.watch(orderController.notifier).dashboard?.orders.length ?? 0) <
          (ref.watch(orderController.notifier).dashboard?.todayOrders ?? 0) &&
          !scrollLoading) {
        scrollLoading = true;
        page++;
        ref.read(orderController.notifier).getOrderListWithFilter(
          ref.read(selectedOrderStatus),
        );
      }
    }
  }

  int getOrderCountByStatus(List<Order?> orders, String status) {
  return orders.where((order) => order?.status == status).length;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor
              ? AppColor.blackColor
              : AppColor.offWhiteColor,
      body: Column(
        children: [
          buildHeader(context: context, ref: ref),
          Flexible(
            flex: 5,
            child: ref.watch(orderController) && !scrollLoading
                ? const EarningHistoryShimmerWidget()
                : buildBody(ref: ref),
          )
        ],
      ),
    );
  }

  Widget buildHeader({required BuildContext context, required WidgetRef ref}) {
    final orders = ref.watch(orderController.notifier).dashboard?.orders ?? [];

    return Container(
      padding: EdgeInsets.only(top: 50.h, bottom: 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                S.of(context).orders,
                style: AppTextStyle(context).subTitle,
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 3.h),
                child: Text(
                  'Today-${DateFormat('dd MMM,yyyy').format(DateTime.now().toLocal())}',
                  style: AppTextStyle(context)
                      .bodyTextSmall
                      .copyWith(fontWeight: FontWeight.w500, fontSize: 13.sp),
                ),
              ),
              trailing: SizedBox(
                width: 90.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {},
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColor.offWhiteColor,
                        child: Icon(Icons.search),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColor.offWhiteColor,
                        child: Icon(Icons.calendar_month),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Gap(10.h),
          Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 12),
            child: ScrollablePositionedList.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 20.w),
              initialScrollIndex: ref.watch(activeOrderTab),
              itemScrollController: itemScrollController,
              itemCount: orderStatuses.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return AbsorbPointer(
                  absorbing: ref.watch(orderController),
                  child: InkWell(
                    onTap: () async {
                      page = 1;
                      ref.read(activeOrderTab.notifier).state = index;
                      ref.read(selectedOrderStatus.notifier).state = orderStatuses[index];
                      await ref.read(orderController.notifier).getOrderListWithFilter(
                        ref.read(selectedOrderStatus),
                      );
                    },
                    child: OrderTabCard(
                      isActiveTab: ref.watch(activeOrderTab) == index,
                      orderCount: orderCounts[orderStatuses[index]] ?? 0,
                      orderStatus: GlobalFunction.getOrderStatusLocalizationText(
                        context: context,
                        status: orderStatuses[index],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody({required WidgetRef ref}) {
    final orders = ref.watch(orderController.notifier).dashboard?.orders;

    final nonNullOrders = orders?.where((order) => order != null).toList() ?? [];

    return nonNullOrders.isNotEmpty
        ? AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                page = 1;
                ref.read(activeOrderTab.notifier).state = 0;
                ref.read(selectedOrderStatus.notifier).state = 'Pending';
                final result = await ref.read(orderController.notifier).getOrderListWithFilter(
                ref.read(selectedOrderStatus),
              );
              debugPrint(result.toString());

              if (result == false) {
                debugPrint("false");
                Center(
            child: Text(
              
              S.of(context).orderNotFound,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          ); // Ensures orders list is empty
              } else if (itemScrollController.isAttached) {
                itemScrollController.scrollTo(
                  index: 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                );
              }
            },
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                itemCount: nonNullOrders.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 50.0.w,
                      child: FadeInAnimation(
                        child: OrderCard(
                          order: nonNullOrders[index],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        : Center(
            child: Text(
              S.of(context).orderNotFound,
              style: AppTextStyle(context)
                  .bodyText
                  .copyWith(fontWeight: FontWeight.w400),
            ),
          );
  }
}

