import 'dart:convert';
import 'dart:io';
import 'package:fluffypawsm/data/models/conversation/message_model.dart';
import 'package:fluffypawsm/data/repositories/chat_service.dart';
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatController extends StateNotifier<AsyncValue<ChatPagination>> {
  final Ref ref;
  final int conversationId;
  late final ChatService _chatService;
  int? _currentUserId;

  ChatController(this.ref, this.conversationId) : super(const AsyncValue.loading()) {
    _chatService = ref.read(chatServiceProvider(_handleNewMessage));
    _initialize();
  }

  Future<void> _initialize() async {
    final token = await ref.read(hiveStoreService).getAuthToken();
    if (token != null) {
      final parts = token.split('.');
      if (parts.length > 1) {
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final json = jsonDecode(decoded);
        _currentUserId = int.tryParse(json['id']?.toString() ?? '');
      }
    }
    await _chatService.connectToSignalR();
    getMessages(); // Initial load
  }

  void _handleNewMessage(String content, int messageConversationId, int targetId) {
    if (messageConversationId == conversationId) {
      if (state.hasValue) {
        final currentState = state.value!;
        
        final newMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          conversationId: messageConversationId,
          senderId: targetId, // Use target ID as sender
          content: content,
          createTime: DateTime.now(),
          isSeen: false,
          isDelete: false,
          replyMessageId: 0,
          deleteAt: null,
          files: [],
        );

        final updatedMessages = [...currentState.items, newMessage];
        state = AsyncValue.data(ChatPagination(
          items: updatedMessages,
          totalItems: currentState.totalItems + 1,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          pageSize: currentState.pageSize,
          hasPreviousPage: currentState.hasPreviousPage,
          hasNextPage: currentState.hasNextPage,
        ));
      }
    }
  }

  Future<void> getMessages() async {
    try {
      final response = await _chatService.getMessages(conversationId);
      
      debugPrint('API Response: ${response.data}');
      
      if (response.data['statusCode'] == 200 && response.data['data'] != null) {
        final chatPagination = ChatPagination.fromMap(response.data['data']);
        state = AsyncValue.data(chatPagination);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e, stack) {
      debugPrint('Error getting messages: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> sendMessage({
    required String content,
    int? replyMessageId,
    List<File>? files,
  }) async {
    try {
      if (state.hasValue && _currentUserId != null) {
        final currentState = state.value!;
        
        final optimisticMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch,
          conversationId: conversationId,
          senderId: _currentUserId!, // Use current user ID
          content: content,
          createTime: DateTime.now(),
          isSeen: false,
          isDelete: false,  
          replyMessageId: replyMessageId ?? 0,
          deleteAt: null,
          files: [],
        );

        final updatedMessages = [...currentState.items, optimisticMessage];
        state = AsyncValue.data(ChatPagination(
          items: updatedMessages,
          totalItems: currentState.totalItems + 1,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          pageSize: currentState.pageSize,
          hasPreviousPage: currentState.hasPreviousPage,
          hasNextPage: currentState.hasNextPage,
        ));
      }

      final response = await _chatService.sendMessage(
        conversationId: conversationId,
        content: content,
        replyMessageId: replyMessageId,
        files: files,
      );

      if (response.data['statusCode'] != 200 || files?.isNotEmpty == true) {
        await getMessages();
      }

      return response.data['statusCode'] == 200;
    } catch (e) {
      debugPrint('Error sending message: $e');
      await getMessages();
      return false;
    }
  }

  void markMessageAsSeen(Message message) {
    if (state.hasValue && !message.isSeen) {
      final currentState = state.value!;
      final updatedMessages = currentState.items.map((m) {
        if (m.id == message.id) {
          return Message(
            id: m.id,
            conversationId: m.conversationId,
            senderId: m.senderId,
            content: m.content,
            createTime: m.createTime,
            isSeen: true,
            isDelete: m.isDelete,
            replyMessageId: m.replyMessageId,
            deleteAt: m.deleteAt,
            files: m.files,
          );
        }
        return m;
      }).toList();

      state = AsyncValue.data(ChatPagination(
        items: updatedMessages,
        totalItems: currentState.totalItems,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        pageSize: currentState.pageSize,
        hasPreviousPage: currentState.hasPreviousPage,
        hasNextPage: currentState.hasNextPage,
      ));
    }
  }

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, AsyncValue<ChatPagination>, int>(
  (ref, conversationId) => ChatController(ref, conversationId),
);