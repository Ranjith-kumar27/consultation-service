import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/chat_message_entity.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatMessageEntity>>> getChatStream(
    String currentUserId,
    String otherUserId,
  );
  Future<Either<Failure, void>> sendMessage(ChatMessageEntity message);
  Future<Either<Failure, void>> markAsRead(String messageId);
}
