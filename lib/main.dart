import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/core/utils/global_function.dart';
import 'package:fluffypawsm/core/utils/theme.dart';
import 'package:fluffypawsm/data/controller/notification_controller.dart';
import 'package:fluffypawsm/data/repositories/background_service.dart';
import 'package:fluffypawsm/data/repositories/notification_service.dart';
import 'package:fluffypawsm/presentation/pages/profile/components/language.dart';
import 'package:fluffypawsm/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/localization/l10n.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/generated/l10n.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.appSettingsBox);
  await Hive.openBox(AppConstants.userBox);
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  //await initializeBackgroundService();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform, // Initialize with options
  // );
  // final authService = AuthService();
  // bool isExpired = await authService.isTokenExpired();
  // Widget defaultHome = isExpired ? SplashScreen() : Home();

  runApp(const ProviderScope(child: MyApp())
      // DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => const ProviderScope(
      //     child: MyApp(),
      //   ),
      // ),
      );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  Locale resolveLocal({required String langCode}) {
    return Locale(langCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(appLifecycleProvider);
    return ScreenUtilInit(
      designSize: const Size(390, 844), // XD Design Sizes
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: false,
      builder: (context, child) {
        return ValueListenableBuilder(
            valueListenable: Hive.box(AppConstants.appSettingsBox).listenable(),
            builder: (context, appSettingsBox, _) {
              final selectedLocal = appSettingsBox.get(AppConstants.appLocal);
              final bool? isDark =
                  appSettingsBox.get(AppConstants.isDarkTheme) ?? false;
              if (isDark == null) {
                appSettingsBox.put(AppConstants.isDarkTheme, false);
              }

              if (selectedLocal == null) {
                appSettingsBox.put(
                  AppConstants.appLocal,
                  AppLanguage(name: '\ud83c\uddfa\ud83c\uddf8 ENG', value: 'en')
                      .toMap(),
                );
              }

              GlobalFunction.changeStatusBarTheme(isDark: isDark);
              return MaterialApp(
                  title: 'FluffyPawSeller',
                  navigatorKey: GlobalFunction.navigatorKey,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    FormBuilderLocalizations.delegate,
                  ],
                  locale: resolveLocal(
                      langCode: selectedLocal == null
                          ? 'en'
                          : selectedLocal['value']),
                  localeResolutionCallback: (deviceLocal, supportedLocales) {
                    for (final locale in supportedLocales) {
                      if (locale.languageCode == deviceLocal!.languageCode) {
                        return deviceLocal;
                      }
                    }
                    return supportedLocales.first;
                  },
                  supportedLocales: S.delegate.supportedLocales,
                  theme: getAppTheme(
                      context: context, isDarkTheme: isDark ?? false),
                  onGenerateRoute: generatedRoutes,
                  initialRoute: Routes.splash);
            });
      },
    );
  }
}

final appLifecycleProvider = Provider<AppLifecycleNotifier>((ref) {
  return AppLifecycleNotifier(ref);
});

class AppLifecycleNotifier extends WidgetsBindingObserver {
  final Ref ref;
  bool _initialized = false;

  AppLifecycleNotifier(this.ref) {
    print('AppLifecycleNotifier: Initializing...');
    WidgetsBinding.instance.addObserver(this);
    _initSignalR();
  }

  Future<void> _initSignalR() async {
    if (_initialized) {
      print('AppLifecycleNotifier: Already initialized');
      return;
    }

    print('AppLifecycleNotifier: Getting token...');
    final token = await ref.read(hiveStoreService).getAuthToken();
    if (token != null) {
      print('AppLifecycleNotifier: Token found, initializing SignalR...');
      await ref.read(notificationControllerProvider.notifier).initializeSignalR();
      _initialized = true;
    } else {
      print('AppLifecycleNotifier: No token found');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('AppLifecycleNotifier: State changed to $state');
    switch (state) {
      case AppLifecycleState.resumed:
        // Khi app được resume, kiểm tra và khôi phục kết nối nếu cần
        Future.delayed(const Duration(seconds: 1), () {
          ref.read(notificationControllerProvider.notifier).initializeSignalR();
        });
        break;
      case AppLifecycleState.paused:
        // Khi app tạm dừng, vẫn giữ kết nối
        break;
      case AppLifecycleState.detached:
        // Chỉ đóng kết nối khi app bị tắt hoàn toàn
        _initialized = false;
        ref.read(notificationControllerProvider.notifier).dispose();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    print('AppLifecycleNotifier: Disposing...');
    WidgetsBinding.instance.removeObserver(this);
  }
}
