import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/data/models/service/create_store.dart';
import 'package:fluffypawsm/data/models/service/service.dart';
import 'package:fluffypawsm/presentation/pages/authentication/signup_view.dart';
import 'package:fluffypawsm/presentation/pages/authentication/under_review_view.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/bottom_navigation_bar_view.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/dashboard_view.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/layouts/dashboard_layout.dart';
import 'package:fluffypawsm/presentation/pages/notification/notification_view.dart';
import 'package:fluffypawsm/presentation/pages/order/order_details_view.dart';
import 'package:fluffypawsm/presentation/pages/profile/seller_account_view.dart';
import 'package:fluffypawsm/presentation/pages/services/create_store_service_view.dart';
import 'package:fluffypawsm/presentation/pages/services/service_detail_view.dart';
import 'package:fluffypawsm/presentation/pages/services/service_list_view.dart';
import 'package:fluffypawsm/presentation/pages/splash_screen/splash_view.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/profile/store_manager_profile_layout.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/profile/store_manager_profile_view.dart';
import 'package:fluffypawsm/presentation/pages/store_manager/store/store_list_view.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'presentation/pages/authentication/login_view.dart';

class Routes{
  Routes._();
  static const splash = '/';
  static const login = '/login';
  static const core = '/core';
  static const sellerAccount = '/sellerAccount';
  static const orderDetailsView ='/orderDetails';
  static const serviceDetails = '/serviceDetails';
  static const createStoreService = '/createStoreService';
  static const notification="/notification";
  static const signUp = '/signUp';
  static const underReviewAccount = '/underReviewAccount';
  static const serviceListByBrand = '/serviceListByBrand';
  static const storeList = '/storeList';
  static const storeManagerProfile = '/storeManagerProfile';
}
class StoreServiceRouteArgs {
  final int serviceId;
  final CreateScheduleRequest? scheduleToEdit;
  final Function(CreateScheduleRequest)? onUpdate;

  StoreServiceRouteArgs({
    required this.serviceId,
    this.scheduleToEdit,
    this.onUpdate,
  });
}

Route generatedRoutes(RouteSettings settings){
  Widget child;

  switch(settings.name){
    case Routes.splash:
      child = const SplashView();
      break;
    case Routes.notification:
      child = const NotificationView();
    case Routes.login:
      child = const LoginView();
      break;
    case Routes.signUp:
      child = const SignUpView();
      break;
    case Routes.underReviewAccount:
      child = const UnderReviewView();
      break;
    case Routes.core:
      child = const BottomNavigationBarView();
      break;
    case Routes.sellerAccount:
      child = const SellerAccountView();
      break;
    case Routes.storeManagerProfile:
      child = const StoreManagerProfileView();
      break;
    case Routes.serviceListByBrand:
      child = const ServiceListView();
      break;
    case Routes.storeList:
      child = const StoreListView();
      break;

    case Routes.createStoreService:
      final args = settings.arguments as StoreServiceRouteArgs;
      child = StoreServiceView(
        serviceId: args.serviceId,
        scheduleToEdit: args.scheduleToEdit,
        onUpdate: args.onUpdate,
      );
      break;
    case Routes.serviceDetails:
      final riderInfo = settings.arguments as Service;
      child = ServiceDetailView(riderInfo: riderInfo);
      break;
    case Routes.orderDetailsView:
      final order = settings.arguments as Order;
      child = OrderDetailsView(
        order: order,
      );
    default:
      throw Exception('Invalid route: ${settings.name}');
  }
  debugPrint('Route: ${settings.name}');

  return PageTransition(
    child: child,
    type: PageTransitionType.fade,
    settings: settings,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );
}