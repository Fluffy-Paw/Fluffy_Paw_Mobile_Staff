import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/gen/assets.gen.dart';
import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/controller/wallet/wallet_controller.dart';
import 'package:fluffypawsm/data/models/profile/profile.dart';
import 'package:fluffypawsm/data/models/profile/store_manager.dart';
import 'package:fluffypawsm/data/models/wallet/wallet_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/language.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/menu_card.dart';
import 'package:fluffypawsm/presentation/widgets/component/confirmation_dialog.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shimmer/shimmer.dart';

class ProfileLayout extends ConsumerStatefulWidget {
  const ProfileLayout({super.key});

  @override
  ConsumerState<ProfileLayout> createState() => _ProfileLayoutState();
}

class _ProfileLayoutState extends ConsumerState<ProfileLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final role = await userRole();
      if (role == 'StoreManager') {
        ref.read(walletController.notifier).fetchWalletInfo();
      }
    });
  }

  Future<String> userRole() async {
    final token = await ref.read(hiveStoreService).getAuthToken();
    final decodedToken = JwtDecoder.decode(token!);
    return decodedToken["http://schemas.microsoft.com/ws/2008/06/identity/claims/role"];
  }

  @override 
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;
    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderWidget(context: context, ref: ref),
            Gap(14.h),
            _buildBodyWidget(context: context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWidget({required BuildContext context, required WidgetRef ref}) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(AppConstants.userBox).listenable(),
      builder: (context, userBox, _) {
        final userInfo = userBox.get(AppConstants.userData);
        if (userInfo == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<String>(
          future: userRole(),
          builder: (context, roleSnapshot) {
            if (!roleSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final isStoreManager = roleSnapshot.data == 'StoreManager';
            final wallet = isStoreManager 
              ? ref.watch(walletController.notifier).walletInfo 
              : null;

            Map<String, dynamic> userInfoStringKeys = Map<String, dynamic>.from(userInfo);
            dynamic user;
            String role = roleSnapshot.data!;

            try {
              if (role == 'Staff') {
                user = User.fromMap(userInfoStringKeys);
              } else {
                user = StoreManagerProfileModel.fromMap(userInfoStringKeys);
              }

              return Stack(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w)
                        .copyWith(top: 60.h, bottom: 14.h),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CircleAvatar(
                              radius: 40.sp,
                              backgroundImage: role == 'Staff'
                                  ? CachedNetworkImageProvider(user.account.avatar)
                                  : CachedNetworkImageProvider(user.logo),
                            ),
                            Positioned(
                              right: -10,
                              bottom: 0,
                              child: CircleAvatar(
                                radius: 16.sp,
                                backgroundImage: role == 'Staff'
                                    ? CachedNetworkImageProvider(user.brandName)
                                    : CachedNetworkImageProvider(user.logo),
                              ),
                            )
                          ],
                        ),
                        Gap(14.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                role == 'Staff'
                                    ? "${user.account.username} ${user.account.roleName}"
                                    : user.fullName,
                                style: AppTextStyle(context).title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Gap(10.w),
                            CircleAvatar(
                              radius: 3,
                              backgroundColor: colors(context)
                                  .bodyTextSmallColor!
                                  .withOpacity(0.2),
                            ),
                            Gap(10.w),
                            Expanded(
                              child: Text(
                                role == 'Staff' ? user.brandName : user.name,
                                style: AppTextStyle(context)
                                    .bodyTextSmall
                                    .copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                        Gap(10.h),
                        Text(
                          role == 'Staff'
                              ? user.account.email
                              : user.brandEmail,
                          style: AppTextStyle(context).bodyTextSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        // Only show earning widget for Store Manager
                        if (isStoreManager) ...[
                          Gap(14.h),
                          _buildEarningWidget(context, wallet)
                        ],
                      ],
                    ),
                  ),
                  // Positioned(
                  //   top: 70.h,
                  //   right: 20.w,
                  //   child: FlutterSwitch(
                  //     width: 80.w,
                  //     activeText: S.of(context).open,
                  //     inactiveText: S.of(context).close,
                  //     valueFontSize: 14,
                  //     activeTextColor: AppColor.whiteColor,
                  //     activeColor: AppColor.violetColor,
                  //     inactiveTextFontWeight: FontWeight.w400,
                  //     activeTextFontWeight: FontWeight.w400,
                  //     showOnOff: true,
                  //     value: true,
                  //     onToggle: (v) {},
                  //   ),
                  // )
                ],
              );
            } catch (e) {
              debugPrint('Error building header: $e');
              return Center(
                child: Text('Error loading profile: $e'),
              );
            }
          },
        );
      }
    );
  }

  Widget _buildEarningWidget(BuildContext context, WalletModel? wallet) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors(context).primaryColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  Assets.svg.doller,
                  color: AppColor.whiteColor,
                  height: 30.h,
                ),
                Gap(10.w),
                Expanded(
                  child: Text(
                    S.of(context).earnThisMonth,
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                      color: AppColor.whiteColor,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              ],
            ),
          ),
          ref.watch(walletController)
              ? Shimmer.fromColors(
                  baseColor: AppColor.whiteColor,
                  highlightColor: AppColor.blackColor,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: AppColor.offWhiteColor.withOpacity(0.2),
                    ),
                    child: Text(
                      '0.00',
                      style: AppTextStyle(context).title.copyWith(
                          color: AppColor.whiteColor,
                          fontSize: 16.sp),
                    ),
                  ),
                )
              : Text(
                  '${AppConstants.appCurrency}${GlobalFunction.numberLocalization(wallet?.balance.toString() ?? "0")}',
                  style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: AppColor.whiteColor,
                    fontWeight: FontWeight.w400,
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildBodyWidget({required BuildContext context}) {
    return FutureBuilder<String>(
      future: userRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isStoreManager = snapshot.data == 'StoreManager';

        return AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // Earning History - only for Store Manager
                if (isStoreManager) ...[
                  Container(
                    color: AppColor.whiteColor,
                    child: Column(
                      children: [
                        MenuCard(
                          context: context,
                          icon: Assets.svg.earningHistory,
                          text: S.of(context).earningHistory,
                          onTap: () {
                            context.nav.pushNamed(Routes.earningHistory);
                          },
                        ),
                        const Divider(
                          height: 0,
                          thickness: 0.5,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ],
                    ),
                  ),
                  Gap(14.h),
                ],

                // Regular menu items
                Container(
                  color: AppColor.whiteColor,
                  child: Column(
                    children: [
                      MenuCard(
                        context: context,
                        icon: Assets.svg.sellerProfile,
                        text: S.of(context).sellerProfile,
                        onTap: () async {
                          if (isStoreManager) {
                            context.nav.pushNamed(Routes.storeManagerProfile);
                          } else {
                            context.nav.pushNamed(Routes.sellerAccount);
                          }
                        },
                      ),
                      const Divider(
                        height: 0,
                        thickness: 0.5,
                        indent: 20,
                        endIndent: 20,
                      ),
                      MenuCard(
                        context: context,
                        icon: Assets.svg.storeAccount,
                        text: S.of(context).staffmanageservice,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                Gap(14.h),

                // Language and Theme
                // Container(
                //   color: AppColor.whiteColor,
                //   child: Column(
                //     children: [
                //       MenuCard(
                //         context: context,
                //         icon: Assets.svg.language,
                //         text: S.of(context).language,
                //         type: 'launguage',
                //         onTap: () {
                //           showModalBottomSheet(
                //             isDismissible: true,
                //             backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.only(
                //                 topLeft: Radius.circular(12.r),
                //                 topRight: Radius.circular(12.r),
                //               ),
                //             ),
                //             context: context,
                //             builder: (BuildContext context) => ShowLanguage(),
                //           );
                //         },
                //       ),
                //       const Divider(
                //         height: 0,
                //         thickness: 0.5,
                //         indent: 20,
                //         endIndent: 20,
                //       ),
                //       MenuCard(
                //         context: context,
                //         icon: Assets.svg.sun,
                //         text: S.of(context).theme,
                //         type: 'theme',
                //         onTap: () {},
                //       ),
                //     ],
                //   ),
                // ),
                // Gap(14.h),

                // Settings
                // Container(
                //   color: AppColor.whiteColor,
                //   child: Column(
                //     children: [
                //       MenuCard(
                //         context: context,
                //         icon: Assets.svg.sellerSupport,
                //         text: S.of(context).sellerSupport,
                //         onTap: () {},
                //       ),
                //       const Divider(
                //         height: 0,
                //         thickness: 0.5,
                //         indent: 20,
                //         endIndent: 20,
                //       ),
                //       MenuCard(
                //         context: context,
                //         icon: Assets.svg.termsConditions,
                //         text: S.of(context).termsconditions,
                //         onTap: () {},
                //       ),
                //       const Divider(
                //         height: 0,
                //         thickness: 0.5,
                //         indent: 20,
                //         endIndent: 20,
                //       ),
                //       MenuCard(
                //         context: context,
                //         icon: Assets.svg.privacy,
                //         text: S.of(context).privacyPolicy,
                //         onTap: () {},
                //       ),
                //     ],
                //   ),
                // ),
                // Gap(14.h),

                // Logout
                Container(
                  color: AppColor.whiteColor,
                  child: MenuCard(
                    context: context,
                    icon: Assets.svg.logout,
                    text: S.of(context).logout,
                    type: 'logout',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => ConfirmationDialog(
                          isLoading: false,
                          text: S.of(context).logoutDes,
                          cancelTapAction: () {
                            context.nav.pop(context);
                          },
                          applyTapAction: () {
                            ref.read(hiveStoreService).removeAllData()
                              .then((isSuccess) {
                                if (isSuccess) {
                                  ref.refresh(selectedIndexProvider.notifier).state;
                                  context.nav.pushNamedAndRemoveUntil(
                                    Routes.login, (route) => false);
                                } else {
                                  context.nav.pop();
                                  GlobalFunction.showCustomSnackbar(
                                    message: 'Something went wrong!',
                                    isSuccess: false,
                                  );
                                }
                              });
                          },
                          image: Assets.image.question.image(width: 80.w),
                        ),
                      );
                    },
                  ),
                ),
                Gap(50.h),
              ],
            ),
          ),
        );
      },
    );
  }
}