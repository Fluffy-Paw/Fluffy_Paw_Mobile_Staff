import 'package:dio/dio.dart';

abstract class DashboardProvider{
  Future<Response> getDashboardInfo();
}