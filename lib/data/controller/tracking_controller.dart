import 'package:fluffypawsm/data/models/tracking/tracking_model.dart';
import 'package:fluffypawsm/data/repositories/order_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class TrackingController extends StateNotifier<AsyncValue<List<TrackingInfo>>> {
  final Ref ref;
  
  TrackingController(this.ref) : super(const AsyncValue.loading());

  Future<void> getTrackingInfo(int bookingId) async {
    try {
      state = const AsyncValue.loading();
      
      final response = await ref.read(orderServiceProvider).getTrackingByBookingId(bookingId);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final trackingList = data
            .map((item) => TrackingInfo.fromMap(item as Map<String, dynamic>))
            .toList();
        
        state = AsyncValue.data(trackingList);
      } else {
        state = AsyncValue.error(
          'Failed to load tracking info',
          StackTrace.current,
        );
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<void> uploadTracking({
    required int bookingId,
    required String description,
    required List<XFile> images,
  }) async {
    try {
      // Create temporary tracking
      final tempTracking = TrackingInfo.temp(
        bookingId: bookingId,
        description: description,
        images: images,
      );
      
      // Add temporary tracking to the list
      state.whenData((trackingList) {
        state = AsyncValue.data([tempTracking, ...trackingList]);
      });
      
      // Attempt to upload
      final response = await ref.read(orderServiceProvider).createTracking(
        bookingId: bookingId,
        description: description,
        files: images,
      );
      
      if (response.statusCode == 200) {
        // Remove temporary and get fresh data
        await getTrackingInfo(bookingId);
      } else {
        // Update temporary tracking with error
        state.whenData((trackingList) {
          final updatedList = trackingList.map((tracking) {
            if (tracking.id == tempTracking.id) {
              return tracking.copyWith(error: 'Failed to upload tracking');
            }
            return tracking;
          }).toList();
          state = AsyncValue.data(updatedList);
        });
        throw Exception('Failed to upload tracking');
      }
    } catch (e) {
      throw e;
    }
  }
}

final trackingControllerProvider = StateNotifierProvider<TrackingController, AsyncValue<List<TrackingInfo>>>(
  (ref) => TrackingController(ref),
);