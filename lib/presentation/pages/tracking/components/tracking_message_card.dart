import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/models/tracking/tracking_model.dart';
import 'package:fluffypawsm/presentation/pages/tracking/components/tracking_image_viewer.dart';
import 'package:fluffypawsm/presentation/pages/tracking/components/tracking_status_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class TrackingMessageCard extends StatelessWidget {
  final TrackingInfo tracking;
  final bool isLastItem;

  const TrackingMessageCard({
    Key? key,
    required this.tracking,
    this.isLastItem = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSending = tracking.isTemp && tracking.error == null;
    final bool isError = tracking.error != null;

    Widget contentWidget = _buildContent(context);

    if (isSending) {
      contentWidget = Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: contentWidget,
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: isSending ? Colors.grey[300] : AppColor.violetColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLastItem)
                Container(
                  width: 2.w,
                  height: 50.h,
                  color: AppColor.violetColor.withOpacity(0.3),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(tracking.uploadDate.toLocal()),
                        style: AppTextStyle(context).bodyTextSmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    if (isSending || isError)
                      TrackingStatusText(
                        isSending: isSending,
                        isSuccess: !isSending && !isError,
                        errorMessage: tracking.error,
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                contentWidget,
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (tracking.files.isNotEmpty && !tracking.isTemp) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewer(
                images: tracking.files.map((e) => e.file).toList(),
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (tracking.description.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(12.w),
                child: Text(
                  tracking.description,
                  style: AppTextStyle(context).bodyText,
                  softWrap: true,
                ),
              ),
            if (tracking.files.isNotEmpty)
              ClipRRect(
                borderRadius: tracking.description.isEmpty
                    ? BorderRadius.circular(12.r)
                    : BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                child: tracking.files.length == 1
                    ? AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildImage(tracking.files[0].file),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2.w,
                          mainAxisSpacing: 2.w,
                        ),
                        itemCount: tracking.files.length,
                        itemBuilder: (context, index) {
                          return _buildImage(tracking.files[index].file);
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (tracking.isTemp) {
      // For temporary tracking, show local file
      return Image.file(
        File(imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey[600],
          ),
        ),
      );
    }
    // For actual tracking, use CachedNetworkImage
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}