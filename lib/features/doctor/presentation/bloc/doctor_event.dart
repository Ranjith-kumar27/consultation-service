import 'package:equatable/equatable.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

abstract class DoctorEvent extends Equatable {
  const DoctorEvent();

  @override
  List<Object?> get props => [];
}

class ToggleAvailabilityEvent extends DoctorEvent {
  final bool isOnline;
  const ToggleAvailabilityEvent(this.isOnline);

  @override
  List<Object?> get props => [isOnline];
}

class UpdateSlotsEvent extends DoctorEvent {
  final List<String> slots;
  const UpdateSlotsEvent(this.slots);

  @override
  List<Object?> get props => [slots];
}

class LoadDoctorBookingsEvent extends DoctorEvent {
  final String doctorId;
  const LoadDoctorBookingsEvent(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}

class UpdateBookingStatusEvent extends DoctorEvent {
  final String appointmentId;
  final AppointmentStatus status;

  const UpdateBookingStatusEvent(this.appointmentId, this.status);

  @override
  List<Object?> get props => [appointmentId, status];
}

class LoadEarningsSummaryEvent extends DoctorEvent {
  final String doctorId;
  const LoadEarningsSummaryEvent(this.doctorId);

  @override
  List<Object?> get props => [doctorId];
}
