import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class StartCallEvent extends CallEvent {
  final String receiverId;
  final String channelName;

  const StartCallEvent({required this.receiverId, required this.channelName});

  @override
  List<Object?> get props => [receiverId, channelName];
}

class AcceptCallEvent extends CallEvent {
  final String channelName;
  const AcceptCallEvent(this.channelName);

  @override
  List<Object?> get props => [channelName];
}

class EndCallEvent extends CallEvent {
  final String? callId;
  const EndCallEvent(this.callId);

  @override
  List<Object?> get props => [callId];
}

class InitializeEngineEvent extends CallEvent {}
