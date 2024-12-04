import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/core/utils/app_text_style.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CheckinConfirmationScreen extends ConsumerStatefulWidget {
  final int orderId;
  final String apiUrl;
  final Map<String, dynamic> requestData;
  final bool isCheckout;

  const CheckinConfirmationScreen({
    Key? key,
    required this.orderId,
    required this.apiUrl,
    required this.requestData,
    this.isCheckout = false,
  }) : super(key: key);

  @override
  ConsumerState<CheckinConfirmationScreen> createState() =>
      _CheckinConfirmationScreenState();
}

class _CheckinConfirmationScreenState
    extends ConsumerState<CheckinConfirmationScreen> {
  File? _selectedImage;
  File? _checkoutImage;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  DateTime? _nextVaccineDate;
  TimeOfDay? _nextVaccineTime;

  // Controllers for checkout form
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  //DateTime? _nextVaccineDate;

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source,
      {bool isCheckoutImage = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isCheckoutImage) {
            _checkoutImage = File(image.path);
          } else {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      GlobalFunction.showCustomSnackbar(
        message: 'Có lỗi khi chọn ảnh: ${e.toString()}',
        isSuccess: false,
      );
    }
  }

  Future<void> _submit() async {
    // Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Image validation
    if (widget.isCheckout &&
        (_selectedImage == null || _checkoutImage == null)) {
      GlobalFunction.showCustomSnackbar(
        message: 'Vui lòng chọn đầy đủ ảnh trước và sau khi trả',
        isSuccess: false,
      );
      return;
    }

    if (!widget.isCheckout && _selectedImage == null) {
      GlobalFunction.showCustomSnackbar(
        message: 'Vui lòng chọn ảnh check-in',
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get auth token
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) throw Exception('Không tìm thấy token xác thực');

      // Create form data
      final formData = FormData();

      // Log initial request data
      debugPrint('\n=== Request Data ===');
      debugPrint('API URL: ${widget.apiUrl}');
      debugPrint('Is Checkout: ${widget.isCheckout}');
      debugPrint('Order ID: ${widget.orderId}');

      if (widget.isCheckout) {
        // Log checkout form data
        debugPrint('\nCheckout Form Data:');
        debugPrint('Name: ${_nameController.text}');
        debugPrint('Weight: ${_weightController.text}');
        debugPrint(
            'Next Vaccine Date: ${_nextVaccineDate != null ? DateFormat('dd-MM-yyyy').format(_nextVaccineDate!) : 'null'}');
        debugPrint('Description: ${_descriptionController.text}');
        debugPrint('Has Before Image: ${_selectedImage != null}');
        debugPrint('Has After Image: ${_checkoutImage != null}');

        // Add basic fields
        formData.fields.addAll([
          MapEntry('Id', widget.orderId.toString()),
          MapEntry('Name', _nameController.text.trim()),
          MapEntry('PetCurrentWeight', _weightController.text.trim()),
          MapEntry('Description', _descriptionController.text.trim()),
        ]);

        // Add date if available
        if (_nextVaccineDate != null) {
          formData.fields.add(MapEntry('NextVaccineDate',
              DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(_nextVaccineDate!)));
        }

        // Add checkout image
        if (_checkoutImage != null) {
          String fileName = _checkoutImage!.path.split('/').last;
          String mimeType =
              fileName.endsWith('.png') ? 'image/png' : 'image/jpeg';

          formData.files.add(MapEntry(
            'CheckoutImage',
            await MultipartFile.fromFile(
              _checkoutImage!.path,
              filename: fileName,
              contentType: DioMediaType.parse(mimeType),
            ),
          ));
        }

        // Add before image
        if (_selectedImage != null) {
          String fileName = _selectedImage!.path.split('/').last;
          String mimeType =
              fileName.endsWith('.png') ? 'image/png' : 'image/jpeg';

          formData.files.add(MapEntry(
            'Image',
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: fileName,
              contentType: DioMediaType.parse(mimeType),
            ),
          ));
        }
      } else {
        // Log checkin data
        debugPrint('\nCheckin Data:');
        debugPrint('ID: ${widget.orderId}');
        debugPrint('Has Image: ${_selectedImage != null}');

        // Add ID for checkin
        formData.fields.add(MapEntry('Id', widget.orderId.toString()));

        // Add checkin image
        if (_selectedImage != null) {
          String fileName = _selectedImage!.path.split('/').last;
          String mimeType =
              fileName.endsWith('.png') ? 'image/png' : 'image/jpeg';

          formData.files.add(MapEntry(
            'CheckinImagge', // Note: Fixed typo in field name
            await MultipartFile.fromFile(
              _selectedImage!.path,
              filename: fileName,
              contentType: DioMediaType.parse(mimeType),
            ),
          ));
        }
      }

      // Log final form data
      debugPrint('\n=== Final FormData ===');
      for (var field in formData.fields) {
        debugPrint('Field: ${field.key} = ${field.value}');
      }
      for (var file in formData.files) {
        debugPrint('File: ${file.key} = ${file.value.filename}');
      }

      // Create Dio instance with logging
      final dio = Dio()
        ..interceptors.add(LogInterceptor(
            requestBody: true,
            responseBody: true,
            error: true,
            requestHeader: true,
            responseHeader: true,
            logPrint: (obj) {
              debugPrint(obj.toString());
            }));

      try {
        final response = await dio.patch(
          widget.apiUrl,
          data: formData,
          options: Options(
            headers: {
              HttpHeaders.authorizationHeader: 'Bearer $token',
              'accept': '*/*',
            },
            validateStatus: (status) => status == 200,
          ),
        );

        debugPrint('\n=== Success Response ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Response Data: ${response.data}');

        if (mounted) {
          Navigator.of(context).pop(true);
          GlobalFunction.showCustomSnackbar(
            message: widget.isCheckout
                ? 'Check-out thành công'
                : 'Check-in thành công',
            isSuccess: true,
          );
        }
      } on DioException catch (e) {
        debugPrint('\n=== Error Details ===');
        debugPrint('Status Code: ${e.response?.statusCode}');
        debugPrint('Error Type: ${e.type}');
        debugPrint('Error Message: ${e.message}');
        debugPrint('Error Response: ${e.response?.data}');

        String errorMessage = 'Có lỗi xảy ra';

        if (e.response?.data is Map) {
          final errorData = e.response?.data as Map;
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'].toString();
          } else if (errorData.containsKey('errors')) {
            if (errorData['errors'] is Map) {
              // Handle structured error messages
              errorMessage = (errorData['errors'] as Map).values.join(', ');
            } else {
              errorMessage = errorData['errors'].toString();
            }
          }
        }

        if (mounted) {
          GlobalFunction.showCustomSnackbar(
            message: errorMessage,
            isSuccess: false,
          );
        }

        if (e.response?.statusCode == 400) {
          debugPrint('\n=== Request Details for 400 Error ===');
          debugPrint('Request Data:');
          if (e.requestOptions.data is FormData) {
            final fd = e.requestOptions.data as FormData;
            debugPrint('Fields:');
            for (var field in fd.fields) {
              debugPrint('  ${field.key}: ${field.value}');
            }
            debugPrint('Files:');
            for (var file in fd.files) {
              debugPrint('  ${file.key}: ${file.value.filename}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('\nUnexpected Error: $e');
      if (mounted) {
        GlobalFunction.showCustomSnackbar(
          message: 'Có lỗi xảy ra: ${e.toString()}',
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.isCheckout ? 'Xác nhận Check-out' : 'Xác nhận Check-in'),
        backgroundColor: AppColor.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.isCheckout) ...[
                _buildImageSection(
                  title: 'Ảnh trước khi trả',
                  image: _selectedImage,
                  onPick: (source) => _pickImage(source),
                ),
                Gap(20.h),
                _buildImageSection(
                  title: 'Ảnh sau khi trả',
                  image: _checkoutImage,
                  onPick: (source) => _pickImage(source, isCheckoutImage: true),
                ),
                Gap(20.h),
                _buildCheckoutForm(),
              ] else
                _buildImageSection(
                  title: 'Ảnh check-in',
                  image: _selectedImage,
                  onPick: (source) => _pickImage(source),
                ),
              Gap(24.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.violetColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.isCheckout
                            ? 'Xác nhận Check-out'
                            : 'Xác nhận Check-in',
                        style: AppTextStyle(context).buttonText.copyWith(
                              color: Colors.white,
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

  Widget _buildImageSection({
    required String title,
    required File? image,
    required Function(ImageSource) onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle(context).bodyText.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Gap(8.h),
        Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColor.violetColor.withOpacity(0.3)),
          ),
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (title.contains('sau')) {
                              _checkoutImage = null;
                            } else {
                              _selectedImage = null;
                            }
                          });
                        },
                        icon: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_outlined,
                      size: 48.sp,
                      color: Colors.grey,
                    ),
                    Gap(8.h),
                    Text(
                      'Chưa có ảnh được chọn',
                      style: AppTextStyle(context).bodyText.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
        ),
        Gap(8.h),
        Row(
          children: [
            Expanded(
              child: _buildImageSourceButton(
                'Chụp ảnh',
                Icons.camera_alt,
                () => onPick(ImageSource.camera),
              ),
            ),
            Gap(8.w),
            Expanded(
              child: _buildImageSourceButton(
                'Thư viện',
                Icons.photo_library,
                () => onPick(ImageSource.gallery),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Tên',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vui lòng nhập tên';
            return null;
          },
        ),
        Gap(16.h),
        TextFormField(
          controller: _weightController,
          decoration: InputDecoration(
            labelText: 'Cân nặng hiện tại',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            suffixText: 'kg',
          ),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vui lòng nhập cân nặng';
            if (double.tryParse(value!) == null)
              return 'Vui lòng nhập số hợp lệ';
            return null;
          },
        ),
        Gap(16.h),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate:
                  _nextVaccineDate ?? DateTime.now().add(Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );

            if (date != null) {
              final time = await showTimePicker(
                context: context,
                initialTime: _nextVaccineTime ?? TimeOfDay.now(),
              );

              if (time != null) {
                setState(() {
                  _nextVaccineTime = time;
                  _nextVaccineDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  );
                });
              }
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Ngày và giờ tiêm vaccine tiếp theo',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _nextVaccineDate != null
                      ? DateFormat('HH:mm dd/MM/yyyy')
                          .format(_nextVaccineDate!) // Format hiển thị cho user
                      : 'Chọn ngày và giờ',
                  style: TextStyle(
                    color: _nextVaccineDate != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Colors.grey[600],
                  ),
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
        Gap(16.h),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Ghi chú',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImageSourceButton(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColor.violetColor),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColor.violetColor),
          Gap(8.w),
          Text(
            label,
            style: AppTextStyle(context).bodyText.copyWith(
                  color: AppColor.violetColor,
                ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // If this is a checkout confirmation, set initial values if available from requestData
    if (widget.isCheckout && widget.requestData.containsKey('initialData')) {
      final initialData =
          widget.requestData['initialData'] as Map<String, dynamic>;
      _nameController.text = initialData['Name'] ?? '';
      _weightController.text =
          initialData['PetCurrentWeight']?.toString() ?? '';
      _descriptionController.text = initialData['Description'] ?? '';

      if (initialData['NextVaccineDate'] != null) {
        try {
          _nextVaccineDate =
              DateFormat('dd-MM-yyyy').parse(initialData['NextVaccineDate']);
        } catch (e) {
          debugPrint('Error parsing initial date: $e');
        }
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      return false;
    }

    if (_selectedImage != null ||
        _checkoutImage != null ||
        _nameController.text.isNotEmpty ||
        _weightController.text.isNotEmpty ||
        _descriptionController.text.isNotEmpty ||
        _nextVaccineDate != null) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Xác nhận hủy',
            style: AppTextStyle(context).title.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          content: Text(
            'Bạn có những thay đổi chưa được lưu. Bạn có chắc chắn muốn hủy không?',
            style: AppTextStyle(context).bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Không',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Có',
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }

    return true;
  }

  void _showFullScreenImage(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40.sp,
                ),
              ),
              Gap(16.h),
              Text(
                widget.isCheckout
                    ? 'Check-out thành công!'
                    : 'Check-in thành công!',
                style: AppTextStyle(context).title.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Gap(8.h),
              Text(
                'Thao tác đã được xử lý thành công',
                textAlign: TextAlign.center,
                style: AppTextStyle(context).bodyText.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              Gap(24.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(
                      true); // Return to previous screen with success result
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                ),
                child: Text(
                  'Đóng',
                  style: AppTextStyle(context).buttonText.copyWith(
                        color: Colors.white,
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
}
