import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluffypawsm/data/controller/service_brand_controller.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailScreen extends ConsumerStatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({Key? key, required this.service})
      : super(key: key);

  @override
  ConsumerState<ServiceDetailScreen> createState() =>
      _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends ConsumerState<ServiceDetailScreen> {
  late ServiceModel _service;
  @override
  void initState() {
    super.initState();
    _service = widget.service;
  }

  void _updateService(ServiceModel updatedService) {
    setState(() {
      _service = updatedService;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF4F4F5),
    appBar: AppBar(
      title: const Text('Service Details'),
    ),
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageHeader(_service),  // Changed from widget.service
          _buildServiceInfo(context, _service),  // Changed from widget.service
          _buildCertificatesList(context, _service),  // Changed from widget.service
        ],
      ),
    ),
  );
}

  Widget _buildImageHeader(ServiceModel service) {
    return Stack(
      children: [
        Image.network(
          service.image,
          width: double.infinity,
          height: 250.h,
          fit: BoxFit.cover,
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gap(8.h),
                Text(
                  service.serviceTypeName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceInfo(BuildContext context, ServiceModel service) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(Icons.access_time, 'Duration', service.duration),
          Divider(height: 24.h),
          _buildInfoRow(Icons.attach_money, 'Cost', '\$${service.cost}'),
          Divider(height: 24.h),
          _buildInfoRow(
              Icons.book, 'Total Bookings', '${service.bookingCount}'),
          if (service.description.isNotEmpty) ...[
            Divider(height: 24.h),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap(8.h),
            Text(
              service.description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Color(0xFF8B5CF6), size: 20.sp),
        Gap(12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCertificatesList(BuildContext context, ServiceModel service) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Certificates',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: service.certificate.length >= 2
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Maximum of 2 certificates allowed'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    : () => _showAddCertificateDialog(context),
                icon: Icon(
                  Icons.add,
                  color: service.certificate.length >= 2
                      ? Colors.grey
                      : const Color(0xFF8B5CF6),
                ),
                label: Text(
                  'Add Certificate',
                  style: TextStyle(
                    color: service.certificate.length >= 2
                        ? Colors.grey
                        : const Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          Gap(12.h),
          if (service.certificate.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Text(
                  'No certificates available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...service.certificate.map((cert) => _CertificateCard(
                  certificate: cert,
                  onDelete: () => _showDeleteConfirmation(context, cert),
                )),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, Certificate certificate) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Certificate'),
        content:
            const Text('Are you sure you want to delete this certificate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && context.mounted) {
      final result = await ref
          .read(serviceController.notifier)
          .deleteCertificate(certificate.id);

      if (result && context.mounted) {
        // Get updated service after deletion
        final updatedService =
            ref.read(serviceController.notifier).getServiceById(_service.id);
        if (updatedService != null) {
          _updateService(updatedService);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete certificate'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddCertificateDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    String name = '';
    String description = '';
    File? certificateFile;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Certificate (${_service.certificate.length}/2)',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8B5CF6),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      Gap(16.h),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: InkWell(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['pdf', 'doc', 'docx'],
                            );
                            if (result != null) {
                              setState(() {
                                certificateFile =
                                    File(result.files.single.path!);
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(12.r),
                          child: Container(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              children: [
                                Icon(
                                  certificateFile == null
                                      ? Icons.upload_file
                                      : Icons.file_present,
                                  size: 40.sp,
                                  color: const Color(0xFF8B5CF6),
                                ),
                                Gap(8.h),
                                Text(
                                  certificateFile == null
                                      ? 'Upload Certificate File'
                                      : certificateFile!.path.split('/').last,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF8B5CF6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (certificateFile == null) ...[
                                  Gap(4.h),
                                  Text(
                                    'Supported formats: PDF, DOC, DOCX',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      Gap(16.h),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Certificate Name',
                          hintText: 'Enter certificate name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF8B5CF6)),
                          ),
                          floatingLabelStyle:
                              const TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                        validator: (value) => value?.isEmpty == true
                            ? 'Please enter a name'
                            : null,
                        onSaved: (value) => name = value ?? '',
                      ),
                      Gap(16.h),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide:
                                const BorderSide(color: Color(0xFF8B5CF6)),
                          ),
                          floatingLabelStyle:
                              const TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                        maxLines: 3,
                        onSaved: (value) => description = value ?? '',
                      ),
                      Gap(24.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isUploading
                              ? null
                              : () async {
                                  if (formKey.currentState?.validate() ==
                                      true) {
                                    if (certificateFile == null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please select a certificate file'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() => isUploading = true);
                                    formKey.currentState?.save();

                                    final result = await ref
                                        .read(serviceController.notifier)
                                        .createCertificate(
                                          serviceId: _service.id,
                                          certificateFile: certificateFile!,
                                          title: name,
                                          description: description,
                                        );

                                    if (result && context.mounted) {
                                      // Get updated service after adding certificate
                                      final updatedService = ref
                                          .read(serviceController.notifier)
                                          .getServiceById(_service.id);
                                      if (updatedService != null) {
                                        _updateService(updatedService);
                                      }

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Certificate added successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      Navigator.pop(context);
                                    } else if (context.mounted) {
                                      setState(() => isUploading = false);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Failed to add certificate'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          child: isUploading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Add Certificate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  final Certificate certificate;
  final VoidCallback onDelete;

  const _CertificateCard({
    required this.certificate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.verified,
              color: const Color(0xFF8B5CF6),
              size: 24.sp,
            ),
          ),
          Gap(16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (certificate.description.isNotEmpty) ...[
                  Gap(4.h),
                  Text(
                    certificate.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                Gap(8.h),
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(certificate.file);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        icon: Icon(Icons.file_download, size: 18.sp),
                        label: const Text('View Certificate'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF8B5CF6),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
