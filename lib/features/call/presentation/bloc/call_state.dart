import 'package:equatable/equatable.dart';

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallLoading extends CallState {}

class CallInProgress extends CallState {
  final String channelName;
  final String? token;
  const CallInProgress({required this.channelName, this.token});

  @override
  List<Object?> get props => [channelName, token];
}

class CallEnded extends CallState {}

class CallError extends CallState {
  final String message;
  const CallError(this.message);

  @override
  List<Object?> get props => [message];
}
