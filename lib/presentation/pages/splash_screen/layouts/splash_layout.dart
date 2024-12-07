import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/controller/notification_controller.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/data/repositories/background_service.dart';
import 'package:fluffypawsm/presentation/pages/splash_screen/components/logo_animation.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashLayout extends ConsumerStatefulWidget {
  const SplashLayout({super.key});

  @override
  ConsumerState<SplashLayout> createState() => _SplashLayoutState();
}

class _SplashLayoutState extends ConsumerState<SplashLayout> {
  Future<void> initializeApp() async {
  try {
    await Future.delayed(const Duration(seconds: 3));
    
    // Get token from storage
    final token = await ref.read(hiveStoreService).getAuthToken();
    
    if (token == null) {
      if (mounted) {
        context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
      }
      return;
    }
    
    // Validate token expiration
    if (JwtDecoder.isExpired(token)) {
      await ref.read(hiveStoreService).removeAllData();
      if (mounted) {
        context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
      }
      return;
    }
    
    // Update API client token first
    ref.read(apiClientProvider).updateToken(token: token);

    try {
      // Get user profile first
      await ref.read(profileController.notifier).getAccountDetails();
      
      // Initialize SignalR
      //await ref.read(notificationControllerProvider.notifier).initializeSignalR();
      
      // Try to get dashboard info, but don't fail if empty
      try {
        await ref.read(dashboardController.notifier).getDashboardInfo();
      } catch (e) {
        debugPrint('Dashboard error: $e'); 
        // Don't rethrow - continue even if dashboard fails
      }

      if (mounted) {
        context.nav.pushNamedAndRemoveUntil(Routes.core, (route) => false);
      }
    } catch (e) {
      debugPrint('API Error: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        await ref.read(hiveStoreService).removeAllData();
        if (mounted) {
          context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
        }
        return;
      }
      rethrow;
    }
  } catch (e) {
    debugPrint('Initialization Error: $e');
    if (mounted) {
      context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
    }
  }
}

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LogoAnimation(),
      ),
    );
  }
}