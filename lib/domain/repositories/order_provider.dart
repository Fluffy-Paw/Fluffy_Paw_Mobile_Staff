import 'package:dio/dio.dart';

abstract class OrderProvider {
    Future<Response> getOrderListWithFilter(String status);
    Future<Response> acceptBooking(int id);
    Future<Response> deniedBooking(int id);
}