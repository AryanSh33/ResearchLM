import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create new conversation
  Future<String> createConversation(String userId, String title) async {
    try {
      print('🔥 Creating conversation for user: $userId with title: $title');

      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc();

      final conversation = Conversation(
        id: conversationRef.id,
        title: title,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageCount: 0,
      );

      await conversationRef.set(conversation.toJson());
      print('✅ Conversation created successfully: ${conversationRef.id}');
      return conversationRef.id;
    } catch (e) {
      print('❌ Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get conversations for user
  Stream<List<Conversation>> getConversations(String userId) {
    print('🔥 Setting up conversation stream for user: $userId');

    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      print('🔥 Received ${snapshot.docs.length} conversations from stream');
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          print('🔥 Processing conversation: ${doc.id}');
          return Conversation.fromJson(data);
        } catch (e) {
          print('❌ Error parsing conversation ${doc.id}: $e');
          // Return a default conversation to prevent stream from breaking
          return Conversation(
            id: doc.id,
            title: 'Error Loading Conversation',
            userId: userId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            messageCount: 0,
          );
        }
      }).toList();
    });
  }

  // Enhanced method to add message with optional API response data
  Future<void> addMessage(
      String userId,
      String conversationId,
      Message message, {
        Map<String, dynamic>? apiResponseData,
      }) async {
    try {
      print('🔥 Adding message to conversation: $conversationId');
      print('🔥 Message ID: ${message.id}, IsUser: ${message.isUser}');

      final batch = _db.batch();

      // Prepare message data
      Map<String, dynamic> messageData = message.toJson();

      // Add API response data if provided (typically for AI messages)
      if (apiResponseData != null && !message.isUser) {
        print('🔥 Adding API response data to message');
        messageData['apiResponse'] = apiResponseData;
        messageData['hasApiData'] = true;

        // Extract key metrics for easier querying
        if (apiResponseData.containsKey('results')) {
          final results = apiResponseData['results'];
          if (results is Map<String, dynamic>) {
            messageData['paperCount'] = results.length;
            messageData['extractedPhrase'] = apiResponseData['extracted_phrase'];
            messageData['originalQuery'] = apiResponseData['query'];
            print('🔥 Added ${results.length} papers to message data');
          }
        }
      } else {
        messageData['hasApiData'] = false;
      }

      // Add message
      final messageRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id);

      batch.set(messageRef, messageData);
      print('🔥 Message ref set in batch: ${messageRef.path}');

      // Update conversation timestamp and message count
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId);

      batch.update(conversationRef, {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'messageCount': FieldValue.increment(1),
      });
      print('🔥 Conversation update added to batch');

      await batch.commit();
      print('✅ Message batch committed successfully');
    } catch (e) {
      print('❌ Error adding message: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      throw Exception('Failed to add message: $e');
    }
  }

  // Method specifically for storing research queries and their results
  Future<void> storeResearchQuery(
      String userId,
      String conversationId,
      String query,
      Map<String, dynamic> apiResponse,
      String messageId,
      ) async {
    try {
      print('🔥 Storing research query data');

      final researchRef = _db
          .collection('users')
          .doc(userId)
          .collection('research_queries')
          .doc(messageId);

      final researchData = {
        'messageId': messageId,
        'conversationId': conversationId,
        'query': query,
        'extractedPhrase': apiResponse['extracted_phrase'],
        'results': apiResponse['results'],
        'paperCount': (apiResponse['results'] as Map<String, dynamic>?)?.length ?? 0,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'userId': userId,
      };

      await researchRef.set(researchData);
      print('✅ Research query data stored successfully');
    } catch (e) {
      print('❌ Error storing research query: $e');
      // Non-critical error, don't throw
    }
  }

  // Get messages for conversation
  Stream<List<Message>> getMessages(String userId, String conversationId) {
    print('🔥 Setting up messages stream for conversation: $conversationId');

    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      print('🔥 Received ${snapshot.docs.length} messages from stream');

      final messages = <Message>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          print('🔥 Processing message: ${doc.id}');
          final message = Message.fromJson(data);
          messages.add(message);
        } catch (e) {
          print('❌ Error parsing message ${doc.id}: $e');
          // Skip this message but continue with others
          continue;
        }
      }
      return messages;
    });
  }

  // Get enhanced messages with API data
  Stream<List<Map<String, dynamic>>> getEnhancedMessages(String userId, String conversationId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  // Get specific message with API data
  Future<Map<String, dynamic>?> getMessageWithApiData(
      String userId,
      String conversationId,
      String messageId
      ) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Error getting message with API data: $e');
      return null;
    }
  }

  // Get research history for user
  Stream<List<Map<String, dynamic>>> getResearchHistory(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('research_queries')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  // Search through user's research queries
  Future<List<Map<String, dynamic>>> searchResearchQueries(
      String userId,
      String searchTerm
      ) async {
    try {
      // Basic search implementation
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('research_queries')
          .where('query', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where('query', isLessThanOrEqualTo: searchTerm.toLowerCase() + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('❌ Error searching research queries: $e');
      return [];
    }
  }

  // Get user's research statistics
  Future<Map<String, dynamic>> getUserResearchStats(String userId) async {
    try {
      final researchSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('research_queries')
          .get();

      final conversationsSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .get();

      int totalPapers = 0;
      final List<String> topics = [];

      for (var doc in researchSnapshot.docs) {
        final data = doc.data();
        totalPapers += (data['paperCount'] as int?) ?? 0;
        if (data['extractedPhrase'] != null) {
          topics.add(data['extractedPhrase'].toString());
        }
      }

      return {
        'totalQueries': researchSnapshot.docs.length,
        'totalConversations': conversationsSnapshot.docs.length,
        'totalPapersFound': totalPapers,
        'uniqueTopics': topics.toSet().length,
        'recentTopics': topics.take(10).toList(),
      };
    } catch (e) {
      print('❌ Error getting user research stats: $e');
      return {};
    }
  }

  // Delete conversation and all its messages
  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      print('🔥 Deleting conversation: $conversationId');

      final batch = _db.batch();

      // Delete all messages first
      final messagesSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      print('🔥 Found ${messagesSnapshot.docs.length} messages to delete');
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete related research queries
      final researchSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('research_queries')
          .where('conversationId', isEqualTo: conversationId)
          .get();

      print('🔥 Found ${researchSnapshot.docs.length} research queries to delete');
      for (var doc in researchSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId);

      batch.delete(conversationRef);

      await batch.commit();
      print('✅ Conversation deleted successfully');
    } catch (e) {
      print('❌ Error deleting conversation: $e');
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Backup user's research data
  Future<Map<String, dynamic>> backupUserData(String userId) async {
    try {
      final conversations = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .get();

      final researchQueries = await _db
          .collection('users')
          .doc(userId)
          .collection('research_queries')
          .get();

      return {
        'userId': userId,
        'exportDate': DateTime.now().toIso8601String(),
        'conversations': conversations.docs.map((doc) => doc.data()).toList(),
        'researchQueries': researchQueries.docs.map((doc) => doc.data()).toList(),
      };
    } catch (e) {
      print('Error backing up user data: $e');
      throw Exception('Failed to backup user data: $e');
    }
  }

  // Test connection
  Future<bool> testConnection() async {
    try {
      await _db.collection('test').limit(1).get();
      return true;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }

  // ============ GEMINI CONVERSATION METHODS ============

  // Create Gemini conversation linked to a research conversation
  Future<String> createGeminiConversation(String userId, String baseConversationId, String title) async {
    try {
      print('🤖 Creating Gemini conversation for user: $userId, base: $baseConversationId');

      final geminiConversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('gemini_conversations')
          .doc();

      final geminiConversation = {
        'id': geminiConversationRef.id,
        'title': title,
        'userId': userId,
        'baseConversationId': baseConversationId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'messageCount': 0,
        'type': 'gemini_chat',
      };

      await geminiConversationRef.set(geminiConversation);
      print('✅ Gemini conversation created successfully: ${geminiConversationRef.id}');
      return geminiConversationRef.id;
    } catch (e) {
      print('❌ Error creating Gemini conversation: $e');
      throw Exception('Failed to create Gemini conversation: $e');
    }
  }

  // Add message to Gemini conversation
  Future<void> addGeminiMessage(String userId, String geminiConversationId, Message message) async {
    try {
      print('🤖 Adding Gemini message to conversation: $geminiConversationId');

      final batch = _db.batch();

      // Add message
      final messageRef = _db
          .collection('users')
          .doc(userId)
          .collection('gemini_conversations')
          .doc(geminiConversationId)
          .collection('messages')
          .doc(message.id);

      batch.set(messageRef, message.toJson());

      // Update conversation timestamp and message count
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('gemini_conversations')
          .doc(geminiConversationId);

      batch.update(conversationRef, {
        'updatedAt': Timestamp.fromDate(DateTime.now()),
        'messageCount': FieldValue.increment(1),
      });

      await batch.commit();
      print('✅ Gemini message saved successfully');
    } catch (e) {
      print('❌ Error adding Gemini message: $e');
      throw Exception('Failed to add Gemini message: $e');
    }
  }

  // Get Gemini messages for a conversation
  Stream<List<Message>> getGeminiMessages(String userId, String geminiConversationId) {
    print('🤖 Setting up Gemini messages stream for conversation: $geminiConversationId');

    return _db
        .collection('users')
        .doc(userId)
        .collection('gemini_conversations')
        .doc(geminiConversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      print('🤖 Received ${snapshot.docs.length} Gemini messages from stream');

      final messages = <Message>[];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          final message = Message.fromJson(data);
          messages.add(message);
        } catch (e) {
          print('❌ Error parsing Gemini message ${doc.id}: $e');
          continue;
        }
      }
      return messages;
    });
  }

  // Get all Gemini conversations for a base conversation
  Stream<List<Map<String, dynamic>>> getGeminiConversations(String userId, String baseConversationId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('gemini_conversations')
        .where('baseConversationId', isEqualTo: baseConversationId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => doc.data())
        .toList());
  }

  // Delete Gemini conversation and all its messages
  Future<void> deleteGeminiConversation(String userId, String geminiConversationId) async {
    try {
      print('🤖 Deleting Gemini conversation: $geminiConversationId');

      final batch = _db.batch();

      // Delete all messages first
      final messagesSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('gemini_conversations')
          .doc(geminiConversationId)
          .collection('messages')
          .get();

      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete conversation
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('gemini_conversations')
          .doc(geminiConversationId);

      batch.delete(conversationRef);

      await batch.commit();
      print('✅ Gemini conversation deleted successfully');
    } catch (e) {
      print('❌ Error deleting Gemini conversation: $e');
      throw Exception('Failed to delete Gemini conversation: $e');
    }
  }
}