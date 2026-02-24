import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessagesEvent extends ChatEvent {
  final String otherUserId;
  const LoadMessagesEvent(this.otherUserId);

  @override
  List<Object?> get props => [otherUserId];
}

class SendMessageEvent extends ChatEvent {
  final String receiverId;
  final String text;
  const SendMessageEvent({required this.receiverId, required this.text});

  @override
  List<Object?> get props => [receiverId, text];
}

class MessagesUpdatedEvent extends ChatEvent {
  final List<ChatMessageEntity> messages;
  const MessagesUpdatedEvent(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MarkMessageAsReadEvent extends ChatEvent {
  final String messageId;
  const MarkMessageAsReadEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}
