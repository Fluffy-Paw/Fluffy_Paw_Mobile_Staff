import 'package:dio/dio.dart';
import 'package:dio/src/response.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/domain/repositories/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class OrderService implements OrderProvider{
  final Ref ref;
  OrderService(this.ref);
  @override
  Future<Response> getOrderListWithFilter(String status) async {
    final response = await ref.read(apiClientProvider).get(
      '${AppConstants.dashboardInfo}?Status=$status',
    );
    return response;
  }
  
  @override
  Future<Response> acceptBooking(int id) async{
    
    final response = await ref.read(apiClientProvider).patch(
      '${AppConstants.acceptBooking}/$id',
    );
    
    return response;
  }
  
  @override
  Future<Response> deniedBooking(int id) async{
    final response = await ref.read(apiClientProvider).patch(
      '${AppConstants.deniedBooking}/$id',
    );
    return response;
  }
  Future<Response> getAllOrders() async {
    final response = await ref.read(apiClientProvider).get(
      AppConstants.dashboardInfo,
    );
    return response;
  }
  @override
  Future<Response> getTrackingByBookingId(int bookingId) async {
    final response = await ref.read(apiClientProvider).get(
      '${AppConstants.baseUrl}/api/Staff/GetAllTrackingByBookingId/$bookingId',
    );
    return response;
  }
  @override
  Future<Response> createTracking({
    required int bookingId,
    required String description,
    required List<XFile> files,
  }) async {
    final formData = FormData.fromMap({
      'BookingId': bookingId,
      'Description': description,
    });

    // Add files to form data
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      formData.files.add(
        MapEntry(
          'Files',
          await MultipartFile.fromFile(
            file.path,
            filename: file.name,
            contentType: DioMediaType('image', 'png'), // Adjust based on file type
          ),
        ),
      );
    }

    return await ref.read(apiClientProvider).post(
      '${AppConstants.baseUrl}/api/Staff/CreateTracking',
      data: formData,
    );
  }
  
  // @override
  // Future<Response> orderDetailById(int id) async{
  //   final response = await ref.read(apiClientProvider).get(
  //     '${AppConstants.dashboardInfo}?Status=$id',
  //   );
  //   return response;
  // }

}
final orderServiceProvider = Provider((ref) => OrderService(ref));