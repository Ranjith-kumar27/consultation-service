import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class FcmMessagingService {
  static const String _projectId = 'consultation-service-3ad34';
  static const String _serviceAccountJsonString = String.fromEnvironment(
    'FIREBASE_SERVICE_ACCOUNT',
  );

  static Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(
      _serviceAccountJsonString,
    );
    var scopes = ['https://www.googleapis.com/auth/cloud-platform'];
    final authClient = await clientViaServiceAccount(
      accountCredentials,
      scopes,
    );
    return authClient.credentials.accessToken.data;
  }

  static Future<void> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final String serverToken = await _getAccessToken();
      final String endpoint =
          'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

      final Map<String, dynamic> message = {
        'message': {
          'token': fcmToken,
          'notification': {'title': title, 'body': body},
          if (data != null) 'data': data,
        },
      };

      final response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('FCM notification sent successfully');
      } else {
        print('Failed to send FCM notification: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }
}
