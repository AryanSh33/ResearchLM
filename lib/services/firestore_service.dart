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

      final conversation = Conversation(
        id: conversationRef.id,
        title: title,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageCount: 0,
      );

      await conversationRef.set(conversation.toJson());
      return conversationRef.id;
    } catch (e) {
      print('Error creating conversation: $e');
      throw Exception('Failed to create conversation: $e');
    }
  }

  // Get conversations for user
  Stream<List<Conversation>> getConversations(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Conversation.fromJson(doc.data()))
        .toList());
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

      batch.set(messageRef, message.toJson());

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

      await batch.commit();
    } catch (e) {
      print('Error adding message: $e');
      throw Exception('Failed to add message: $e');
    }
  }

  // Get messages for conversation
  Stream<List<Message>> getMessages(String userId, String conversationId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Message.fromJson(doc.data()))
        .toList());
  }

  // Delete conversation and all its messages
  Future<void> deleteConversation(String userId, String conversationId) async {
    try {
      final batch = _db.batch();

      // Delete all messages
      final messagesSnapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .get();

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
}