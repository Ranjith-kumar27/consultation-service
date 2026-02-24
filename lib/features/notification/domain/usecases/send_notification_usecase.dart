import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class SendNotificationUseCase implements UseCase<void, SendNotificationParams> {
  final NotificationRepository repository;

  SendNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SendNotificationParams params) async {
    return await repository.sendNotification(
      params.userId,
      params.title,
      params.body,
    );
  }
}

class SendNotificationParams extends Equatable {
  final String userId;
  final String title;
  final String body;

  const SendNotificationParams({
    required this.userId,
    required this.title,
    required this.body,
  });

  @override
  List<Object?> get props => [userId, title, body];
}
