import 'dart:io';
import 'package:fluffypawsm/data/controller/store_controller.dart';
import 'package:fluffypawsm/presentation/pages/authentication/components/addess_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _streetController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _operatingLicenseImage;
  List<File> _certificateFiles = [];
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  LatLng _selectedLocation = LatLng(10.850211, 106.7260669);

  void _updateFullAddress() {
    List<String> addressParts = [];
    if (_streetController.text.isNotEmpty) addressParts.add(_streetController.text);
    if (_wardController.text.isNotEmpty) addressParts.add(_wardController.text);
    if (_districtController.text.isNotEmpty) addressParts.add(_districtController.text);
    if (_cityController.text.isNotEmpty) addressParts.add(_cityController.text);

    _addressController.text = addressParts.join(', ');
  }

  Future<void> _openAddressPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerScreen(
          initialLocation: _selectedLocation,
        ),
      ),
    );

    if (result != null && mounted) {
      final details = result['addressDetails'] as Map<String, dynamic>;
      
      setState(() {
        _selectedLocation = result['location'] as LatLng;
      });

      if (_streetController.text.isEmpty) {
        _streetController.text = details['street'] as String;
      }
      
      _wardController.text = details['ward'] as String;
      _districtController.text = details['district'] as String;
      _cityController.text = details['city'] as String;

      _updateFullAddress();

      // Debug logs
      debugPrint('Street: ${_streetController.text}');
      debugPrint('Ward: ${_wardController.text}');
      debugPrint('District: ${_districtController.text}');
      debugPrint('City: ${_cityController.text}');
      debugPrint('Full Address: ${_addressController.text}');
    }
  }

  Future<void> _pickOperatingLicense() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _operatingLicenseImage = File(image.path);
      });
    }
  }

  Future<void> _pickCertificates() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      setState(() {
        _certificateFiles.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  void _removeCertificate(int index) {
    setState(() {
      _certificateFiles.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _operatingLicenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ các trường bắt buộc và tải lên giấy phép hoạt động')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await ref.read(storeController.notifier).createStore(
        operatingLicense: _operatingLicenseImage!,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        userName: _usernameController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        email: _emailController.text.trim(),
        certificates: _certificateFiles,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tạo cửa hàng thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Thông tin địa chỉ'),
        Gap(16.h),
        _buildTextInput(
          controller: _streetController,
          label: 'Số nhà, Đường',
          onChanged: (value) => _updateFullAddress(),
        ),
        Gap(16.h),
        _buildTextInput(
          controller: _wardController,
          label: 'Phường',
          readOnly: true,
        ),
        Gap(16.h),
        _buildTextInput(
          controller: _districtController,
          label: 'Quận',
          readOnly: true,
        ),
        Gap(16.h),
        _buildTextInput(
          controller: _cityController,
          label: 'Thành phố',
          readOnly: true,
        ),
        Gap(16.h),
        _buildAddressPickerButton(),
      ],
    );
  }

  Widget _buildAddressPickerButton() {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: _openAddressPicker,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(
                  Icons.map,
                  color: Colors.grey[600],
                ),
                Gap(12.w),
                Text(
                  'Chọn địa chỉ từ bản đồ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUpload({
    required File? image,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: image == null ? Colors.grey[300]! : const Color(0xFF8B5CF6),
          ),
        ),
        child: image == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 48.sp,
                  color: Colors.grey[400],
                ),
                Gap(8.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordInput({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      children: [
        Container(
          height: 100.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: InkWell(
            onTap: _pickCertificates,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 32.sp,
                    color: const Color(0xFF8B5CF6),
                  ),
                  Gap(8.h),
                  Text(
                    'Thêm chứng chỉ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_certificateFiles.isNotEmpty) ...[
          Gap(16.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _certificateFiles.length,
              separatorBuilder: (context, index) => Gap(12.w),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        _certificateFiles[index],
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: GestureDetector(
                        onTap: () => _removeCertificate(index),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: AppBar(
        title: Text(
          'Tạo cửa hàng mới',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Giấy phép hoạt động'),
              Gap(16.h),
              _buildImageUpload(
                image: _operatingLicenseImage,
                onTap: _pickOperatingLicense,
                label: 'Đăng tải giấy phép hoạt động',
              ),
              Gap(24.h),
              _buildSectionTitle('Thông tin cửa hàng'),
              Gap(16.h),
              _buildTextInput(
                controller: _nameController,
                label: 'Tên cửa hàng',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              Gap(16.h),
              _buildTextInput(
                controller: _phoneController,
                label: 'Số điện thoại',
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              Gap(16.h),
              _buildAddressSection(),
              Gap(24.h),
              _buildSectionTitle('Thông tin tài khoản'),
              Gap(16.h),
              _buildTextInput(
                controller: _usernameController,
                label: 'Tên đăng nhập',
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              Gap(16.h),
              _buildTextInput(
                controller: _emailController,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v!)) {
                    return 'Invalid email';
                  }
                  return null;
                },
              ),
              Gap(16.h),
              _buildPasswordInput(
                controller: _passwordController,
                label: 'Mật khẩu',
                obscureText: _obscurePassword,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  // Add any additional password validation rules here
                  return null;
                },
              ),
              Gap(16.h),
              _buildPasswordInput(
                controller: _confirmPasswordController,
                label: 'Xác nhận mật khẩu',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (v != _passwordController.text) return 'Mật khẩu không trùng khớp';
                  return null;
                },
              ),
              Gap(24.h),
              _buildSectionTitle('Chứng chỉ (Optional)'),
              Gap(16.h),
              _buildCertificatesSection(),
              Gap(32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: _isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Tạo cửa hàng',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
              ),
              Gap(16.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}