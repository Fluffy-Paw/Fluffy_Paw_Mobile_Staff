import 'dart:io';
import 'package:fluffypawsm/data/controller/service_brand_controller.dart';
import 'package:fluffypawsm/data/models/service/service_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class CreateServiceScreen extends ConsumerStatefulWidget {
  const CreateServiceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateServiceScreen> createState() =>
      _CreateServiceScreenState();
}

class _CreateServiceScreenState extends ConsumerState<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _durationController = TextEditingController();
  List<ServiceTypeModel> _serviceTypes = [];
  bool _isLoadingServiceTypes = true;
  ServiceTypeModel?
      _selectedServiceType; // Replace _selectedServiceTypeId with this

  File? _serviceImage;
  List<CertificateInput> _certificates = [];
  int? _selectedServiceTypeId;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to delay the state modification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceTypes();
    });
  }

  Future<void> _loadServiceTypes() async {
    try {
      setState(() {
        _isLoadingServiceTypes = true;
      });

      await ref.read(serviceController.notifier).getAllServiceTypes();
      final types = ref.read(serviceController.notifier).serviceTypes;

      if (mounted) {
        setState(() {
          _serviceTypes = types ?? [];
          _isLoadingServiceTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServiceTypes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading service types: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _serviceImage = File(image.path);
      });
    }
  }

  void _addCertificate() {
    setState(() {
      _certificates.add(CertificateInput());
    });
  }

  void _removeCertificate(int index) {
    setState(() {
      _certificates.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _serviceImage == null ||
        _selectedServiceTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    try {
      final duration = Duration(minutes: int.parse(_durationController.text));
      final cost = double.parse(_costController.text);

      if (!_formKey.currentState!.validate() ||
          _serviceImage == null ||
          _selectedServiceType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')),
        );
        return;
      }

// And update the service creation call:
      final serviceId =
          await ref.read(serviceController.notifier).createService(
                serviceTypeId:
                    _selectedServiceType!.id, // Use the selected type's ID
                name: _nameController.text,
                image: _serviceImage!,
                duration: duration,
                cost: cost,
                description: _descriptionController.text,
              );

      if (serviceId != null) {
        // Upload certificates if service creation was successful
        for (var certificate in _certificates) {
          if (certificate.isValid()) {
            await ref.read(serviceController.notifier).createCertificate(
                  serviceId: serviceId,
                  certificateFile: certificate.file!,
                  title: certificate.title!,
                  description: certificate.description!,
                );
          }
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service created successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create service')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating service: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(serviceController);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          'Create New Service',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(),
                    Gap(16.h),
                    _buildServiceTypeDropdown(),
                    Gap(16.h),
                    _buildBasicInfoFields(),
                    Gap(24.h),
                    _buildCertificatesSection(),
                    Gap(32.h),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Create Service',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _serviceImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.file(
                  _serviceImage!,
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48.sp,
                    color: Colors.grey,
                  ),
                  Gap(8.h),
                  Text(
                    'Add Service Image',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    if (_isLoadingServiceTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Service Type',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.8,
          ),
          itemCount: _serviceTypes.length,
          itemBuilder: (context, index) {
            final serviceType = _serviceTypes[index];
            final isSelected = _selectedServiceType?.id == serviceType.id;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedServiceType = serviceType;
                  _selectedServiceTypeId =
                      serviceType.id; // Keep this for compatibility
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B5CF6)
                        : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10.r),
                        ),
                        child: Image.network(
                          serviceType.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48.sp,
                                color: Colors.grey[400],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B5CF6).withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        serviceType.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBasicInfoFields() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Service Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a service name';
            }
            return null;
          },
        ),
        Gap(16.h),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
        Gap(16.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Cost (\$)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
            Gap(16.w),
            Expanded(
              child: TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter duration';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
              onPressed: _addCertificate,
              icon: const Icon(Icons.add),
              label: const Text('Add Certificate'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        Gap(8.h),
        ..._certificates.asMap().entries.map((entry) {
          final index = entry.key;
          final certificate = entry.value;
          return _CertificateForm(
            certificate: certificate,
            onRemove: () => _removeCertificate(index),
          );
        }),
      ],
    );
  }
}

class CertificateInput {
  String? title;
  String? description;
  File? file;

  bool isValid() {
    return title != null && description != null && file != null;
  }
}

class _CertificateForm extends StatelessWidget {
  final CertificateInput certificate;
  final VoidCallback onRemove;

  const _CertificateForm({
    required this.certificate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Certificate Details',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
                color: Colors.red,
              ),
            ],
          ),
          Gap(16.h),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Certificate Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onChanged: (value) => certificate.title = value,
          ),
          Gap(16.h),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Certificate Description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onChanged: (value) => certificate.description = value,
          ),
          Gap(16.h),
          ElevatedButton.icon(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image =
                  await picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                certificate.file = File(image.path);
              }
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Certificate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
