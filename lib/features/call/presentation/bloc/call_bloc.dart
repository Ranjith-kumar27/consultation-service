import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/initialize_call_usecase.dart';
import '../../domain/usecases/start_call_usecase.dart';
import '../../domain/usecases/end_call_usecase.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final InitializeCallUseCase initializeCallUseCase;
  final StartCallUseCase startCallUseCase;
  final EndCallUseCase endCallUseCase;

  CallBloc({
    required this.initializeCallUseCase,
    required this.startCallUseCase,
    required this.endCallUseCase,
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
