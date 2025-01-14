
import 'package:fluffypawsm/core/auth/hive_service.dart';
import 'package:fluffypawsm/data/models/conversation/conversation_model.dart';
import 'package:fluffypawsm/data/repositories/conversation_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConversationController extends StateNotifier<bool> {
  final Ref ref;
  List<ConversationModel>? _conversations;
  List<ConversationModel>? get conversations => _conversations;
  
  ConversationController(this.ref) : super(false);

  Future<void> getAllConversations() async {
    try {
      state = true;
      final response = await ref.read(conversationServiceProvider).getAllConversations();
      
      if (response.data['data'] is List) {
        _conversations = ConversationModel.fromMapList(response.data['data']);
      } else {
        // Handle single conversation response
        _conversations = [ConversationModel.fromMap(response.data['data'])];
      }
      
      if (_conversations != null) {
        await ref.read(hiveStoreService).saveConversations(conversations: _conversations!);
      }
      
      state = false;
    } catch (e) {
      state = false;
      debugPrint('Error getting conversations: ${e.toString()}');
      rethrow;
    }
  }

  Future<ConversationModel?> checkExistingConversation(int personId) async {
    try {
      state = true;
      // Try to find in existing conversations first
      if (_conversations != null) {
        final existing = _conversations!.firstWhere(
          (conv) => conv.poAccountId == personId,
          orElse: () => null as ConversationModel,
        );
        if (existing != null) return existing;
      }

      // If not found, check from API
      final response = await ref.read(conversationServiceProvider).getExistingConversation(personId);
      if (response != null && response.statusCode == 200) {
        return ConversationModel.fromMap(response.data['data']);
      }
      
      state = false;
      return null;
    } catch (e) {
      state = false;
      debugPrint('Error checking existing conversation: ${e.toString()}');
      return null;
    }
  }

  Future<ConversationModel?> createNewConversation(int personId) async {
    try {
      state = true;
      final response = await ref.read(conversationServiceProvider).createConversation(personId);
      
      if (response.statusCode == 200) {
        final newConversation = ConversationModel.fromMap(response.data['data']);
        
        // Add to local list if it exists
        if (_conversations != null) {
          _conversations = [..._conversations!, newConversation];
          // Update cache
          await ref.read(hiveStoreService).saveConversations(conversations: _conversations!);
        }
        
        state = false;
        return newConversation;
      }
      
      state = false;
      return null;
    } catch (e) {
      state = false;
      debugPrint('Error creating new conversation: ${e.toString()}');
      return null;
    }
  }

  Future<ConversationModel?> getOrCreateConversation(int personId) async {
    // First check existing
    final existing = await checkExistingConversation(personId);
    if (existing != null) return existing;

    // If not exists, create new
    return await createNewConversation(personId);
  }
}

final conversationController = StateNotifierProvider<ConversationController, bool>(
  (ref) => ConversationController(ref),
);