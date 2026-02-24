import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/get_fcm_token_usecase.dart';
import '../../domain/usecases/subscribe_to_topic_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import '../../../../core/usecases/usecase.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class GetFcmTokenEvent extends NotificationEvent {}

class SubscribeToTopicEvent extends NotificationEvent {
  final String topic;
  const SubscribeToTopicEvent(this.topic);
  @override
  List<Object?> get props => [topic];
}

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationTokenLoaded extends NotificationState {
  final String? token;
  const NotificationTokenLoaded(this.token);
  @override
  List<Object?> get props => [token];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetFcmTokenUseCase getFcmTokenUseCase;
  final SubscribeToTopicUseCase subscribeToTopicUseCase;
  final SendNotificationUseCase sendNotificationUseCase;

  NotificationBloc({
    required this.getFcmTokenUseCase,
    required this.subscribeToTopicUseCase,
    required this.sendNotificationUseCase,
  }) : super(NotificationInitial()) {
    on<GetFcmTokenEvent>((event, emit) async {
      emit(NotificationLoading());
      final result = await getFcmTokenUseCase(NoParams());
      result.fold(
        (failure) => emit(NotificationError(failure.message)),
        (token) => emit(NotificationTokenLoaded(token)),
      );
    });

    on<SubscribeToTopicEvent>((event, emit) async {
      await subscribeToTopicUseCase(event.topic);
    });
  }
}
