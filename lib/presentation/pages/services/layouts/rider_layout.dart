import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/data/controller/service_controller.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/earning_history_shimmer_widget.dart';
import 'package:fluffypawsm/presentation/pages/services/components/rider_card.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_search_field.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gap/gap.dart';

class RiderLayout extends ConsumerStatefulWidget {
  const RiderLayout({super.key});

  @override
  ConsumerState<RiderLayout> createState() => _RiderLayoutState();
}

class _RiderLayoutState extends ConsumerState<RiderLayout> {
  final TextEditingController riderSearchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  @override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Load data immediately when screen opens
    final userInfo = await ref.read(hiveStoreService).getUserInfo();
    if (userInfo?.id != null) {
      await ref.read(serviceController.notifier).getAllStoreServices(userInfo!.id);
    }

    // Setup search listener
    riderSearchController.addListener(() {
      // Search implementation
    });

    // Setup scroll listener
    scrollController.addListener(scrollListener);
  });
}

  int page = 1;
  final int perPage = 20;
  bool scrollLoading = false;

  void scrollListener() async {
  if (scrollController.offset >= scrollController.position.maxScrollExtent) {
    if (!ref.watch(serviceController) && !scrollLoading) {
      scrollLoading = true;
      page++;
      final userInfo = await ref.read(hiveStoreService).getUserInfo();
      if (userInfo?.id != null) {
        await ref.read(serviceController.notifier).getAllStoreServices(
          userInfo!.id,
        );
      }
      scrollLoading = false;
    }
  }
}

  @override
  Widget build(BuildContext context) {
    bool isDark =
        Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
        body: Column(
          children: [
            buildHeader(context: context),
            Flexible(flex: 5, child: buildBody()),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({required BuildContext context}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h)
          .copyWith(top: 50.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).riders,
            style: AppTextStyle(context).subTitle,
          ),
          Gap(10.h),
          SizedBox(
            child: Row(
              children: [
                Flexible(
                  flex: 5,
                  child: CustomSearchField(
                    name: 'searchRider',
                    hintText: S.of(context).searchByName,
                    textInputType: TextInputType.text,
                    controller: riderSearchController,
                    onChanged: (value) {
                      // ref.read(riderController.notifier).getRiders(
                      //       page: 1,
                      //       perPage: 20,
                      //       search: value,
                      //       pagination: false,
                      //     );
                    },
                    widget: const SizedBox(),
                    // IconButton(
                    //   onPressed: () {
                    //     if (riderSearchController.text.isNotEmpty) {
                    //       ref.read(riderController.notifier).getRiders(
                    //             page: 1,
                    //             perPage: 20,
                    //             search: riderSearchController.text,
                    //             pagination: false,
                    //           );
                    //     }
                    //   },
                    //   icon: Icon(
                    //     Icons.search,
                    //     size: 30.sp,
                    //   ),
                    // ),
                  ),
                ),
                Gap(5.w),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<CircleBorder>(
                      const CircleBorder(),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColor.violetColor),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.all(10.0),
                    ),
                  ),
                  onPressed: () {
                    context.nav.pushNamed(Routes.serviceListByBrand);
                  },
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      color: AppColor.whiteColor,
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    return ref.watch(serviceController)
        ? const EarningHistoryShimmerWidget()
        : AnimationLimiter(
            child: RefreshIndicator(
              onRefresh: () async {
                riderSearchController.clear();
                final userInfo = await ref.read(hiveStoreService).getUserInfo();
                if (userInfo?.id != null) {
                  await ref
                      .read(serviceController.notifier)
                      .getAllStoreServices(userInfo!.id);
                }
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                controller: scrollController,
                itemCount:
                    ref.watch(serviceController.notifier).services?.length ?? 0,
                itemBuilder: (context, index) {
                  final Service service =
                      ref.watch(serviceController.notifier).services![index];
                  return AnimationConfiguration.staggeredList(
                    duration: const Duration(milliseconds: 500),
                    position: index,
                    child: SlideAnimation(
                      verticalOffset: 50.0.w,
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.h),
                          child: RiderCard(
                            rider:
                                service, // Cần đổi RiderCard thành ServiceCard sau này
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }
}
