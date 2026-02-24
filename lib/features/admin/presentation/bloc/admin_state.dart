import 'package:equatable/equatable.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class PendingDoctorsLoaded extends AdminState {
  final List<DoctorEntity> doctors;
  const PendingDoctorsLoaded(this.doctors);

  @override
  List<Object?> get props => [doctors];
}

class DoctorApproved extends AdminState {}

class UserBlockedStatusChanged extends AdminState {}

class AllBookingsLoaded extends AdminState {
  final List<AppointmentEntity> bookings;
  const AllBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class TotalTransactionsLoaded extends AdminState {
  final double amount;
  const TotalTransactionsLoaded(this.amount);

  @override
  List<Object?> get props => [amount];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
