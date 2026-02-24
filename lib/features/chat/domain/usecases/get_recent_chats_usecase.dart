import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/chat_repository.dart';

class GetRecentChatsUseCase {
  final ChatRepository repository;

  GetRecentChatsUseCase(this.repository);

  Stream<Either<Failure, List<Map<String, dynamic>>>> call(String userId) {
    return repository.getRecentChats(userId);
  }
}
