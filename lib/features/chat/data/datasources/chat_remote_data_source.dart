import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ChatMessageModel>> getChatStream(
    String currentUserId,
    String otherUserId,
  );
  Future<void> sendMessage(ChatMessageModel message);
  Future<void> markAsRead(String messageId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;

  ChatRemoteDataSourceImpl({required this.firestore});

  String _getChatRoomId(String uid1, String uid2) {
    if (uid1.compareTo(uid2) > 0) {
      return '${uid1}_$uid2';
    } else {
      return '${uid2}_$uid1';
    }
  }

  @override
  Stream<List<ChatMessageModel>> getChatStream(
    String currentUserId,
    String otherUserId,
  ) {
    final roomId = _getChatRoomId(currentUserId, otherUserId);
    return firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(ChatMessageModel message) async {
    try {
      final roomId = _getChatRoomId(message.senderId, message.receiverId);
      final docRef = firestore.collection('chats').doc(roomId);
      await docRef.set({
        'participants': [message.senderId, message.receiverId],
      }, SetOptions(merge: true));

      await docRef
          .collection('messages')
          .doc(message.id)
          .set(message.toFirestore());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> markAsRead(String messageId) async {
    // Requires room ID to locate the message, this might need restructuring if flat collection isn't used
    // Simplest is to assume this runs inside a context where the message doc ref is known,
    // but for now we'll leave as a placeholder or use a collectionGroup query.
  }
}
