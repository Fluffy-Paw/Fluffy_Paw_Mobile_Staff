import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatService {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;
  final void Function(String content, int conversationId, int targetId)? onMessageReceived;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  ChatService(this.ref, {this.onMessageReceived});

  Future<String?> _getAuthToken() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      return token;
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    if (token == null) throw Exception('No authentication token available');
    
    return {
      'Authorization': 'Bearer $token',
      'accept': '*/*',
    };
  }

  Future<void> connectToSignalR() async {
    try {
      if (_hubConnection?.state == HubConnectionState.connected || _isConnecting) {
        return;
      }

      _isConnecting = true;
      final token = await _getAuthToken();
      
      if (token == null) {
        _isConnecting = false;
        return;
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(
              'https://fluffypaw.azurewebsites.net/NotificationHub',
              HttpConnectionOptions(
                accessTokenFactory: () async => token,
                transport: HttpTransportType.webSockets,
                skipNegotiation: true,
                logging: (level, message) => print('SignalR Chat Log: $message'),
              ))
          .withAutomaticReconnect([0, 2000, 5000, 10000, 20000]) // Progressive retry delays
          .build();

      _setupMessageHandlers();
      _setupConnectionHandlers();

      await _hubConnection?.start();
      _isConnecting = false;
      _reconnectAttempts = 0; // Reset attempts on successful connection
      print('SignalR Chat: Connected successfully');
    } catch (e) {
      _isConnecting = false;
      print('SignalR Chat Error: $e');
      await _handleConnectionError();
    }
  }

  Future<void> _handleConnectionError() async {
    _reconnectAttempts++;
    if (_reconnectAttempts < maxReconnectAttempts) {
      final delay = Duration(seconds: pow(2, _reconnectAttempts).toInt()); // Exponential backoff
      print('SignalR Chat: Attempting reconnect in ${delay.inSeconds} seconds...');
      await Future.delayed(delay);
      await connectToSignalR();
    } else {
      print('SignalR Chat: Max reconnection attempts reached');
    }
  }

  void _setupConnectionHandlers() {
    _hubConnection?.onreconnecting((error) {
      print('SignalR Chat: Attempting to reconnect... Error: $error');
    });

    _hubConnection?.onreconnected((connectionId) {
      print('SignalR Chat: Reconnected successfully. ConnectionId: $connectionId');
      _reconnectAttempts = 0;
    });

    _hubConnection?.onclose((error) async {
      print('SignalR Chat: Connection closed. Error: $error');
      if (!_isConnecting && _reconnectAttempts < maxReconnectAttempts) {
        await _handleConnectionError();
      }
    });
  }

  void _setupMessageHandlers() {
    // Log tất cả các message nhận được để debug
    _hubConnection?.on("", (messages) {
      print("Raw SignalR message received: $messages");
    });

    // Thử đăng ký cả ReceiveMessage và MessageNoti
    _hubConnection?.on("MessageNoti", (arguments) {
      print('Received ReceiveMessage: $arguments');
      _handleMessageNotification(arguments);
    });

    _hubConnection?.on("ReceiveNoti", (arguments) {
      print('Received ReceiveNoti: $arguments');
      _handleMessageNotification(arguments);
    });
  }

  void _handleMessageNotification(List<dynamic>? arguments) {
    if (arguments != null && arguments.length >= 5) {
      try {
        final senderId = int.parse(arguments[0].toString());
        final receiverId = int.parse(arguments[1].toString());
        final notification = arguments[2].toString();
        final type = arguments[3].toString();
        final referenceId = int.tryParse(arguments[4].toString()) ?? 0;
        
        print('Parsed notification: senderId=$senderId, receiverId=$receiverId, message=$notification, type=$type, referenceId=$referenceId');
        
        if (type == "Message") {
          onMessageReceived?.call(notification, referenceId, senderId);
        }
      } catch (e) {
        print('Error handling notification: $e');
      }
    } else {
      print('Invalid notification format: $arguments');
    }
  }

  Future<Response> getMessages(int conversationId, {int pageSize = 20}) async {
    try {
      final response = await ref.read(apiClientProvider).get(
        '${AppConstants.getAllConversationMessageByConversationId}/$conversationId',
        query: {'pageSize': pageSize},
      );
      return response;
    } catch (e) {
      print('Error getting messages: $e');
      rethrow;
    }
  }

  Future<Response> sendMessage({
    required int conversationId,
    required String content,
    int? replyMessageId,
    List<File>? files,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      headers['Content-Type'] = 'multipart/form-data';

      Map<String, dynamic> formMap = {
        'ConversationId': conversationId,
        'Content': content,
      };
      
      if (replyMessageId != null) {
        formMap['ReplyMessageId'] = replyMessageId;
      }

      if (files != null && files.isNotEmpty) {
        List<MultipartFile> fileList = [];
        for (var file in files) {
          String fileName = file.path.split('/').last;
          fileList.add(await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ));
        }
        formMap['Files'] = fileList;
      }

      final formData = FormData.fromMap(formMap);

      return await ref.read(apiClientProvider).post(
        AppConstants.sendMessage,
        data: formData,
        headers: headers,
      );
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> reconnect() async {
    if (_hubConnection?.state != HubConnectionState.connected && !_isConnecting) {
      _reconnectAttempts = 0; // Reset attempts for manual reconnect
      await connectToSignalR();
    }
  }

  void disconnect() {
    _hubConnection?.stop();
    _isConnecting = false;
    _reconnectAttempts = 0;
  }
}

final chatServiceProvider = Provider.family<ChatService, void Function(String, int, int)>(
  (ref, onMessageReceived) => ChatService(ref, onMessageReceived: onMessageReceived),
);