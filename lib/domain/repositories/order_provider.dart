import 'package:dio/dio.dart';

abstract class OrderProvider {
    Future<Response> getOrderListWithFilter(String status);
}