import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BookingProvider {
  Future<Response> getAllBookings();
}

class BookingService implements BookingProvider {
  final Ref ref;

  BookingService(this.ref);

  @override
  Future<Response> getAllBookings() async {
    final response = await ref.read(apiClientProvider).get(
          AppConstants.getAllBookingByStoreSM,
        );
    return response;
  }
}

final bookingServiceProvider = Provider((ref) => BookingService(ref));