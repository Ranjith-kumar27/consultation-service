import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/notification_repository.dart';

class GetFcmTokenUseCase implements UseCase<String?, NoParams> {
  final NotificationRepository repository;

  GetFcmTokenUseCase(this.repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await repository.getFcmToken();
  }
}
