import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';

abstract class CallRemoteDataSource {
  Future<String> getAgoraToken(String channelName, String uid);
  Future<void> startCall(String receiverId, String channelName);
  Future<void> endCall(String callId);
  Stream<String?> getIncomingCallStream(String userId);
}

class CallRemoteDataSourceImpl implements CallRemoteDataSource {
  final FirebaseFirestore firestore;

  CallRemoteDataSourceImpl({required this.firestore});

  @override
  Future<String> getAgoraToken(String channelName, String uid) async {
    // In a real app, this would call a Cloud Function to get a token.
    // For demo purposes, we'll return a placeholder or empty string.
    // A test token can be generated from Agora Console.
    return "";
  }

  @override
  Future<void> startCall(String receiverId, String channelName) async {
    try {
      await firestore.collection('calls').add({
        'receiverId': receiverId,
        'channelName': channelName,
        'status': 'calling',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> endCall(String callId) async {
    try {
      await firestore.collection('calls').doc(callId).update({
        'status': 'ended',
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<String?> getIncomingCallStream(String userId) {
    return firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: 'calling')
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return snapshot.docs.first.id;
          }
          return null;
        });
  }
}
