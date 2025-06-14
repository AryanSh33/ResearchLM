import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create new conversation
  Future<String> createConversation(String userId, String title) async {
    try {
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc();

      final conversation = {
        'id': conversationRef.id,
        'title': title,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': 0,
      };

      await conversationRef.set(conversation);
      return conversationRef.id;
    } catch (e) {
      print('Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get conversations for user
  Stream<List<Conversation>> getConversations(String userId) {
    try {
      return _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          // Handle potential null timestamps from Firestore
          return Conversation(
            id: data['id'] ?? doc.id,
            title: data['title'] ?? 'Untitled',
            userId: data['userId'] ?? userId,
            createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            messageCount: data['messageCount'] ?? 0,
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting conversations: $e');
      return Stream.value([]);
    }
  }

  // Add message to conversation
  Future<void> addMessage(
      String userId, String conversationId, Message message) async {
    try {
      final batch = _db.batch();

      // Add message
      final messageRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(message.id);

      batch.set(messageRef, {
        'id': message.id,
        'content': message.content,
        'isUser': message.isUser,
        'timestamp': FieldValue.serverTimestamp(),
        'status': message.status ?? 'sent',
        'userId': userId,
      });

      // Update conversation timestamp and message count
      final conversationRef = _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId);

      batch.update(conversationRef, {
        'updatedAt': FieldValue.serverTimestamp(),
        'messageCount': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (e) {
      print('Error adding message: $e');
      throw Exception('Failed to add message: $e');
    }
  }

  // Get messages for conversation
  Stream<List<Message>> getMessages(String userId, String conversationId) {
    try {
      return _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Message(
            id: data['id'] ?? doc.id,
            content: data['content'] ?? '',
            isUser: data['isUser'] ?? false,
            timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            status: data['status'] ?? 'sent',
          );
        }).toList();
      });
    } catch (e) {
      print('Error getting messages: $e');
      return Stream.value([]);
    }
  }

  // Delete conversation and all its messages
  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      final batch = _db.batch();

      // Get all messages first
      final messagesSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

      // Delete all messages
      for (var doc in messagesSnapshot.docs) {
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
    } catch (e) {
      print('Error deleting conversation: $e');
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Helper method to check if user document exists
  Future<bool> userExists(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  // Helper method to create sample conversation for testing
  Future<void> createSampleConversation(String userId) async {
    try {
      final conversationId = await createConversation(
          userId,
          'Sample Literature Survey Discussion'
      );

      // Add sample messages
      final sampleMessages = [
        Message(
          id: 'msg1',
          content: 'Can you help me with a literature survey on machine learning in healthcare?',
          isUser: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
          status: 'sent',
        ),
        Message(
          id: 'msg2',
          content: 'I\'d be happy to help you with a literature survey on machine learning in healthcare. This is a rapidly evolving field with numerous applications...',
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
          status: 'sent',
        ),
      ];

      for (final message in sampleMessages) {
        await addMessage(userId, conversationId, message);
      }

      print('Sample conversation created successfully');
    } catch (e) {
      print('Error creating sample conversation: $e');
    }
  }
}