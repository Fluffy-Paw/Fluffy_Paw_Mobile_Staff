import 'dart:io';

import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/models/profile/store_manager.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_button.dart';
import 'package:fluffypawsm/presentation/widgets/component/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class StoreManagerProfile extends ConsumerStatefulWidget {
 const StoreManagerProfile({Key? key}) : super(key: key);
 @override
 ConsumerState<StoreManagerProfile> createState() => _StoreManagerProfileState();
}

class _StoreManagerProfileState extends ConsumerState<StoreManagerProfile> {
 StoreManagerProfileModel? profileInfo;
 bool isEditing = false;
 final _formKey = GlobalKey<FormBuilderState>();
 late TextEditingController fullNameController;
 late TextEditingController emailController;
 late TextEditingController hotlineController; 
 late TextEditingController brandNameController;
 late TextEditingController mstController;
 String? selectedImagePath;
 String? selectedLicenseImage;

 @override
 void initState() {
   super.initState();
   _loadProfileFromHive();
 }

 void _initControllers() {
   fullNameController = TextEditingController(text: profileInfo?.fullName);
   emailController = TextEditingController(text: profileInfo?.brandEmail);
   hotlineController = TextEditingController(text: profileInfo?.hotline);
   brandNameController = TextEditingController(text: profileInfo?.name);
   mstController = TextEditingController(text: profileInfo?.mst);
 }

 Future<void> _loadProfileFromHive() async {
   final profile = await ref.read(hiveStoreService).getUserInfo();
   if (profile != null && mounted) {
     setState(() {
       profileInfo = profile;
       _initControllers();
     });
   }
 }

 Future<void> _handleUpdateProfile() async {
   if (_formKey.currentState?.saveAndValidate() ?? false) {
     final result = await ref.read(profileController.notifier).updateProfile(
       fullName: fullNameController.text,
       email: emailController.text,
       avatar: selectedImagePath,
      //  hotline: hotlineController.text,
      //  name: brandNameController.text, 
      //  mst: mstController.text,
      //  businessLicense: selectedLicenseImage
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

 @override
 Widget build(BuildContext context) {
   if (profileInfo == null) {
     return const Scaffold(
       body: Center(child: CircularProgressIndicator()),
     );
   }

   return Scaffold(
     backgroundColor: const Color(0xFFF4F4F5),
     appBar: AppBar(
       backgroundColor: Colors.transparent,
       elevation: 0,
       leading: IconButton(
         icon: Icon(Icons.arrow_back, color: AppColor.blackColor),
         onPressed: () => Navigator.pop(context),
       ),
       actions: [
         IconButton(
           icon: Icon(
             isEditing ? Icons.check : Icons.edit,  
             color: AppColor.blackColor,
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
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: EdgeInsets.all(16.w),
         child: FormBuilder(
           key: _formKey,
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               _buildProfileImage(),
               Gap(24.h),
               _buildBusinessLicense(),
               Gap(24.h),
               Text(
                 'Store Information',
                 style: AppTextStyle(context).title,
               ),
               Gap(16.h),
               _buildInfoSection(),
               if (isEditing) ...[
                 Gap(24.h),
                 CustomButton(
                   buttonText: 'Cancel',
                   buttonColor: Colors.grey,
                   onPressed: () {
                     setState(() {
                       isEditing = false;
                       _initControllers();
                     });
                   },
                 ),
               ],
             ],
           ),
         ),
       ),
     ),
   );
 }

 Widget _buildProfileImage() {
   return Center(
     child: Column(
       children: [
         Stack(
           children: [
             CircleAvatar(
               radius: 60.r,
               backgroundImage: selectedImagePath != null 
                 ? FileImage(File(selectedImagePath!))
                 : NetworkImage(profileInfo!.logo) as ImageProvider,
             ),
             if (isEditing)
               Positioned(
                 bottom: 0,
                 right: 0,
                 child: CircleAvatar(
                   backgroundColor: AppColor.violetColor,
                   radius: 18.r,
                   child: IconButton(
                     icon: Icon(Icons.camera_alt, size: 18.sp, color: Colors.white),
                     onPressed: _pickImage,
                   ),
                 ),
               ),
           ],
         ),
         Gap(12.h),
         Text(
           profileInfo!.name,
           style: AppTextStyle(context).title,
         ),
       ],
     ),
   );
 }

 Widget _buildBusinessLicense() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Text(
         'Business License',
         style: AppTextStyle(context).title,
       ),
       Gap(12.h),
       Stack(
         children: [
           Container(
             height: 200.h,
             width: double.infinity,
             decoration: BoxDecoration(
               borderRadius: BorderRadius.circular(12.r),
               image: DecorationImage(
                 image: selectedLicenseImage != null
                     ? FileImage(File(selectedLicenseImage!))
                     : NetworkImage(profileInfo!.businessLicense) as ImageProvider,
                 fit: BoxFit.cover,
               ),
             ),
           ),
           if (isEditing)
             Positioned(
               bottom: 8,
               right: 8,
               child: CircleAvatar(
                 backgroundColor: AppColor.violetColor,
                 child: IconButton(
                   icon: const Icon(Icons.edit, color: Colors.white),
                   onPressed: _pickLicenseImage,
                 ),
               ),
             ),
         ],
       ),
     ],
   );
 }

 Widget _buildInfoSection() {
   return Container(
     padding: EdgeInsets.all(16.w),
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
       children: [
         _buildInfoField(
           icon: Icons.person,
           title: 'Full Name',
           value: profileInfo!.fullName,
           controller: fullNameController,
         ),
         _buildDivider(),
         _buildInfoField(
           icon: Icons.business,
           title: 'Brand Name',
           value: profileInfo!.name,
           controller: brandNameController,
         ),
         _buildDivider(),
         _buildInfoField(
           icon: Icons.email,
           title: 'Email',
           value: profileInfo!.brandEmail,
           controller: emailController,
         ),
         _buildDivider(),
         _buildInfoField(
           icon: Icons.phone,
           title: 'Hotline',
           value: profileInfo!.hotline,
           controller: hotlineController,
         ),
         _buildDivider(),
         _buildInfoField(
           icon: Icons.numbers,
           title: 'Tax ID',
           value: profileInfo!.mst,
           controller: mstController,
         ),
       ],
     ),
   );
 }

 Widget _buildInfoField({
   required IconData icon,
   required String title,
   required String value,
   required TextEditingController controller,
 }) {
   return Padding(
     padding: EdgeInsets.symmetric(vertical: 8.h),
     child: Row(
       children: [
         Container(
           padding: EdgeInsets.all(8.w),
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
           child: isEditing
               ? CustomTextFormField(
                   name: title.toLowerCase().replaceAll(' ', '_'),
                   hintText: title,
                   textInputType: TextInputType.text,
                   controller: controller,
                   textInputAction: TextInputAction.next,
                   validator: (value) {
                     if (value?.isEmpty ?? true) return 'This field is required';
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
                     Gap(2.h),
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

 Widget _buildDivider() {
   return Divider(
     color: Colors.grey[200],
     height: 16.h,
   );
 }

 Future<void> _pickImage() async {
   final ImagePicker picker = ImagePicker();
   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
   if (image != null) {
     setState(() {
       selectedImagePath = image.path;
     });
   }
 }

 Future<void> _pickLicenseImage() async {
   final ImagePicker picker = ImagePicker();
   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
   if (image != null) {
     setState(() {
       selectedLicenseImage = image.path;
     });
   }
 }
}