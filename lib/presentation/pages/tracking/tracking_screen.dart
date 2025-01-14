import 'dart:io';

import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/tracking_controller.dart';
import 'package:fluffypawsm/data/models/tracking/tracking_model.dart';
import 'package:fluffypawsm/presentation/pages/tracking/components/tracking_message_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const TrackingScreen({
    Key? key,
    required this.bookingId,
  }) : super(key: key);

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  late AnimationController _uploadAnimationController;
  late Animation<double> _uploadProgressAnimation;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _messageController.dispose();
    _uploadAnimationController.dispose();
    super.dispose();
  }

  Future<bool> _checkAndRequestPermission() async {
    // Kiểm tra platform
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isGranted) {
        return true;
      }

      final result = await Permission.photos.request();
      return result.isGranted;
    }

    return true; // Với Android không cần xin quyền
  }

  Future<void> _selectImages() async {
    try {
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        if (!status.isGranted) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Photo Access Required'),
                content: const Text(
                    'Please allow full access to your photos in Settings to upload tracking images.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          }
          return;
        }
      }

      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && mounted) {
        setState(() {
          _selectedImages = images;
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        _showErrorSnackbar('Error selecting images');
      }
    }
  }

  Future<void> _uploadTracking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      _showImageRequiredDialog();
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });
      _uploadAnimationController.forward();

      // Perform the upload using the controller
      await ref.read(trackingControllerProvider.notifier).uploadTracking(
            bookingId: widget.bookingId,
            description: _messageController.text,
            images: _selectedImages,
          );

      // Clear form after successful upload
      _messageController.clear();
      setState(() {
        _selectedImages = [];
        _isUploading = false;
      });
      _uploadAnimationController.reset();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _uploadAnimationController.reset();

      // Show error to user
      _showErrorSnackbar(e.toString());
    }
  }

  Future<void> _showSuccessAnimation() async {
    await showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: ScaleTransition(
            scale: animation,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success animation (you can use Lottie here)
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColor.violetColor.withOpacity(0.1),
                    child: Icon(
                      Icons.check,
                      color: AppColor.violetColor,
                      size: 40.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Update Posted!',
                    style: AppTextStyle(context).title,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Your tracking update has been posted successfully.',
                    textAlign: TextAlign.center,
                    style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      barrierDismissible: false,
    );
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showImageRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Images Required'),
        content: const Text(
            'Please select at least one image for the tracking update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _uploadAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _uploadProgressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _uploadAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(trackingControllerProvider.notifier)
          .getTrackingInfo(widget.bookingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracking Booking #${widget.bookingId}',
              style: AppTextStyle(context).title.copyWith(
                    fontSize: 18.sp,
                  ),
            ),
            Text(
              'Theo dõi trạng thái',
              style: AppTextStyle(context).bodyTextSmall.copyWith(
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final trackingState = ref.watch(trackingControllerProvider);

                    return trackingState.when(
                      loading: () => ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: 3,
                        itemBuilder: (context, index) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 100.w,
                                        height: 10.h,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 8.h),
                                      Container(
                                        width: double.infinity,
                                        height: 100.h,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Text('Hiện tại chưa có tracking nào'),
                      ),
                      data: (trackingList) => RefreshIndicator(
                        onRefresh: () async {
                          ref
                              .read(trackingControllerProvider.notifier)
                              .getTrackingInfo(widget.bookingId);
                        },
                        child: trackingList.isEmpty
                            ? ListView(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.7,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 120.w,
                                          height: 120.w,
                                          decoration: BoxDecoration(
                                            color: AppColor.violetColor
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.timeline_outlined,
                                            size: 60.sp,
                                            color: AppColor.violetColor,
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        Text(
                                          'No Tracking Updates',
                                          style: AppTextStyle(context)
                                              .title
                                              .copyWith(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(
                                          'No tracking information available for this order yet. Updates will appear here when they are added.',
                                          textAlign: TextAlign.center,
                                          style: AppTextStyle(context)
                                              .bodyText
                                              .copyWith(
                                                color: Colors.grey,
                                                height: 1.5,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: EdgeInsets.only(
                                  top: 16.h,
                                  bottom:
                                      _selectedImages.isEmpty ? 80.h : 160.h,
                                ),
                                itemCount: trackingList.length,
                                itemBuilder: (context, index) {
                                  return TrackingMessageCard(
                                    tracking: trackingList[index],
                                    isLastItem:
                                        index == trackingList.length - 1,
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
              // Input area
              // Container(
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).scaffoldBackgroundColor,
              //     boxShadow: [
              //       BoxShadow(
              //         color: Colors.black.withOpacity(0.05),
              //         blurRadius: 10,
              //         offset: const Offset(0, -5),
              //       ),
              //     ],
              //   ),
              //   child: Column(
              //     children: [
              //       if (_selectedImages.isNotEmpty)
              //         Container(
              //           height: 80.h,
              //           padding: EdgeInsets.all(8.w),
              //           child: ListView.builder(
              //             scrollDirection: Axis.horizontal,
              //             itemCount: _selectedImages.length,
              //             itemBuilder: (context, index) {
              //               return Padding(
              //                 padding: EdgeInsets.only(right: 8.w),
              //                 child: Stack(
              //                   children: [
              //                     AspectRatio(
              //                       aspectRatio: 1,
              //                       child: ClipRRect(
              //                         borderRadius: BorderRadius.circular(8.r),
              //                         child: Image.file(
              //                           File(_selectedImages[index].path),
              //                           fit: BoxFit.cover,
              //                         ),
              //                       ),
              //                     ),
              //                     Positioned(
              //                       right: 4.w,
              //                       top: 4.h,
              //                       child: GestureDetector(
              //                         onTap: () {
              //                           setState(() {
              //                             _selectedImages.removeAt(index);
              //                           });
              //                         },
              //                         child: Container(
              //                           padding: EdgeInsets.all(4.w),
              //                           decoration: const BoxDecoration(
              //                             color: Colors.black54,
              //                             shape: BoxShape.circle,
              //                           ),
              //                           child: Icon(
              //                             Icons.close,
              //                             size: 12.sp,
              //                             color: Colors.white,
              //                           ),
              //                         ),
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               );
              //             },
              //           ),
              //         ),
              //       Padding(
              //         padding: EdgeInsets.all(8.w),
              //         child: Row(
              //           children: [
              //             IconButton(
              //               onPressed: _selectImages,
              //               icon: Icon(
              //                 Icons.photo_library,
              //                 color: AppColor.violetColor,
              //               ),
              //             ),
              //             Expanded(
              //               child: TextField(
              //                 controller: _messageController,
              //                 decoration: InputDecoration(
              //                   hintText: 'Add tracking update...',
              //                   border: OutlineInputBorder(
              //                     borderRadius: BorderRadius.circular(20.r),
              //                     borderSide: BorderSide.none,
              //                   ),
              //                   filled: true,
              //                   fillColor: Colors.grey[200],
              //                   contentPadding: EdgeInsets.symmetric(
              //                     horizontal: 16.w,
              //                     vertical: 8.h,
              //                   ),
              //                 ),
              //                 maxLines: null,
              //               ),
              //             ),
              //             SizedBox(width: 8.w),
              //             CircleAvatar(
              //               backgroundColor: AppColor.violetColor,
              //               child: IconButton(
              //                 onPressed: _isUploading ? null : _uploadTracking,
              //                 icon: _isUploading
              //                     ? SizedBox(
              //                         width: 20.w,
              //                         height: 20.w,
              //                         child: const CircularProgressIndicator(
              //                           color: Colors.white,
              //                           strokeWidth: 2,
              //                         ),
              //                       )
              //                     : const Icon(
              //                         Icons.send,
              //                         color: Colors.white,
              //                       ),
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              _buildInputArea(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isUploading)
            LinearProgressIndicator(
              value: _uploadProgressAnimation.value,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.violetColor),
            ),
          if (_selectedImages.isNotEmpty)
            Container(
              height: 80.h,
              padding: EdgeInsets.all(8.w),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) => _buildImagePreview(index),
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8.w,
              vertical: 8.w,
            ),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: _isUploading ? null : _selectImages,
                    icon: Icon(
                      Icons.photo_library,
                      color: _isUploading ? Colors.grey : AppColor.violetColor,
                    ),
                  ),
                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 120.h, // Maximum height for the input
                      ),
                      child: TextFormField(
                        controller: _messageController,
                        enabled: !_isUploading,
                        validator: (value) {
                          if (value?.trim().isEmpty ?? true) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        maxLines: null,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        style: AppTextStyle(context).bodyText.copyWith(
                              fontSize: 14.sp,
                            ),
                        decoration: InputDecoration(
                          hintText: 'Add tracking update...',
                          hintStyle: AppTextStyle(context).bodyText.copyWith(
                                color: Colors.grey,
                                fontSize: 14.sp,
                              ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CircleAvatar(
                      backgroundColor:
                          _isUploading ? Colors.grey : AppColor.violetColor,
                      child: IconButton(
                        onPressed: _isUploading ? null : _uploadTracking,
                        icon: _isUploading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(_selectedImages[index].path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!_isUploading)
            Positioned(
              right: 4.w,
              top: 4.h,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
