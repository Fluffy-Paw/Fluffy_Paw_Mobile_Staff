import 'package:fluffypawsm/data/controller/notification_controller.dart';
import 'package:fluffypawsm/data/controller/order_controller.dart';
import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/models/notification/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

//select image state
final selectedUserProfileImage = StateProvider<XFile?>((ref) => null);
final selectedShopLogo = StateProvider<XFile?>((ref) => null);
final selectedShopBanner = StateProvider<XFile?>((ref) => null);

final dateOfBirthProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final obscureText1 = StateProvider<bool>((ref) => true);
final signalRStatusProvider = StateProvider<SignalRStatus>((ref) => SignalRStatus.disconnected);

enum SignalRStatus {
  connected,
  disconnected,
  error
}
final orderIdProvider = StateProvider<int>((ref) => 0);
final selectedIndexProvider = StateProvider<int>((ref) => 0);
final selectedDateFilter = StateProvider<String>((ref) => '');
final signalRInitializedProvider = StateProvider<bool>((ref) => false);
final selectedDate = StateProvider<DateTime?>((ref) => null);
final orderCountsProvider = StateProvider<Map<String, int>>((ref) => {});
final isLoadingCountsProvider = StateProvider<bool>((ref) => false);
final riderIdProvider = StateProvider<int>((ref) => 0);
final dashboardPendingOrdersProvider = StateProvider<List<Order>>((ref) => []);
final bottomTabControllerProvider =
Provider<PageController>((ref) => PageController());
final genderProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final phoneProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final emailProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final passwordProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final firstNameProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final lastNameProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();

  ref.onDispose(() {
    controller.dispose();
  });
  return controller;
});
final ridersFormKey = Provider<GlobalKey<FormBuilderState>>(
    (ref) => GlobalKey<FormBuilderState>());
final activeOrderTab = StateProvider<int>((ref) => 0);
final selectedOrderStatus = StateProvider<String>((ref) => 'Pending');
final selectedFilterProvider = StateProvider<NotificationType?>((ref) => null);

final filteredNotificationsProvider = Provider<List<PetNotification>>((ref) {
  final state = ref.watch(notificationControllerProvider);
  final filter = ref.watch(selectedFilterProvider);
  
  if (filter == null) return state.notifications;
  return state.notifications.where((n) => n.type == filter).toList();
});

final unreadCountProvider = Provider.family<int, NotificationType?>((ref, type) {
  return ref.watch(notificationControllerProvider.notifier).getUnreadCount(type);
});

final notificationCountProvider = Provider.family<int, NotificationType?>((ref, type) {
  return ref.watch(notificationControllerProvider.notifier).getNotificationCount(type);
});
// final orderController =
// StateNotifierProvider<OrderController, bool>((ref) => OrderController(ref));





// final orderStatusController =
// StateNotifierProvider<OrderStatusController, bool>(
//         (ref) => OrderStatusController(ref));