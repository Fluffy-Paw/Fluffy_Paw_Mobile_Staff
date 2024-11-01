import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/request_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient{
  final Dio _dio = Dio();

  ApiClient() {
    addApiInterceptors(_dio);
  }

  Map<String, dynamic> defaultHeaders = {
    HttpHeaders.authorizationHeader: null
  };

  Future<Response> get(String url, {Map<String, dynamic>? query}) async {
  return _dio.get(
    url,
    queryParameters: query,
    options: Options(
      headers: defaultHeaders,
      followRedirects: false,
      validateStatus: (status) {
            // Accept all status codes and handle them in the business logic
            return true;
          },
    ),
  );
}

  Future<Response> post(
      String url, {
        dynamic data,
        Map<String, dynamic>? headers,
      }) async {
    return _dio.post(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        followRedirects: false,
        validateStatus: ((status) {
          if (status == 403) {
          return false;
        }
          return status! <= 500;
        }),
      ),
    );
    
    
  }
  Future<Response> put(
      String url, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? headers,
      }) async {
    return _dio.put(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        followRedirects: false,
        validateStatus: ((status) {
          return status! <= 500;
        }),
      ),
    );
  }
  Future<Response> patch(
    String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    return _dio.patch(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        followRedirects: false,
        validateStatus: (status) {
          return status! <= 500;
        },
      ),
    );
  }
  Future<Response> delete(
      String url, {
        Map<String, dynamic>? data,
        Map<String, dynamic>? headers,
      }) async {
    return _dio.delete(
      url,
      data: data,
      options: Options(
        headers: headers ?? defaultHeaders,
        followRedirects: false,
        validateStatus: ((status) {
          return status! <= 500;
        }),
      ),
    );
  }
  void updateToken({required String token}) {
    defaultHeaders[HttpHeaders.authorizationHeader] = 'Bearer $token';
    debugPrint(
        'Update Token:${defaultHeaders[HttpHeaders.authorizationHeader]}');
  }
}

final apiClientProvider = Provider((ref) => ApiClient());