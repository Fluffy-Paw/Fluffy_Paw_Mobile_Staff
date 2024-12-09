import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/account_controller.dart';
import 'package:fluffypawsm/data/models/store/store_model.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final AccountModel store;
  const AccountDetailScreen({Key? key, required this.store}) : super(key: key);

  @override
  ConsumerState<AccountDetailScreen> createState() =>
      _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  bool isEditing = false;
  bool isUpdatingPassword = false;
  final _formKey = GlobalKey<FormBuilderState>();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    usernameController = TextEditingController(text: widget.store.username);
    emailController = TextEditingController(text: widget.store.email);
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  Future<void> _handleUpdateProfile() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await ref.read(accountController.notifier).updateStaff(
            id: widget.store.id.toString(),
            
            email: emailController.text,
          );

      if (result && mounted) {
        setState(() {
          isEditing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  Future<void> _handleUpdatePassword() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      final result = await ref.read(accountController.notifier).updateStaff(
            id: widget.store.id.toString(),
           
            password: passwordController.text,
            confirmPassword: confirmPasswordController.text,
            email: widget.store.email,
          );

      if (result && mounted) {
        setState(() {
          isUpdatingPassword = false;
          passwordController.clear();
          confirmPasswordController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    }
  }

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!isUpdatingPassword)
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (isEditing) {
                      _handleUpdateProfile();
                    } else {
                      setState(() {
                        isEditing = true;
                      });
                    }
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColor.violetColor,
                          const Color(0xFF8B5CF6),
                          const Color(0xFF7C3AED),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: CirclePatternPainter(),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60.r,
                          backgroundImage: NetworkImage(widget.store.avatar),
                        ),
                        Gap(16.h),
                        Text(
                          widget.store.username,
                          style: AppTextStyle(context).title.copyWith(
                                color: Colors.white,
                                fontSize: 24.sp,
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
                            widget.store.roleName,
                            style: AppTextStyle(context).bodyText.copyWith(
                                  color: Colors.white,
                                ),
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                ),
                child: FormBuilder(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileSection(),
                        Gap(24.h),
                        _buildPasswordSection(),
                        if (isEditing || isUpdatingPassword) ...[
                          Gap(24.h),
                          CustomButton(
                            buttonText: 'Cancel',
                            buttonColor: Colors.grey,
                            onPressed: () {
                              setState(() {
                                isEditing = false;
                                isUpdatingPassword = false;
                                _initControllers();
                              });
                            },
                          ),
                        ],
                        Gap(20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDivider(),
        Text(
          'Profile Information',
          style: AppTextStyle(context).title,
        ),
        Gap(16.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              
              _buildInfoField(
                icon: Icons.person,
                title: 'Username',
                controller: usernameController,
                enabled: isEditing,
                readOnly: true,
              ),
              _buildDivider(),
              _buildInfoField(
                icon: Icons.email,
                title: 'Email',
                controller: emailController,
                enabled: isEditing,
              ),
              //  _buildDivider(),
              //  _buildInfoField(
              //    icon: Icons.business,
              //    title: 'Brand Name',
              //    controller: TextEditingController(text: widget.store.brandName),
              //    enabled: false,
              //  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: AppTextStyle(context).title,
            ),
            if (!isEditing && !isUpdatingPassword)
              TextButton.icon(
                icon: const Icon(Icons.lock_outline),
                label: const Text('Change Password'),
                onPressed: () {
                  setState(() {
                    isUpdatingPassword = true;
                  });
                },
              ),
          ],
        ),
        if (isUpdatingPassword) ...[
          Gap(16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoField(
                  icon: Icons.lock,
                  title: 'New Password',
                  controller: passwordController,
                  enabled: true,
                  isPassword: true,
                ),
                _buildDivider(),
                _buildInfoField(
                  icon: Icons.lock_outline,
                  title: 'Confirm Password',
                  controller: confirmPasswordController,
                  enabled: true,
                  isPassword: true,
                ),
                Gap(16.h),
                CustomButton(
                  buttonText: 'Update Password',
                  onPressed: _handleUpdatePassword,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required bool enabled,
    bool readOnly = false,
    bool isPassword = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColor.violetColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: AppColor.violetColor,
              size: 20.sp,
            ),
          ),
          Gap(12.w),
          Expanded(
            child: enabled
                ? CustomTextFormField(
                    name: title.toLowerCase().replaceAll(' ', '_'),
                    hintText: title,
                    textInputType: TextInputType.text,
                    controller: controller,
                    textInputAction: TextInputAction.next,
                    readOnly: readOnly,
                    obscureText: isPassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'This field is required';
                      }
                      if (isPassword && value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                              color: AppColor.gray,
                            ),
                      ),
                      Text(
                        isPassword ? '••••••••' : controller.text,
                        style: AppTextStyle(context).bodyText,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.grey[200],
      height: 16.h,
    );
  }
}

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
