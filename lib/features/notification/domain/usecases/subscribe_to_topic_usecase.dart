import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class SubscribeToTopicUseCase implements UseCase<void, String> {
  final NotificationRepository repository;

  SubscribeToTopicUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.subscribeToTopic(params);
  }
}
