// import 'dart:async';
// import 'dart:ui';

// import 'package:fluffypawsm/core/utils/constants.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:signalr_core/signalr_core.dart';

// // Khởi tạo FlutterLocalNotificationsPlugin ở mức global
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
//     FlutterLocalNotificationsPlugin();

// Future<void> initializeBackgroundService() async {
//   // Khởi tạo notifications trước
//   await _initializeNotifications();
  
//   final service = FlutterBackgroundService();

//   await service.configure(
//     iosConfiguration: IosConfiguration(
//       autoStart: true,
//       onForeground: onStart,
//       onBackground: onIosBackground,
//     ),
//     androidConfiguration: AndroidConfiguration(
//       onStart: onStart,
//       autoStart: true,
//       isForegroundMode: true,
//       notificationChannelId: 'fluffypaw_notification',
//       initialNotificationTitle: 'FluffyPaw Service',
//       initialNotificationContent: 'Running in background',
//       foregroundServiceNotificationId: 888,
//     ),
//   );
// }

// Future<void> _initializeNotifications() async {
//   const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  
//   final darwinSettings = DarwinInitializationSettings(
//     requestAlertPermission: true,
//     requestBadgePermission: true,
//     requestSoundPermission: true,
//   );

//   await flutterLocalNotificationsPlugin.initialize(
//     InitializationSettings(
//       android: androidSettings,
//       iOS: darwinSettings,
//     ),
//   );

//   // Request permissions for iOS
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
// }

// @pragma('vm:entry-point')
// Future<bool> onIosBackground(ServiceInstance service) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   DartPluginRegistrant.ensureInitialized();
  
//   // Khởi tạo Hive cho iOS background
//   await Hive.initFlutter();
//   await Hive.openBox(AppConstants.appSettingsBox);
//   await Hive.openBox(AppConstants.userBox);
  
//   return true;
// }

// @pragma('vm:entry-point')
// void onStart(ServiceInstance service) async {
//   DartPluginRegistrant.ensureInitialized();
  
//   // Initialize Hive
//   await Hive.initFlutter();
//   await Hive.openBox(AppConstants.appSettingsBox);
//   await Hive.openBox(AppConstants.userBox);
  
//   HubConnection? _hubConnection;
//   bool isReconnecting = false;

//   if (service is AndroidServiceInstance) {
//     service.setAsForegroundService();
//   }

//   Future<String?> getAuthToken() async {
//     final box = Hive.box(AppConstants.userBox);
//     return box.get('token');
//   }

//   Future<void> showNotification(String title, String message) async {
//     try {
//       await flutterLocalNotificationsPlugin.show(
//         DateTime.now().millisecond,
//         title,
//         message,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'fluffypaw_notification',
//             'FluffyPaw Notifications',
//             channelDescription: 'Receive notifications about your pets',
//             importance: Importance.high,
//             priority: Priority.high,
//             enableVibration: true,
//             enableLights: true,
//           ),
//           iOS: const DarwinNotificationDetails(
//             presentAlert: true,
//             presentBadge: true,
//             presentSound: true,
//           ),
//         ),
//       );
//     } catch (e) {
//       print('Error showing notification: $e');
//     }
//   }

//   Future<void> initializeSignalR() async {
//     if (isReconnecting) return;
//     isReconnecting = true;

//     try {
//       final token = await getAuthToken();
//       if (token == null) {
//         print('No token found in Hive storage');
//         isReconnecting = false;
//         return;
//       }

//       if (_hubConnection != null) {
//         await _hubConnection!.stop();
//         await Future.delayed(const Duration(milliseconds: 500));
//       }

//       _hubConnection = HubConnectionBuilder()
//           .withUrl(
//             'https://fluffypaw.azurewebsites.net/NotificationHub',
//             HttpConnectionOptions(
//               accessTokenFactory: () async => token,
//               transport: HttpTransportType.webSockets,
//               skipNegotiation: true,
//               logging: (level, message) => print('SignalR $level: $message'),
//             ))
//           .withAutomaticReconnect([2000, 5000, 10000, 30000])
//           .build();

//       _hubConnection?.onclose((error) {
//         print('SignalR connection closed: $error');
//         if (!isReconnecting) {
//           Future.delayed(const Duration(seconds: 5), initializeSignalR);
//         }
//       });

//       _hubConnection?.on('ReceiveNoti', (arguments) async {
//         if (arguments != null && arguments.isNotEmpty) {
//           try {
//             String userId = arguments[0].toString();
//             String message = arguments[1].toString();
//             await showNotification('FluffyPaw Notification', message);
//           } catch (e) {
//             print('Error handling background notification: $e');
//           }
//         }
//       });

//       await _hubConnection?.start();
//       print('Background SignalR connected successfully');
      
//       // Gửi notification để xác nhận service đang chạy
//       await showNotification(
//         'FluffyPaw Service', 
//         'Background service is running'
//       );
      
//     } catch (e) {
//       print('Background SignalR connection error: $e');
//       await Future.delayed(const Duration(seconds: 30));
//     } finally {
//       isReconnecting = false;
//     }
//   }

//   // Start SignalR connection
//   await initializeSignalR();

//   // Kiểm tra connection thường xuyên hơn
//   Timer.periodic(const Duration(minutes: 5), (_) async {
//     if (_hubConnection?.state != HubConnectionState.connected) {
//       print('Periodic check: Reconnecting SignalR in background...');
//       await initializeSignalR();
//     }
//   });

//   // Listen for token changes
//   final box = Hive.box(AppConstants.userBox);
//   box.watch(key: 'token').listen((event) async {
//     print('Token changed in Hive, reconnecting SignalR...');
//     await initializeSignalR();
//   });

//   // Handle service stop command
//   service.on('stopService').listen((event) async {
//     print('Stopping background service...');
//     await _hubConnection?.stop();
//     if (service is AndroidServiceInstance) {
//       service.setAsForegroundService(); // Để tắt foreground mode, chỉ cần gọi stopSelf()
//     }
//     service.stopSelf();
//   });
// }