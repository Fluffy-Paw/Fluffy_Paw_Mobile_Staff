import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

void addApiInterceptors(Dio dio) {
  dio.options.connectTimeout = const Duration(seconds: 120);
  dio.options.receiveTimeout = const Duration(seconds: 120);
  dio.options.headers['Accept'] = 'application/json';
  // logger
  dio.interceptors.add(PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  ));

  // respone handler
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.next(options);
      },
      onResponse: (response, handler) {
        final message = response.data['message'];
        switch (response.statusCode) {
          case 401:
            Box authBox = Hive.box(AppConstants.authBox);
            authBox.delete(AppConstants.authToken);
            GlobalFunction.navigatorKey.currentState
                ?.pushNamedAndRemoveUntil(Routes.login, (route) => false);
            GlobalFunction.showCustomSnackbar(
              message: message,
              isSuccess: false,
            );
            break;
          case 302:
          case 400:
          case 403:
          //case 404:
          case 409:
          case 422:
          case 500:
            GlobalFunction.showCustomSnackbar(
              message: message,
              isSuccess: false,
            );
            break;
          default:
            break;
        }
        handler.next(response);
      },
      onError: (error, handler) {
        // switch (error.type) {
        //   case DioExceptionType.connectionError:
        //   case DioExceptionType.connectionTimeout:
        //   case DioExceptionType.badResponse:
        //   case DioExceptionType.sendTimeout:
        //   case DioExceptionType.receiveTimeout:
        //   case DioExceptionType.unknown:
        //     GlobalFunction.showCustomSnackbar(
        //       message: 'An unknown error occurred',
        //       isSuccess: false,
        //     );
        //     break;
        //   default:
        //     break;
        // }
        if (error.response != null) {
          final message = error.response!.data['message'];
          final statusCode = error.response!.statusCode;
          switch (statusCode) {
            case 404:
              handler.reject(error);
              return;

            case 401:
              Box authBox = Hive.box(AppConstants.authBox);
              authBox.delete(AppConstants.authToken);
              GlobalFunction.navigatorKey.currentState
                  ?.pushNamedAndRemoveUntil(Routes.login, (route) => false);
              break;
            case 403:
              GlobalFunction.showCustomSnackbar(
                message: message,
                isSuccess: false,
              );
              break;
            default:
              GlobalFunction.showCustomSnackbar(
                message: 'unexpected error',
                isSuccess: false,
              );
              break;
          }
        } else {
          switch (error.type) {
          case DioExceptionType.connectionError:
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.badResponse:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.unknown:
            GlobalFunction.showCustomSnackbar(
              message: 'An unknown error occurred',
              isSuccess: false,
            );
            break;
          default:
            break;
        }
        }
        handler.reject(error);
      },
    ),
  );
}
