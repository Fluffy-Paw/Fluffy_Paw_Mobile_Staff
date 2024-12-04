import 'dart:async';

import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/notification/notification_model.dart';
import 'package:fluffypawsm/data/models/notification/notification_state.dart';
import 'package:fluffypawsm/data/repositories/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>((ref) {
  return NotificationController(ref);
});

class NotificationController extends StateNotifier<NotificationState> {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;

  NotificationController(this.ref) : super(NotificationState());

  Future<void> initializeSignalR() async {
    try {
      print('SignalR: Start connection attempt');

      if (_hubConnection?.state == HubConnectionState.connected) {
        print('SignalR: Already connected');
        return;
      }

      if (_isConnecting) {
        print('SignalR: Connection attempt already in progress');
        return;
      }

      _isConnecting = true;
      state = state.copyWith(isLoading: true);

      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) {
        _handleConnectionError('No auth token found');
        return;
      }

      // Create connection with modified options as shown above
      _hubConnection = HubConnectionBuilder()
          .withUrl(
              'https://fluffypaw.azurewebsites.net/NotificationHub',
              HttpConnectionOptions(
                accessTokenFactory: () async => token,
                transport: HttpTransportType.webSockets,
                // Remove skipNegotiation: true to allow proper handshake
                logging: (level, message) => print('SignalR Log: $message'),
                // Add reconnectRetryAttempts and keepAliveInterval
              ))
          .withAutomaticReconnect()
          .build();

      _setupConnectionHandlers();

      // Add retry logic
      int retryAttempt = 0;
      while (retryAttempt < 3) {
        try {
          await _hubConnection?.start();
          print('SignalR: Connected successfully');
          state = state.copyWith(
            isLoading: false,
            connectionStatus: 'Connected',
          );
          return;
        } catch (e) {
          retryAttempt++;
          print('SignalR: Connection attempt $retryAttempt failed: $e');
          if (retryAttempt < 3) {
            await Future.delayed(Duration(seconds: 2 * retryAttempt));
          }
        }
      }

      _handleConnectionError('Failed after 3 attempts');
    } catch (e) {
      _handleConnectionError(e.toString());
    }
  }

  void _handleConnectionError(String message) {
    _isConnecting = false;
    print('SignalR Error: $message');
    state = state.copyWith(
      isLoading: false,
      connectionStatus: 'Error: $message',
    );
  }

  void _setupConnectionHandlers() {
    _hubConnection?.onclose((error) {
      print('SignalR: Connection closed, error: $error');
      state = state.copyWith(connectionStatus: 'Disconnected');
    });

    _hubConnection?.onreconnecting((_) {
      print('SignalR: Attempting to reconnect...');
      state = state.copyWith(connectionStatus: 'Reconnecting');
    });

    _hubConnection?.onreconnected((_) {
      print('SignalR: Reconnected successfully');
      state = state.copyWith(connectionStatus: 'Connected');
    });

    _hubConnection?.on('ReceiveNoti', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        try {
          print('SignalR: Received notification: $arguments');
          String userId = arguments[0].toString();
          String message = arguments[1].toString();

          final newNotification = PetNotification(
            title: "New Notification",
            description: message,
            time: DateTime.now(),
            type: _determineNotificationType(message),
            isRead: false,
          );

          showLocalNotification(newNotification);

          state = state.copyWith(
            notifications: [newNotification, ...state.notifications],
          );
          print('SignalR: Notification processed successfully');
        } catch (e) {
          print('SignalR: Error handling notification: $e');
        }
      }
    });
  }

  NotificationType _determineNotificationType(String message) {
    message = message.toLowerCase();

    if (message.contains('service') || message.contains('maintenance')) {
      return NotificationType.service;
    } else if (message.contains('store') || message.contains('shop')) {
      return NotificationType.store;
    } else if (message.contains('booking') || message.contains('appointment')) {
      return NotificationType.booking;
    } else if (message.contains('vaccine') || message.contains('vaccination')) {
      return NotificationType.vaccine;
    } else if (message.contains('withdraw') || message.contains('payment')) {
      return NotificationType.withdraw;
    } else if (message.contains('check in') || message.contains('checkin')) {
      return NotificationType.checkin;
    } else if (message.contains('check out') || message.contains('checkout')) {
      return NotificationType.checkout;
    } else {
      return NotificationType.message;
    }
  }

  void markAsRead(String id) {
    final updatedNotifications = state.notifications.map((notification) {
      if (notification.title == id) {
        return PetNotification(
          title: notification.title,
          description: notification.description,
          time: notification.time,
          type: notification.type,
          actionData: notification.actionData,
          isRead: true,
        );
      }
      return notification;
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void deleteNotification(String id) {
    final updatedNotifications = state.notifications
        .where((notification) => notification.title != id)
        .toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  void clearAllNotifications() {
    state = state.copyWith(notifications: []);
  }

  void setFilter(NotificationType? type) {
    state = state.copyWith(selectedFilter: type);
  }

  void markAllAsRead() {
    final updatedNotifications = state.notifications.map((notification) {
      return PetNotification(
        title: notification.title,
        description: notification.description,
        time: notification.time,
        type: notification.type,
        actionData: notification.actionData,
        isRead: true,
      );
    }).toList();

    state = state.copyWith(notifications: updatedNotifications);
  }

  int getUnreadCount(NotificationType? type) {
    if (type == null) {
      return state.notifications.where((n) => !n.isRead).length;
    }
    return state.notifications.where((n) => !n.isRead && n.type == type).length;
  }

  int getNotificationCount(NotificationType? type) {
    if (type == null) return state.notifications.length;
    return state.notifications.where((n) => n.type == type).length;
  }

  String getConnectionStatus() {
    return state.connectionStatus;
  }

  @override
  void dispose() {
    cleanupConnection();
    super.dispose();
  }

  Future<void> cleanupConnection() async {
    try {
      if (_hubConnection != null) {
        await _hubConnection?.stop();
        _hubConnection = null;
      }
    } catch (e) {
      print('SignalR: Error during cleanup: $e');
    }
    _isConnecting = false;
  }
}
