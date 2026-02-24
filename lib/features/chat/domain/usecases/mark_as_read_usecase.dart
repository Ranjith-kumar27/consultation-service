import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class MarkAsReadUseCase implements UseCase<void, String> {
  final ChatRepository repository;

  MarkAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String messageId) async {
    return await repository.markAsRead(messageId);
  }
}
