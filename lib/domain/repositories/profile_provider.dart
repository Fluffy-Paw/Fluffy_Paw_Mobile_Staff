import 'package:dio/dio.dart';

abstract class ProfileProvider{
  Future<Response> getAccountDetails();
}