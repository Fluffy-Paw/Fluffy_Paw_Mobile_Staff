import 'dart:io';
import 'package:fluffypawsm/data/controller/service_brand_controller.dart';
import 'package:fluffypawsm/data/models/service/service_by_brand.dart';
import 'package:fluffypawsm/data/models/service/service_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

class UpdateServiceScreen extends ConsumerStatefulWidget {
  final ServiceModel service;

  const UpdateServiceScreen({Key? key, required this.service})
      : super(key: key);

  @override
  ConsumerState<UpdateServiceScreen> createState() =>
      _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends ConsumerState<UpdateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  final _durationController = TextEditingController();

  File? _serviceImage;
  late ServiceTypeModel? _selectedServiceType;
  bool _isLoadingServiceTypes = true;
  List<ServiceTypeModel> _serviceTypes = [];
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadServiceTypes();
    });
    final durationParts = widget.service.duration.split(':');
    if (durationParts.length == 3) {
      _hours = int.tryParse(durationParts[0]) ?? 0;
      _minutes = int.tryParse(durationParts[1]) ?? 0;
      _seconds = int.tryParse(durationParts[2]) ?? 0;
      _durationController.text =
          '${_hours.toString().padLeft(2, '0')}:${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';
    }
  }

  void _initializeFields() {
    _nameController.text = widget.service.name;
    _descriptionController.text = widget.service.description;
    _costController.text = widget.service.cost.toString();
    _durationController.text = widget.service.duration
        .replaceAll(RegExp(r'[^0-9]'), ''); // Extract minutes
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
          _selectedServiceType = _serviceTypes.firstWhere(
            (type) => type.id == widget.service.serviceTypeId,
            orElse: () => _serviceTypes.first,
          );
          _isLoadingServiceTypes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingServiceTypes = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading service types: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _serviceImage = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedServiceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service type')),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service name cannot be empty')),
      );
      return;
    }

    try {
      final success = await ref.read(serviceController.notifier).updateService(
            id: widget.service.id,
            serviceTypeId: _selectedServiceType!.id,
            name: name,
            image: _serviceImage,
            duration: '${_hours.toString().padLeft(2, '0')}:'
                '${_minutes.toString().padLeft(2, '0')}:'
                '${_seconds.toString().padLeft(2, '0')}',
            cost: double.parse(_costController.text),
            description: _descriptionController.text.trim(),
          );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(serviceController);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          'Update Service',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                    _buildImageSection(),
                    Gap(24.h),
                    _buildServiceTypeSelector(),
                    Gap(24.h),
                    _buildBasicInfoFields(),
                    Gap(32.h),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Image',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(16.h),
        GestureDetector(
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
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      widget.service.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 48.sp,
                              color: Colors.grey,
                            ),
                            Gap(8.h),
                            Text(
                              'Error loading image',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceTypeSelector() {
    if (_isLoadingServiceTypes) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Type',
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
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48.sp,
                              color: Colors.grey[400],
                            ),
                          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        Gap(16.h),
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
            // Replace the old duration field with the new _buildDurationField
            Expanded(child: _buildDurationField()),
          ],
        ),
      ],
    );
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Set Duration',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              content: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimePickerColumn(
                      'Hours',
                      _hours,
                      (value) => setState(() => _hours = value),
                      23,
                    ),
                    SizedBox(width: 16.w),
                    _buildTimePickerColumn(
                      'Minutes',
                      _minutes,
                      (value) => setState(() => _minutes = value),
                      59,
                    ),
                    SizedBox(width: 16.w),
                    _buildTimePickerColumn(
                      'Seconds',
                      _seconds,
                      (value) => setState(() => _seconds = value),
                      59,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final duration = '${_hours.toString().padLeft(2, '0')}:'
                        '${_minutes.toString().padLeft(2, '0')}:'
                        '${_seconds.toString().padLeft(2, '0')}';
                    _durationController.text = duration;
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Set',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTimePickerColumn(
    String label,
    int value,
    Function(int) onChanged,
    int maxValue,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8B5CF6)),
            borderRadius: BorderRadius.circular(8.r),
          ),
          width: 64.w,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_up,
                  color: Color(0xFF8B5CF6),
                ),
                onPressed: () => onChanged(value < maxValue ? value + 1 : 0),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B5CF6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF8B5CF6),
                ),
                onPressed: () => onChanged(value > 0 ? value - 1 : maxValue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput(
      String label, int value, Function(int) onChanged, int maxValue) {
    final controller =
        TextEditingController(text: value.toString().padLeft(2, '0'));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Gap(8.h),
        SizedBox(
          width: 60.w,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: const Color(0xFF8B5CF6)),
              ),
            ),
            onChanged: (value) {
              final newValue = int.tryParse(value) ?? 0;
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeColumn(
      String label, int value, Function(int) onChanged, int maxValue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        Gap(8.h),
        SizedBox(
          width: 60.w,
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                onPressed: () {
                  onChanged(value < maxValue ? value + 1 : 0);
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  value.toString().padLeft(2, '0'),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: () {
                  onChanged(value > 0 ? value - 1 : maxValue);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B5CF6),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: Text(
        'Update Service',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDurationField() {
    return InkWell(
      onTap: () => _showDurationPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8.r),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _durationController.text,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.access_time,
              color: Colors.grey[600],
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
