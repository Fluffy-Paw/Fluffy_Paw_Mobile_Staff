import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluffypawsm/core/utils/app_color.dart';
import 'package:fluffypawsm/dependency_injection/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../generated/l10n.dart';
import 'constants.dart';

class GlobalFunction {
  GlobalFunction._();
  static Future<void> datePicker({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime.now().add(
        const Duration(days: 365),
      ),
    ).then((selectedDate) {
      ref.read(dateOfBirthProvider).text = formateDate(selectedDate!);
    });
  }

  static String formateDate(DateTime date) {
    final DateFormat dateFormatter = DateFormat('dd/MM/yyyy', 'en');
    return dateFormatter.format(date);
  }

  static Future<void> pickImageFromCamera({required WidgetRef ref}) async {
    final picker = ImagePicker();
    await picker.pickImage(source: ImageSource.camera).then((imageFile) {
      if (imageFile != null) {
        ref.read(selectedUserProfileImage.notifier).state = imageFile;
      }
    });
  }

  static Future<void> pickImageFromGallery({
    required WidgetRef ref,
    required ImageType imageType,
    ImageSource? imageSource,  // Thêm parameter này
  }) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: imageSource ?? ImageSource.gallery,
    );

    if (pickedImage != null) {
      switch (imageType) {
        case ImageType.userProfile:
          ref.read(selectedUserProfileImage.notifier).state = pickedImage;
          break;
        case ImageType.frontId:
          ref.read(frontIdProvider.notifier).state = pickedImage;
          break;
        case ImageType.backId:
          ref.read(backIdProvider.notifier).state = pickedImage;
          break;
        case ImageType.businessLicense:
          ref.read(businessLicenseProvider.notifier).state = pickedImage;
          break;
        case ImageType.shopLogo:
          ref.read(selectedShopLogo.notifier).state = pickedImage;
          break;
        case ImageType.shopBanner:
          ref.read(selectedShopBanner.notifier).state = pickedImage;
          break;
      }
    }
  }
   static Future<void> pickFileFromSystem({
    required WidgetRef ref,
    required ImageType imageType,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = XFile(result.files.first.path!);
        
        switch (imageType) {
          case ImageType.shopLogo:
            ref.read(selectedShopLogo.notifier).state = file;
            break;
          case ImageType.businessLicense:
            ref.read(businessLicenseProvider.notifier).state = file;
            break;
          case ImageType.frontId:
            ref.read(frontIdProvider.notifier).state = file;
            break;
          case ImageType.backId:
            ref.read(backIdProvider.notifier).state = file;
            break;
          case ImageType.userProfile:
            ref.read(selectedUserProfileImage.notifier).state = file;
            break;
          case ImageType.shopBanner:
            ref.read(selectedShopBanner.notifier).state = file;
            break;
        }
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      showCustomSnackbar(
        message: 'Không thể chọn file. Vui lòng thử lại',
        isSuccess: false,
      );
    }
  }

  // Thêm phương thức kiểm tra file type
  static bool isValidFileType(String filePath) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    final extension = filePath.toLowerCase().split('.').last;
    return validExtensions.contains('.$extension');
  }

  static Future<bool> checkGalleryPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  static String getDashboardSummeryLocalizationText(
      {required String text, required BuildContext context}) {
    switch (text) {
      case "Today's Order":
        return S.of(context).todaysOrder;
      case "Ongoing Order":
        return S.of(context).ongoingOrder;
      case "Today's Earnings":
        return S.of(context).todaysEarnings;
      default:
        return S.of(context).earndThisMonth;
    }
  }

  static String getOrderStatusLocalizationText({
    required String status,
    required BuildContext context,
  }) {
    switch (status) {
      case "Accepted":
        return S.of(context).accepted;
      case "Pending":
        return S.of(context).pending;
      case "Canceled":
        return S.of(context).canceled;
      case "Denied":
        return S.of(context).denied;
      case "OverTime":
        return S.of(context).overTime;
      case "Ended":
        return S.of(context).ended;
      default:
        return S.of(context).cancelled;
    }
  }

  static String getRidersStatusLocalizationText(
      {required String status, required BuildContext context}) {
    switch (status) {
      case 'Active':
        return S.of(context).active;
      default:
        return S.of(context).inActive;
    }
  }

  static String getPaymentStatusLocalizationText(
      {required String status, required BuildContext context}) {
    switch (status) {
      case 'Cash Payment':
        return S.of(context).cod;
      default:
        return S.of(context).onlinePayment;
    }
  }

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Cập nhật showCustomSnackbar trong GlobalFunction
  static void showCustomSnackbar({
    required String message,
    required bool isSuccess,
    bool isTop = false,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.fixed, // Thay đổi floating thành fixed
      backgroundColor: isSuccess ? AppColor.violetColor : AppColor.redColor,
      content: Text(message),
    );
    ScaffoldMessenger.of(navigatorKey.currentState!.context)
        .showSnackBar(snackBar);
  }

  static void changeStatusBarTheme({required isDark}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  static String errorText(
      {required String fieldName, required BuildContext context}) {
    return '$fieldName ${S.of(context).validationMessage}';
  }

  static String? firstNameValidator(
      {required String value,
      required String hintText,
      required BuildContext context}) {
    if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    } else if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? mstValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    // Có thể thêm validate cho định dạng MST nếu cần
    return null;
  }

  static String? businessDocumentValidator({
    required dynamic value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value == null) {
      return 'Please upload $hintText';
    }
    return null;
  }

  static String? lastNameNameValidator(
      {required String value,
      required String hintText,
      required BuildContext context}) {
    if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    } else if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? phoneValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (value.length != 10) {
      // Changed to check for 10 digits
      return 'Please enter a valid $hintText with exactly 10 digits';
    }
    return null;
  }

  static String? emailValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid $hintText';
    }

    return null;
  }

  static String? defaultValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? shopNameValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (containsNumber(value)) {
      return 'Please enter valid $hintText';
    }
    return null;
  }

  static String? orderPrefixCodeValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? dateOfBirthValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? shopDesValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    }
    return null;
  }

  static String? passwordValidator({
    required String value,
    required String hintText,
    required BuildContext context,
  }) {
    if (value.isEmpty) {
      return errorText(fieldName: hintText, context: context);
    } else if (value.length < 6) {
      return 'Please enter a valid $hintText with at least 6 characters';
    }

    return null;
  }

  static bool containsNumber(String input) {
    final RegExp numericRegex = RegExp(r'\d');
    return numericRegex.hasMatch(input);
  }

  static Color getStatusCardColor({required String status}) {
    switch (status) {
      case 'Accepted':
        return AppColor.delivered; // Màu của trạng thái "Accepted"
      case 'Pending':
        return AppColor.pending; // Màu của trạng thái "Pending"
      case 'Canceled':
        return AppColor.redColor; // Màu của trạng thái "Canceled"
      case 'Denied':
        return AppColor.redColor; // Màu của trạng thái "Denied"
      case 'OverTime':
        return Colors.orange; // Màu của trạng thái "OverTime"
      case 'Ended':
        return Colors.green; // Màu của trạng thái "Ended"
      default:
        return AppColor.redColor; // Trạng thái mặc định nếu không khớp
    }
  }

  static void clearControllers({required WidgetRef ref}) {
    // Account Information Controllers
    ref.refresh(usernameProvider);
    ref.refresh(fullNameProvider);
    ref.refresh(hotlineProvider);
    ref.refresh(emailProvider);
    ref.refresh(passwordProvider);
    ref.refresh(confirmPasswordProvider);

    // Business Information Controllers
    ref.refresh(nameProvider); // store name
    ref.refresh(mstProvider); // tax code
    ref.refresh(addressProvider);
    ref.refresh(brandEmailProvider);

    // Document Upload Providers
    ref.refresh(businessLicenseProvider);
    ref.refresh(frontIdProvider);
    ref.refresh(backIdProvider);
    ref.refresh(logoProvider);

    // State Providers
    ref.refresh(isCheckBox);
    ref.refresh(isPhoneNumberVerified);
    ref.refresh(obscureText1);
    ref.refresh(obscureText2);
  }

  static String numberLocalization(dynamic number) {
    dynamic local =
        Hive.box(AppConstants.appSettingsBox).get(AppConstants.appLocal);
    double parsedNumber =
        double.tryParse(number.toString().replaceAll(',', '')) ?? 0.0;
    final NumberFormat numberFormat =
        NumberFormat.decimalPattern(local['value']);
    return numberFormat.format(parsedNumber);
  }

  static bool isValidImageFormat(File file) {
    final validExtensions = ['.jpg', '.jpeg', '.png'];
    final extension = file.path.toLowerCase().split('.').last;
    return validExtensions.contains('.$extension');
  }

  static String? validateImageFile({
    required File? file,
    required String fieldName,
    required BuildContext context,
  }) {
    if (file == null) {
      return errorText(fieldName: fieldName, context: context);
    }
    if (!isValidImageFormat(file)) {
      return '$fieldName must be in JPG, JPEG or PNG format';
    }
    return null;
  }

  static String stringLocalization(String inputString, BuildContext context) {
    dynamic local =
        Hive.box(AppConstants.appSettingsBox).get(AppConstants.appLocal);
    final formattedString =
        NumberFormat.simpleCurrency(locale: local).format(0);

    return '$inputString $formattedString';
  }
}

enum ImageType {
  userProfile,
  shopLogo,
  shopBanner,
  businessLicense,
  frontId,
  backId,
}
