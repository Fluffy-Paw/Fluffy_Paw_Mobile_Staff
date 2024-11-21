import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/context_less_navigation.dart';
import 'package:fluffypawsm/data/controller/dashboard_controller.dart';
import 'package:fluffypawsm/data/controller/profile_controller.dart';
import 'package:fluffypawsm/presentation/pages/splash_screen/components/logo_animation.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SplashLayout extends ConsumerStatefulWidget {
  const SplashLayout({super.key});

  @override
  ConsumerState<SplashLayout> createState() => _SplashLayoutState();
}

class _SplashLayoutState extends ConsumerState<SplashLayout> {
  @override
  void initState() {
    super.initState();
    _handleAuthentication();
  }

  Future<void> _handleAuthentication() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      
      // Case 1: No token found (never logged in or logged out)
      if (token == null) {
        _navigateToLogin();
        return;
      }

      // Case 2: Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        // Clean up stored data
        await ref.read(hiveStoreService).removeAllData();
        _navigateToLogin();
        return;
      }

      // Case 3: Valid token - proceed with app initialization
      ref.read(apiClientProvider).updateToken(token: token);
      
      // Load user data
      final userDataLoaded = await _loadUserData();
      
      if (!mounted) return;

      if (userDataLoaded) {
        context.nav.pushNamedAndRemoveUntil(Routes.core, (route) => false);
      } else {
        // Handle case where data loading failed
        await ref.read(hiveStoreService).removeAllData();
        _navigateToLogin();
      }

    } catch (e) {
      debugPrint('Authentication error: $e');
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  Future<bool> _loadUserData() async {
    try {
      await ref.read(profileController.notifier).getAccountDetails();
      await ref.read(dashboardController.notifier).getDashboardInfo();
      return true;
    } catch (e) {
      debugPrint('Error loading user data: $e');
      return false;
    }
  }

  void _navigateToLogin() {
    context.nav.pushNamedAndRemoveUntil(Routes.login, (route) => false);
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