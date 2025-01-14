import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ConversationProvider {
  Future<Response> getAllConversations();
  Future<Response> createConversation(int personId);
  Future<Response?> getExistingConversation(int personId);
}

class ConversationServiceProvider implements ConversationProvider {
  final Ref ref;

  ConversationServiceProvider(this.ref);

  @override
  Future<Response> getAllConversations() async {
    final response = await ref.read(apiClientProvider).get(AppConstants.getAllConversation);
    return response;
  }
  @override
  Future<Response> createConversation(int personId) async {
    final response = await ref.read(apiClientProvider).post(
      AppConstants.createConversation,
      data: {'personId': personId},
    );
    return response;
  }
  @override
  Future<Response?> getExistingConversation(int personId) async {
    try {
      final allConversations = await getAllConversations();
      if (allConversations.statusCode == 200) {
        final conversations = allConversations.data['data'] as List;
        final existingConversation = conversations.firstWhere(
          (conv) => conv['personId'] == personId,
          orElse: () => null,
        );
        if (existingConversation != null) {
          return Response(
            requestOptions: RequestOptions(path: ''),
            data: {'data': existingConversation},
            statusCode: 200
          );
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting existing conversation: $e');
      return null;
    }
  }
}

final conversationServiceProvider = 
    Provider((ref) => ConversationServiceProvider(ref));