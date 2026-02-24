import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/usecases/get_chat_stream_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/mark_as_read_usecase.dart';
import '../../domain/usecases/get_recent_chats_usecase.dart';
import '../../../../features/notification/domain/usecases/send_notification_usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import 'package:uuid/uuid.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatStreamUseCase getChatStreamUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final GetRecentChatsUseCase getRecentChatsUseCase;
  final SendNotificationUseCase sendNotificationUseCase;
  final AuthRepository authRepository;

  StreamSubscription? _chatSubscription;
  StreamSubscription? _recentChatsSubscription;

  ChatBloc({
    required this.getChatStreamUseCase,
    required this.sendMessageUseCase,
    required this.markAsReadUseCase,
    required this.getRecentChatsUseCase,
    required this.sendNotificationUseCase,
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
      result.fold((failure) => emit(ChatError(failure.message)), (_) async {
        final currentUser = authResult.fold((l) => null, (r) => r);
        final senderName = currentUser?.name ?? "Someone";

        await sendNotificationUseCase(
          SendNotificationParams(
            userId: event.receiverId,
            title: "New message from $senderName",
            body: event.text.length > 50
                ? "${event.text.substring(0, 50)}..."
                : event.text,
            data: {'type': 'chat', 'senderId': currentUserId},
          ),
        );
      });
    });

    on<MarkMessageAsReadEvent>((event, emit) async {
      await markAsReadUseCase(event.messageId);
    });

    on<LoadRecentChatsEvent>((event, emit) async {
      emit(ChatLoading());
      final result = await authRepository.getCurrentUser();
      final currentUserId = result.fold((l) => null, (r) => r.uid);
      if (currentUserId == null) {
        emit(const ChatError('User not authenticated'));
        return;
      }

      await _recentChatsSubscription?.cancel();
      _recentChatsSubscription = getRecentChatsUseCase(currentUserId).listen((
        result,
      ) {
        result.fold(
          (failure) => add(const RecentChatsUpdatedEvent([])),
          (chats) => add(RecentChatsUpdatedEvent(chats)),
        );
      });
    });

    on<RecentChatsUpdatedEvent>((event, emit) {
      emit(RecentChatsLoaded(event.chats));
    });
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    _recentChatsSubscription?.cancel();
    return super.close();
  }
}
