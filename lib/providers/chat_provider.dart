import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/message.dart';
import '../models/conversation.dart';
import '../models/paper.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();
  final Uuid _uuid = const Uuid();

  List<Conversation> _conversations = [];
  List<Message> _messages = [];
  String? _currentConversationId;
  bool _isLoading = false;
  String? _error;
  bool _isOnline = true;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Message> get messages => _messages;
  String? get currentConversationId => _currentConversationId;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOnline => _isOnline;

  void loadConversations(String userId) {
    print('📂 Loading conversations for user: $userId');
    try {
      _firestoreService.getConversations(userId).listen(
            (conversations) {
          print('📂 Loaded ${conversations.length} conversations');
          _conversations = conversations;
          _isOnline = true;
          notifyListeners();
        },
        onError: (error) {
          print('❌ Error loading conversations: $error');
          _isOnline = false;
          _error = 'Failed to connect to database. Working in offline mode.';
          notifyListeners();
        },
      );
    } catch (e) {
      print('❌ Exception loading conversations: $e');
      _isOnline = false;
      _error = 'Database connection failed. Working in offline mode.';
      notifyListeners();
    }
  }

  void selectConversation(String userId, String conversationId) {
    print('💬 Selecting conversation: $conversationId');
    _currentConversationId = conversationId;

    if (!_isOnline) {
      print('⚠️ Offline mode - cannot load conversation messages');
      return;
    }

    try {
      _firestoreService.getMessages(userId, conversationId).listen(
            (messages) {
          print('💬 Loaded ${messages.length} messages for conversation');
          _messages = messages;
          notifyListeners();
        },
        onError: (error) {
          print('❌ Error loading messages: $error');
          _error = 'Failed to load conversation messages.';
          notifyListeners();
        },
      );
    } catch (e) {
      print('❌ Exception loading messages: $e');
      _error = 'Failed to load conversation messages.';
      notifyListeners();
    }
  }

  // Key changes in the sendMessage method for better API integration

  // Fixed sendMessage method in ChatProvider class
  Future<void> sendMessage(String userId, String content) async {
    print('🚀 Starting sendMessage process...');
    print('👤 User ID: $userId');
    print('💬 Content: $content');
    print('🆔 Current conversation ID: $_currentConversationId');

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate input first
      if (!_apiService.isValidQuery(content)) {
        throw ArgumentError('Please enter a valid research topic (at least 3 characters).');
      }

      // Create or get conversation (offline mode creates temporary ID)
      if (_currentConversationId == null) {
        print('📝 Creating new conversation...');
        final title = content.length > 50 ? '${content.substring(0, 50)}...' : content;

        if (_isOnline) {
          try {
            _currentConversationId = await _firestoreService.createConversation(userId, title);
            print('✅ New conversation created: $_currentConversationId');
          } catch (e) {
            print('⚠️ Failed to create conversation online, using offline mode');
            _currentConversationId = 'offline_${_uuid.v4()}';
            _isOnline = false;
          }
        } else {
          _currentConversationId = 'offline_${_uuid.v4()}';
          print('📝 Created offline conversation: $_currentConversationId');
        }
      }

      // Create and add user message immediately
      final userMessage = Message(
        id: _uuid.v4(),
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
      );

      print('👤 Adding user message to UI...');
      _messages.add(userMessage);
      notifyListeners(); // Update UI immediately with user message

      // Save user message to Firestore (if online)
      if (_isOnline && !_currentConversationId!.startsWith('offline_')) {
        try {
          await _firestoreService.addMessage(userId, _currentConversationId!, userMessage);
          print('✅ User message saved to Firestore');
        } catch (e) {
          print('⚠️ Failed to save user message to Firestore: $e');
          _isOnline = false;
        }
      }

      // Test API connection first
      print('🔌 Testing API connection...');
      bool apiReachable = await _apiService.testConnection();
      if (!apiReachable) {
        throw Exception('API server is not reachable. Please check your internet connection and try again.');
      }
      print('✅ API is reachable');

      // Call API for AI response with better error handling
      print('📡 Calling API with query: "$content"');
      Map<String, dynamic> apiResponse; // Changed from String to Map<String, dynamic>
      try {
        // Remove the cast to String - the method already returns Map<String, dynamic>
        apiResponse = await _apiService.generateLiteratureSurvey(content);
        print('✅ API response received');
        print('📋 Response keys: ${apiResponse.keys.toList()}');
      } catch (e) {
        print('❌ API call failed: $e');
        // Re-throw with more context
        if (e is HttpException) {
          throw Exception('Literature survey generation failed: ${e.message}');
        } else {
          throw Exception('Failed to generate literature survey: $e');
        }
      }

      // Use apiResponse directly instead of trying to decode it again
      final data = apiResponse; // No need to jsonDecode since it's already a Map
      print('📋 Data keys: ${data.keys.toList()}');

      String aiResponseContent;

      // Handle different response formats
      if (data.containsKey('results') && data['results'] != null) {
        final results = data['results'];

        if (results is Map<String, dynamic> && results.isNotEmpty) {
          print('📚 Found ${results.length} papers in results');

          final papers = <Paper>[];
          for (final entry in results.entries) {
            print('📄 Processing paper: ${entry.key}');
            try {
              if (entry.value is Map<String, dynamic>) {
                final paperData = entry.value as Map<String, dynamic>;
                final paper = Paper.fromApiResponse(entry.key, paperData);
                papers.add(paper);
                print('✅ Added paper: ${paper.title}');
              } else {
                print('⚠️ Skipping invalid paper data for ${entry.key}');
              }
            } catch (e) {
              print('⚠️ Error processing paper ${entry.key}: $e');
              // Continue processing other papers
            }
          }

          if (papers.isNotEmpty) {
            final extractedPhrase = data['extracted_phrase']?.toString() ??
                data['query']?.toString() ??
                content;
            aiResponseContent = _formatPapersToMarkdown(papers, extractedPhrase);
            print('✅ Formatted ${papers.length} papers to markdown');
          } else {
            aiResponseContent = 'No valid papers found for the query: "$content"\n\nPlease try refining your search with more specific terms.';
            print('⚠️ No valid papers found in results');
          }
        } else {
          aiResponseContent = 'No papers found for the query: "$content"\n\nPlease try a different search term or check your internet connection.';
          print('⚠️ Results field is empty or invalid');
        }
      } else if (data.containsKey('message') || data.containsKey('error')) {
        // Handle error responses from API
        final errorMessage = data['message']?.toString() ??
            data['error']?.toString() ??
            'Unknown error occurred';
        throw Exception('API Error: $errorMessage');
      } else {
        print('❌ Unexpected API response structure: ${data.keys}');
        aiResponseContent = 'Received an unexpected response format from the server. Please try again.';
      }

      // Create and add AI message
      final aiMessage = Message(
        id: _uuid.v4(),
        content: aiResponseContent,
        isUser: false,
        timestamp: DateTime.now(),
      );

      print('🤖 Adding AI response to UI...');
      _messages.add(aiMessage);
      notifyListeners(); // Update UI with AI response

      // Save AI message to Firestore (if online)
      if (_isOnline && !_currentConversationId!.startsWith('offline_')) {
        try {
          await _firestoreService.addMessage(userId, _currentConversationId!, aiMessage);
          print('✅ AI message saved to Firestore');
        } catch (e) {
          print('⚠️ Failed to save AI message to Firestore: $e');
          // Message is already in UI, so this is not critical
        }
      }

    } catch (e) {
      print('❌ Error in sendMessage: $e');

      // Create more user-friendly error messages
      String errorMessage;
      if (e is ArgumentError) {
        errorMessage = e.message;
      } else if (e is HttpException) {
        errorMessage = 'Network Error: ${e.message}';
      } else if (e.toString().contains('422')) {
        errorMessage = 'Invalid request format. Please check your input and try again.';
      } else if (e.toString().contains('405')) {
        errorMessage = 'API method not supported. The server may be misconfigured.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please check your internet connection and try again.';
      } else {
        errorMessage = 'An error occurred while processing your request: ${e.toString()}';
      }

      _error = errorMessage;

      // Create error message and add to UI
      final errorMessage_ui = Message(
        id: _uuid.v4(),
        content: '❌ **Error**: $errorMessage\n\nPlease try again or contact support if the problem persists.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage_ui);
      notifyListeners(); // Update UI with error message

      // Try to save error message to Firestore (if online)
      if (_isOnline && _currentConversationId != null && !_currentConversationId!.startsWith('offline_')) {
        try {
          await _firestoreService.addMessage(userId, _currentConversationId!, errorMessage_ui);
        } catch (firestoreError) {
          print('⚠️ Failed to save error message to Firestore: $firestoreError');
        }
      }

    } finally {
      _isLoading = false;
      notifyListeners();
      print('✅ sendMessage process completed');
    }
  }

// Enhanced paper formatting with better error handling
  String _formatPapersToMarkdown(List<Paper> papers, [String? extractedPhrase]) {
    if (papers.isEmpty) return 'No papers found.';

    final buffer = StringBuffer();

    try {
      if (extractedPhrase != null && extractedPhrase.isNotEmpty) {
        buffer.writeln('# Literature Survey: $extractedPhrase\n');
      }

      buffer.writeln('Found ${papers.length} relevant papers:\n');

      for (int i = 0; i < papers.length; i++) {
        final paper = papers[i];

        // Ensure title is not empty
        final title = paper.title.isNotEmpty ? paper.title : 'Untitled Paper';
        buffer.writeln('## ${i + 1}. $title');

        if (paper.authors.isNotEmpty && paper.authors != 'Unknown Authors') {
          buffer.writeln('**Authors:** ${paper.authors}');
        }

        if (paper.year != null) {
          buffer.writeln('**Year:** ${paper.year}');
        }

        if (paper.citations != null && paper.citations! > 0) {
          buffer.writeln('**Citations:** ${paper.citations}');
        }

        if (paper.abstractText.isNotEmpty) {
          buffer.writeln('\n**Analysis:**');
          buffer.writeln(paper.abstractText);
        }

        if (paper.link.isNotEmpty && paper.link.startsWith('http')) {
          buffer.writeln('\n[📄 Read Full Paper](${paper.link})');
        }

        buffer.writeln('\n---\n');
      }

      return buffer.toString();
    } catch (e) {
      print('❌ Error formatting papers to markdown: $e');
      return 'Error formatting research papers. Please try again.';
    }
  }

  Future<void> retryLastMessage(String userId) async {
    if (_messages.isEmpty) {
      print('⚠️ No messages to retry');
      return;
    }

    try {
      print('🔄 Retrying last message...');
      _error = null;
      notifyListeners();

      // Find the last user message
      Message? lastUserMessage;
      try {
        lastUserMessage = _messages.lastWhere((msg) => msg.isUser);
      } catch (e) {
        print('⚠️ No user message found to retry');
        _error = 'No user message found to retry';
        notifyListeners();
        return;
      }

      if (lastUserMessage != null) {
        print('🔄 Found last user message: ${lastUserMessage.content}');

        // Remove AI responses after the last user message
        final messagesToKeep = <Message>[];
        bool foundLastUserMessage = false;

        for (final message in _messages) {
          if (message.id == lastUserMessage.id) {
            foundLastUserMessage = true;
            messagesToKeep.add(message);
          } else if (!foundLastUserMessage) {
            messagesToKeep.add(message);
          }
          // Skip AI messages after the last user message
        }

        _messages = messagesToKeep;
        notifyListeners();

        // Retry the API call
        await sendMessage(userId, lastUserMessage.content);
      }
    } catch (e) {
      print('❌ Failed to retry: $e');
      _error = 'Failed to retry: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      print('🗑️ Deleting conversation: $conversationId');

      if (_isOnline && !conversationId.startsWith('offline_')) {
        await _firestoreService.deleteConversation(userId, conversationId);
      }

      // Remove from local list
      _conversations.removeWhere((conv) => conv.id == conversationId);

      if (_currentConversationId == conversationId) {
        _currentConversationId = null;
        _messages.clear();
      }

      notifyListeners();
      print('✅ Conversation deleted successfully');
    } catch (e) {
      print('❌ Failed to delete conversation: $e');
      _error = 'Failed to delete conversation: $e';
      notifyListeners();
    }
  }

  void startNewConversation() {
    print('🆕 Starting new conversation');
    _currentConversationId = null;
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    print('🧹 Clearing error');
    _error = null;
    notifyListeners();
  }

  // Check connectivity status
  Future<void> checkConnectivity() async {
    try {
      final isConnected = await _firestoreService.testConnection();
      _isOnline = isConnected;
      if (!isConnected) {
        _error = 'Working in offline mode - database unavailable';
      } else if (_error?.contains('offline mode') == true) {
        _error = null; // Clear offline error when back online
      }
      notifyListeners();
    } catch (e) {
      _isOnline = false;
      notifyListeners();
    }
  }

  // Debug method to check current state
  void debugState() {
    print('=== ChatProvider Debug State ===');
    print('Current Conversation ID: $_currentConversationId');
    print('Messages Count: ${_messages.length}');
    print('Is Loading: $_isLoading');
    print('Is Online: $_isOnline');
    print('Error: $_error');
    print('Conversations Count: ${_conversations.length}');
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      print('Message $i: ${msg.isUser ? "USER" : "AI"} - ${msg.content.substring(0, msg.content.length > 50 ? 50 : msg.content.length)}...');
    }
    print('================================');
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}