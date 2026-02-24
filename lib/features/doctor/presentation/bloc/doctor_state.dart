import 'package:equatable/equatable.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

abstract class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object?> get props => [];
}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorAvailabilityUpdated extends DoctorState {
  final bool isOnline;
  const DoctorAvailabilityUpdated(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class DoctorSlotsUpdated extends DoctorState {}

class DoctorBookingsLoaded extends DoctorState {
  final List<AppointmentEntity> bookings;
  const DoctorBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class DoctorBookingStatusUpdated extends DoctorState {}

class DoctorEarningsLoaded extends DoctorState {
  final double earnings;
  const DoctorEarningsLoaded(this.earnings);

  @override
  List<Object?> get props => [earnings];
}

class DoctorError extends DoctorState {
  final String message;
  const DoctorError(this.message);

  @override
  List<Object?> get props => [message];
}
