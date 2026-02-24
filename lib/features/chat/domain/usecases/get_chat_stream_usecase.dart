import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetChatStreamUseCase {
  final ChatRepository repository;

  GetChatStreamUseCase(this.repository);

  Stream<Either<Failure, List<ChatMessageEntity>>> call(
    String currentUserId,
    String otherUserId,
  ) {
    return repository.getChatStream(currentUserId, otherUserId);
  }
}
