import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class NotificationRepository {
  Future<Either<Failure, String?>> getFcmToken();
  Future<Either<Failure, void>> subscribeToTopic(String topic);
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);
  Future<Either<Failure, void>> sendNotification(
    String userId,
    String title,
    String body, {
    Map<String, dynamic>? data,
  });
}
