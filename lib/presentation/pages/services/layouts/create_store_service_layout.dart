import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/data/controller/service_controller.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:gap/gap.dart';

class StoreServiceFormLayout extends ConsumerStatefulWidget {
  final int serviceId;
  final CreateScheduleRequest? scheduleToEdit; // Add this parameter
  final Function(CreateScheduleRequest)? onUpdate; // Add callback for update
  
  const StoreServiceFormLayout({
    Key? key,
    required this.serviceId,
    this.scheduleToEdit,
    this.onUpdate,
  }) : super(key: key);

  @override
  ConsumerState<StoreServiceFormLayout> createState() => _StoreServiceFormLayoutState();
}

class _StoreServiceFormLayoutState extends ConsumerState<StoreServiceFormLayout> {
  final List<CreateScheduleRequest> schedules = [];
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedTime;
  final TextEditingController limitController = TextEditingController();
  
  bool get isEditMode => widget.scheduleToEdit != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Initialize form with existing data if in edit mode
      selectedTime = widget.scheduleToEdit!.startTime;
      limitController.text = widget.scheduleToEdit!.limitPetOwner.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).scaffoldBackgroundColor == AppColor.blackColor;

    return Scaffold(
      backgroundColor: isDark ? AppColor.blackColor : AppColor.offWhiteColor,
      appBar: AppBar(
        title: Text(isEditMode ? 'Update Schedule' : 'Create Store Service'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isEditMode) _buildSchedulesList(),
              Gap(16.h),
              _buildScheduleForm(),
              Gap(32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.violetColor,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  onPressed: isEditMode ? _updateSchedule : _createService,
                  child: ref.watch(serviceController)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditMode ? 'Update Schedule' : 'Create Service',
                        style: AppTextStyle(context).bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchedulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Schedules',
          style: AppTextStyle(context).title,
        ),
        Gap(8.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          separatorBuilder: (context, index) => Gap(8.h),
          itemBuilder: (context, index) {
            final schedule = schedules[index];
            return Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.violetColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time: ${schedule.startTime.toString()}',
                          style: AppTextStyle(context).bodyText,
                        ),
                        Text(
                          'Limit: ${schedule.limitPetOwner}',
                          style: AppTextStyle(context).bodyText,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeSchedule(index),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

 Widget _buildScheduleForm() {
  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: AppColor.violetColor.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditMode ? 'Update Schedule' : 'Add New Schedule',
          style: AppTextStyle(context).appBarText,
        ),
        Gap(16.h),
        InkWell(
          onTap: _selectDateTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.violetColor),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedTime?.toString() ?? 'Select Start Time',
                  style: AppTextStyle(context).bodyText,
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        Gap(16.h),
        TextFormField(
          controller: limitController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Limit Pet Owner',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter limit';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        Gap(16.h),
        // Thêm button Add Schedule nếu không phải edit mode
        if (!isEditMode)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.violetColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
              onPressed: _addSchedule,
              child: Text(
                'Add Schedule',
                style: AppTextStyle(context).bodyText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedTime ?? DateTime.now()),
      );
      
      if (time != null) {
        setState(() {
          selectedTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  void _addSchedule() {
    if (selectedTime == null || limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final limit = int.tryParse(limitController.text);
    if (limit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid limit')),
      );
      return;
    }

    setState(() {
      schedules.add(CreateScheduleRequest(
        startTime: selectedTime!,
        limitPetOwner: limit,
      ));
      selectedTime = null;
      limitController.clear();
    });
  }

  Future<void> _updateSchedule() async {
    if (selectedTime == null || limitController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final limit = int.tryParse(limitController.text);
    if (limit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid limit')),
      );
      return;
    }

    final updatedSchedule = CreateScheduleRequest(
      startTime: selectedTime!,
      limitPetOwner: limit,
    );

    widget.onUpdate?.call(updatedSchedule);
    Navigator.of(context).pop();
  }

  void _removeSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  Future<void> _createService() async {
    if (schedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one schedule')),
      );
      return;
    }

    final request = CreateStoreServiceRequest(
      serviceId: widget.serviceId,
      createScheduleRequests: schedules,
    );

    final result = await ref.read(serviceController.notifier).createStoreService(
      request: request,
    );

    if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      Navigator.of(context).pop();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create service')),
      );
    }
  }
}