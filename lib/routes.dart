import 'package:fluffypawsm/data/models/dashboard/dashboard_model.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/bottom_navigation_bar_view.dart';
import 'package:fluffypawsm/presentation/pages/bottom_navigation_bar/layouts/bottom_navigation_layout.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/dashboard_view.dart';
import 'package:fluffypawsm/presentation/pages/dashboard/layouts/dashboard_layout.dart';
import 'package:fluffypawsm/presentation/pages/order/order_details_view.dart';
import 'package:fluffypawsm/presentation/pages/profile/seller_account_view.dart';
import 'package:fluffypawsm/presentation/pages/splash_screen/splash_view.dart';
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
}

Route generatedRoutes(RouteSettings settings){
  Widget child;

  switch(settings.name){
    case Routes.splash:
      child = const SplashView();
      break;
    case Routes.login:
      child = const LoginView();
      break;
    case Routes.core:
      child = const BottomNavigationBarView();
      break;
    case Routes.sellerAccount:
      child = const SellerAccountView();
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