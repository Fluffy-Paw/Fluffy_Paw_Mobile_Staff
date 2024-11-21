import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

abstract class OrderProvider {
    Future<Response> getOrderListWithFilter(String status);
    Future<Response> acceptBooking(int id);
    Future<Response> deniedBooking(int id);
    Future<Response> getAllOrders();
    Future<Response> getTrackingByBookingId(int bookingId);
    Future<Response> createTracking({
    required int bookingId,
    required String description,
    required List<XFile> files,
  });
}