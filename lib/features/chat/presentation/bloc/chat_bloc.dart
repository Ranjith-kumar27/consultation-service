import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:uuid/uuid.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatStreamUseCase getChatStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final AuthRepository authRepository;

  StreamSubscription? _chatSubscription;

  ChatBloc({
    required this.getChatStreamUseCase,
    required this.sendMessageUseCase,
    required this.markAsReadUseCase,
    required this.authRepository,
  }) : super(ChatInitial()) {
    on<LoadMessagesEvent>((event, emit) async {
      emit(ChatLoading());
      final result = await authRepository.getCurrentUser();
      final currentUserId = result.fold((l) => null, (r) => r.uid);
      if (currentUserId == null) {
        emit(const ChatError('User not authenticated'));
        return;
      }

      await _chatSubscription?.cancel();
      _chatSubscription = getChatStreamUseCase(currentUserId, event.otherUserId)
          .listen((result) {
            result.fold(
              (failure) =>
                  add(MessagesUpdatedEvent(const [])), // Or handle error
              (messages) => add(MessagesUpdatedEvent(messages)),
            );
          });
    });

    on<MessagesUpdatedEvent>((event, emit) {
      emit(ChatMessagesLoaded(event.messages));
    });

    on<SendMessageEvent>((event, emit) async {
      final authResult = await authRepository.getCurrentUser();
      final currentUserId = authResult.fold((l) => null, (r) => r.uid);
      if (currentUserId == null) return;

      final message = ChatMessageEntity(
        id: const Uuid().v4(),
        senderId: currentUserId,
        receiverId: event.receiverId,
        text: event.text,
        timestamp: DateTime.now(),
      );

      final result = await sendMessageUseCase(message);
      result.fold(
        (failure) => emit(ChatError(failure.message)),
        (_) => emit(MessageSent()),
      );
    });

    on<MarkMessageAsReadEvent>((event, emit) async {
      await markAsReadUseCase(event.messageId);
    });
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
