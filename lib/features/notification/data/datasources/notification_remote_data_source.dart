import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';

abstract class NotificationRemoteDataSource {
  Future<String?> getFcmToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> sendNotification(String userId, String title, String body);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseMessaging firebaseMessaging;
  final FirebaseFirestore firestore;

  NotificationRemoteDataSourceImpl({
    required this.firebaseMessaging,
    required this.firestore,
  });

  @override
  Future<String?> getFcmToken() async {
    try {
      return await firebaseMessaging.getToken();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> subscribeToTopic(String topic) async {
    try {
      await firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> sendNotification(
    String userId,
    String title,
    String body,
  ) async {
    // In a real production app, sending notifications would be done via a backend or Cloud Function
    // for security reasons (don't want to expose FCM Server Key in the client).
    // For now, we'll store the notification in a Firestore collection to be picked up by a function.
    try {
      await firestore.collection('notifications_queue').add({
        'userId': userId,
        'title': title,
        'body': body,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
