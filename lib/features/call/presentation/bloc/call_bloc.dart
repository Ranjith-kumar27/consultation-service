import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/initialize_call_usecase.dart';
import '../../domain/usecases/start_call_usecase.dart';
import '../../domain/usecases/end_call_usecase.dart';
import '../../../../features/notification/domain/usecases/send_notification_usecase.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final InitializeCallUseCase initializeCallUseCase;
  final StartCallUseCase startCallUseCase;
  final EndCallUseCase endCallUseCase;
  final SendNotificationUseCase sendNotificationUseCase;
  final AuthRepository authRepository;

  CallBloc({
    required this.initializeCallUseCase,
    required this.startCallUseCase,
    required this.endCallUseCase,
    required this.sendNotificationUseCase,
    required this.authRepository,
  }) : super(CallInitial()) {
    on<StartCallEvent>((event, emit) async {
      emit(CallLoading());
      final result = await startCallUseCase(
        StartCallParams(
          receiverId: event.receiverId,
          channelName: event.channelName,
        ),
      );

      await result.fold((failure) async => emit(CallError(failure.message)), (
        _,
      ) async {
        final authResult = await authRepository.getCurrentUser();
        final currentUser = authResult.fold((l) => null, (r) => r);
        final callerName = currentUser?.name ?? "Someone";

        await sendNotificationUseCase(
          SendNotificationParams(
            userId: event.receiverId,
            title: "Incoming Video Call",
            body: "$callerName is calling you...",
            data: {
              'type': 'call',
              'callerId': currentUser?.uid ?? '',
              'channelName': event.channelName,
            },
          ),
        );

        final tokenResult = await initializeCallUseCase(
          CallParams(channelName: event.channelName, uid: "0"),
        );
        tokenResult.fold(
          (failure) => emit(CallError(failure.message)),
          (token) => emit(
            CallInProgress(channelName: event.channelName, token: token),
          ),
        );
      });
    });

    on<AcceptCallEvent>((event, emit) async {
      emit(CallLoading());
      final tokenResult = await initializeCallUseCase(
        CallParams(channelName: event.channelName, uid: "0"),
      );
      tokenResult.fold(
        (failure) => emit(CallError(failure.message)),
        (token) =>
            emit(CallInProgress(channelName: event.channelName, token: token)),
      );
    });

    on<EndCallEvent>((event, emit) async {
      if (event.callId != null) {
        await endCallUseCase(event.callId!);
      }
      emit(CallEnded());
    });
  }
}
