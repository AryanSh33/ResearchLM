import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  String? _currentConversationId;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadConversations(String userId) {
    _firestoreService.getConversations(userId).listen((conversations) {
      _conversations = conversations;
      notifyListeners();
    });
  }

  void selectConversation(String userId, String conversationId) {
    _currentConversationId = conversationId;
    _firestoreService.getMessages(userId, conversationId).listen((messages) {
      _messages = messages;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String userId, String content) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Create new conversation if none exists
      if (_currentConversationId == null) {
        final title = content.length > 50
            ? '${content.substring(0, 50)}...'
            : content;
        _currentConversationId = await _firestoreService.createConversation(
          userId,
          title,
        );
        selectConversation(userId, _currentConversationId!);
      }

      // Add user message
      final userMessage = Message(
        id: _uuid.v4(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
      );

      await _firestoreService.addMessage(
        userId,
        _currentConversationId!,
        userMessage,
      );

      // Generate AI response
      final aiResponse = await ApiService.generateLiteratureSurvey(content);

      final aiMessage = Message(
        id: _uuid.v4(),
        content: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await _firestoreService.addMessage(
        userId,
        _currentConversationId!,
        aiMessage,
      );

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String userId, String conversationId) async {
    await _firestoreService.deleteConversation(userId, conversationId);
    if (_currentConversationId == conversationId) {
      _currentConversationId = null;
      _messages.clear();
      notifyListeners();
    }
  }

  void startNewConversation() {
    _currentConversationId = null;
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}