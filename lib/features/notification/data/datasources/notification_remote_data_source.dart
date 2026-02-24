import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/fcm_messaging_service.dart';

abstract class NotificationRemoteDataSource {
  Future<String?> getFcmToken();
  Future<void> subscribeToTopic(String topic);
  Future<void> unsubscribeFromTopic(String topic);
  Future<void> sendNotification(
    String userId,
    String title,
    String body, {
    Map<String, dynamic>? data,
  });
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
    String body, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = userDoc.data();
      if (userData == null || !userData.containsKey('fcmToken')) return;

      final fcmToken = userData['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      await FcmMessagingService.sendPushNotification(
        fcmToken: fcmToken,
        title: title,
        body: body,
        data: data,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
