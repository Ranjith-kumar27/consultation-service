import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingDoctorsEvent extends AdminEvent {}

class ApproveDoctorEvent extends AdminEvent {
  final String doctorId;
  const ApproveDoctorEvent(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

class BlockUserEvent extends AdminEvent {
  final String userId;
  final bool isBlocked;
  const BlockUserEvent(this.userId, this.isBlocked);

  @override
  List<Object?> get props => [userId, isBlocked];
}

class LoadAllBookingsEvent extends AdminEvent {}

class LoadTotalTransactionsEvent extends AdminEvent {}

class LoadAllUsersEvent extends AdminEvent {}
