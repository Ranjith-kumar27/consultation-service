import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatMessagesLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  const ChatMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSent extends ChatState {}

class RecentChatsLoaded extends ChatState {
  final List<Map<String, dynamic>> chats;
  const RecentChatsLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}
