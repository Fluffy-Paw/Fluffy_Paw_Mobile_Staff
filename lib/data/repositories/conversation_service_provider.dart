import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluffypawsm/core/utils/api_client.dart';
import 'package:fluffypawsm/core/utils/constants.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ConversationProvider {
  Future<Response> getAllConversations();
}

class ConversationServiceProvider implements ConversationProvider {
  final Ref ref;

  ConversationServiceProvider(this.ref);

  @override
  Future<Response> getAllConversations() async {
    final response = await ref
        .read(apiClientProvider)
        .get(AppConstants.getAllConversation);
    return response;
  }
  
}

final conversationServiceProvider = 
    Provider((ref) => ConversationServiceProvider(ref));