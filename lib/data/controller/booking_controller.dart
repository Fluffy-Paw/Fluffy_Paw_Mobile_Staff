import 'package:fluffypawsm/data/models/booking/booking_model.dart';
import 'package:fluffypawsm/data/repositories/booking_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingController extends StateNotifier<bool> {
  final Ref ref;
  List<StoreBookingModel>? _bookings;
  List<StoreBookingModel>? get bookings => _bookings;

  BookingController(this.ref) : super(false);

  Future<void> getAllBookings() async {
    try {
      state = true;
      final response = await ref.read(bookingServiceProvider).getAllBookings();
      _bookings = (response.data['data'] as List)
          .map((item) => StoreBookingModel.fromMap(item))
          .toList();
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting bookings: ${e.toString()}');
      rethrow;
    }
  }
}

final bookingController = StateNotifierProvider<BookingController, bool>(
  (ref) => BookingController(ref),
);