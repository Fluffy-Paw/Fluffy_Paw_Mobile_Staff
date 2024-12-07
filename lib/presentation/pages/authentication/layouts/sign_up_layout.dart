import 'dart:io';

import 'package:fluffypawsm/core/generated/l10n.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/authentication_controller.dart';
import 'package:fluffypawsm/data/models/authentication/signup_model.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/confirm_otp_bottom_sheet.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/shop_details_widget.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/shop_owner_widget.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class SignUpLayout extends ConsumerStatefulWidget {
  const SignUpLayout({super.key});

  @override
  ConsumerState<SignUpLayout> createState() => _SignUpLayoutState();
}

class _SignUpLayoutState extends ConsumerState<SignUpLayout>
    with SingleTickerProviderStateMixin {
  final List<FocusNode> fNodeList = List.generate(8, (index) => FocusNode());
  final List<FocusNode> shopFNode = List.generate(6, (index) => FocusNode());
  final TextEditingController pinCodeController = TextEditingController();
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    // tabController.addListener(() {
    //   if (tabController.index != ref.read(activeTabIndex)) {
    //     ref.read(activeTabIndex.notifier).state = tabController.index;
    //   }
    // });
    GlobalFunction.clearControllers(ref: ref);
  }

  // @override
  // void didChangeDependencies() {
  //   ref.invalidate(activeTabIndex);
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    tabController.dispose();
    for (var node in [...fNodeList, ...shopFNode]) {
      node.dispose();
    }
    pinCodeController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        bottomNavigationBar: _buildBottomBar(context),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: tabController,
          children: [
            ShopOwnerWidget(formKey: _formKey, fNodeList: fNodeList),
            ShopDetailsWidget(shopFNode),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).registration),
      leading: IconButton(
        onPressed: () {
          context.nav.pop(context);
          ref.read(isCheckBox.notifier).state = false;
          ref.refresh(isPhoneNumberVerified);
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20),
          child: Text(
            '${ref.watch(activeTabIndex) + 1}/2',
            style: AppTextStyle(context)
                .bodyText
                .copyWith(fontWeight: FontWeight.w500),
          ),
        )
      ],
      bottom: _buildTabBar(context),
    );
  }

  TabBar _buildTabBar(BuildContext context) {
    return TabBar(
      physics: const NeverScrollableScrollPhysics(),
      isScrollable: false,
      controller: tabController,
      labelColor: colors(context).primaryColor,
      unselectedLabelColor: colors(context).bodyTextColor!.withOpacity(0.4),
      indicatorColor: colors(context).primaryColor,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: (v) {
        print('Tab tapped: $v');
        print('Current tab: ${tabController.index}');

        if (ref.read(isPhoneNumberVerified)) {
          if (v == 1) {
            tabController.animateTo(1);
            ref.read(activeTabIndex.notifier).state = 1;
          } else {
            tabController.animateTo(0);
            ref.read(activeTabIndex.notifier).state = 0;
          }
        } else {
          // Nếu chưa verify, giữ nguyên ở tab 0
          tabController.animateTo(0);
          ref.read(activeTabIndex.notifier).state = 0;
          GlobalFunction.showCustomSnackbar(
            message: 'Please verify your phone number first',
            isSuccess: false,
          );
        }
      },
      tabs: [
        Tab(
          icon: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person),
              Gap(5.w),
              Text(S.of(context).shopOwner)
            ],
          ),
        ),
        Tab(
          icon: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.store),
              Gap(5.w),
              Text(S.of(context).shopDetails)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    print("Current tab index: ${ref.watch(activeTabIndex)}");
    print("Phone verified: ${ref.watch(isPhoneNumberVerified)}");

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors(context).bodyTextSmallColor!.withOpacity(0.1),
            width: 2,
          ),
        ),
      ),
      child: Center(
        child: ref.watch(activeTabIndex) == 0
            ? _buildFirstStepButton(context)
            : _buildSubmitButton(context),
      ),
    );
  }

  Widget _buildFirstStepButton(BuildContext context) {
    return ref.watch(authController)
        ? SizedBox(
            height: 40.h,
            width: 40.w,
            child: const CircularProgressIndicator(),
          )
        : AbsorbPointer(
            absorbing: !ref.watch(isCheckBox),
            child: SizedBox(
              height: 50.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: CustomButton(
                  buttonText: S.of(context).proccedNext,
                  buttonColor: ref.watch(isCheckBox)
                      ? colors(context).primaryColor
                      : AppColor.violet100,
                  onPressed: () => _handleFirstStep(context),
                ),
              ),
            ),
          );
  }

  Future<void> _handleFirstStep(BuildContext context) async {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }

    if (!formState.saveAndValidate()) {
      print('Form validation failed');
      return;
    }
    print('Button pressed');
    print('Form state exists: ${_formKey.currentState != null}');
    print('Form validation result: ${_formKey.currentState?.validate()}');

    if (ref.read(passwordProvider).text != ref.read(confirmPassProvider).text) {
      GlobalFunction.showCustomSnackbar(
        message: 'Provided password is not matched!',
        isSuccess: false,
      );
      return;
    }

    if (ref.read(isPhoneNumberVerified)) {
      _proceedToNextStep();
      return;
    }

    final result = await ref
        .read(authController.notifier)
        .sendOTP(mobile: ref.read(phoneProvider).text);

    if (!mounted) return;

    if (result['success']) {
      _showOtpBottomSheet(context);
    } else {
      GlobalFunction.showCustomSnackbar(
        message: result['message'],
        isSuccess: false,
      );
    }
  }

  void _proceedToNextStep() {
    tabController.animateTo(1);
    ref.read(activeTabIndex.notifier).state = 1;
  }

  void _showOtpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      context: context,
      builder: (context) => ConfirmOTPBottomSheet(
        pinCodeController: pinCodeController,
        tabController: tabController,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ref.watch(authController)
        ? SizedBox(
            height: 40.h,
            width: 40.w,
            child: const CircularProgressIndicator(),
          )
        : SizedBox(
            height: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomButton(
                buttonText: S.of(context).submit,
                onPressed: () => _handleSubmit(context),
                buttonColor: colors(context).primaryColor,
              ),
            ),
          );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (!ref.read(isPhoneNumberVerified)) {
      GlobalFunction.showCustomSnackbar(
        message: 'Please verify your phone number first',
        isSuccess: false,
      );
      return;
    }
    // Form validation
    final formState = ref.read(shopDetailsFormKey).currentState;
    if (formState == null || !formState.validate()) {
      GlobalFunction.showCustomSnackbar(
        message: 'Please fill all required fields correctly',
        isSuccess: false,
      );
      return;
    }

    // Check required files
    if (ref.read(selectedShopLogo) == null) {
      GlobalFunction.showCustomSnackbar(
        message: 'Shop logo is required',
        isSuccess: false,
      );
      return;
    }

    if (ref.read(businessLicenseProvider) == null ||
        ref.read(frontIdProvider) == null ||
        ref.read(backIdProvider) == null) {
      GlobalFunction.showCustomSnackbar(
        message: 'All required documents must be uploaded',
        isSuccess: false,
      );
      return;
    }

    // Create signup model
    final signUpModel = SignUpModel(
      userName: ref.read(usernameProvider).text,
      fullName:
          "${ref.read(firstNameProvider).text} ${ref.read(lastNameProvider).text}",
      password: ref.read(passwordProvider).text,
      confirmPassword: ref.read(confirmPassProvider).text,
      email: ref.read(emailProvider).text,
      storeName: ref.read(shopNameProvider).text,
      mst: ref.read(mstProvider).text,
      address: ref.read(addressProvider).text,
      hotline: ref.read(phoneProvider).text,
      brandEmail: ref.read(brandEmailProvider).text,
    );

    // Submit registration
    try {
      final success = await ref.read(authController.notifier).registration(
            signUpModel: signUpModel,
            businessLicense: ref.read(businessLicenseProvider)!,
            frontId: ref.read(frontIdProvider)!,
            backId: ref.read(backIdProvider)!,
            logo: ref.read(selectedShopLogo)!,
          );

      if (success) {
        GlobalFunction.showCustomSnackbar(
          message: 'Registration successful',
          isSuccess: true,
        );
        context.nav.pushNamedAndRemoveUntil(
          Routes.underReviewAccount,
          (route) => false,
        );
      }
    } catch (e) {
      GlobalFunction.showCustomSnackbar(
        message: 'Registration failed: ${e.toString()}',
        isSuccess: false,
      );
    }
  }
}
