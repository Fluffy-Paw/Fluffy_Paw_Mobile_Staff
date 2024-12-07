import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:fluffypawsm/data/repositories/signal_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signalr_core/signalr_core.dart';

class ChatService {
  final Ref ref;
  HubConnection? _hubConnection;
  bool _isConnecting = false;
  final void Function(String content, int conversationId, int targetId, List<String> attachments)? onMessageReceived;
  final _processedMessageIds = <String>{};

  ChatService(this.ref, {this.onMessageReceived}) {
    _initialize();
  }
  void _initialize() {
    final signalRService = ref.read(signalRServiceProvider);
    signalRService.addHandler("MessageNoti", _handleMessageNotification);
    signalRService.connect();
  }

  Future<String?> _getAuthToken() async {
    try {
      final token = await ref.read(hiveStoreService).getAuthToken();
      if (token == null) throw Exception('Authentication token not found');
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
    if (_hubConnection?.state == HubConnectionState.connected || _isConnecting) return;

    try {
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
              skipNegotiation: false,
              logging: (level, message) => print('SignalR Chat Log: $message'),
            ))
          .withAutomaticReconnect([0, 2000, 10000, 30000])
          .build();

      _hubConnection?.on("MessageNoti", _handleMessageNotification);
      
      await _hubConnection?.start();
      _isConnecting = false;
      print('SignalR Chat: Connected successfully');
    } catch (e) {
      _isConnecting = false;
      print('SignalR Chat Error: $e');
      await Future.delayed(const Duration(seconds: 5));
      connectToSignalR();
    }
  }

  void _handleMessageNotification(List<dynamic>? arguments) {
    if (arguments == null || arguments.length < 6) return;

    try {
      final senderId = int.parse(arguments[0].toString());
      final content = arguments[2].toString();
      final messageId = '${senderId}_${content}_${DateTime.now().millisecondsSinceEpoch}';

      // Kiểm tra nếu tin nhắn đã được xử lý
      if (_processedMessageIds.contains(messageId)) return;
      _processedMessageIds.add(messageId);

      // Giới hạn số lượng messageId được lưu
      if (_processedMessageIds.length > 100) {
        _processedMessageIds.clear();
      }

      final receiverId = int.parse(arguments[1].toString());
      final attachments = (arguments[3] as List).map((url) => url.toString()).toList();
      final type = arguments[4].toString();
      final conversationId = int.parse(arguments[5].toString());

      if (type == "Message") {
        onMessageReceived?.call(content, conversationId, senderId, attachments);
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  Future<Response> getMessages(int conversationId, {int pageSize = 20}) async {
    return await ref.read(apiClientProvider).get(
      '${AppConstants.getAllConversationMessageByConversationId}/$conversationId',
      query: {'pageSize': pageSize},
    );
  }

  Future<Response> sendMessage({
    required int conversationId,
    required String content,
    int? replyMessageId,
    List<File>? files,
  }) async {
    final headers = await _getAuthHeaders();
    headers['Content-Type'] = 'multipart/form-data';

    final formMap = {
      'ConversationId': conversationId,
      'Content': content,
      if (replyMessageId != null) 'ReplyMessageId': replyMessageId,
      if (files != null && files.isNotEmpty)
        'Files': await Future.wait(
          files.map((file) async {
            final fileName = file.path.split('/').last;
            return await MultipartFile.fromFile(file.path, filename: fileName);
          }),
        ),
    };

    return await ref.read(apiClientProvider).post(
      AppConstants.sendMessage,
      data: FormData.fromMap(formMap),
      headers: headers,
    );
  }

  Future<void> reconnect() async {
    if (_hubConnection?.state != HubConnectionState.connected) {
      await connectToSignalR();
    }
  }

  void disconnect() {
    _hubConnection?.stop();
    _isConnecting = false;
  }
  void dispose() {
    ref.read(signalRServiceProvider).removeHandler("MessageNoti", _handleMessageNotification);
  }
}

final chatServiceProvider = Provider.family<ChatService, void Function(String, int, int, List<String>)>(
  (ref, onMessageReceived) => ChatService(ref, onMessageReceived: onMessageReceived),
);