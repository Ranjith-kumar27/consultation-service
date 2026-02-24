import 'package:equatable/equatable.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../domain/entities/appointment_entity.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class DoctorsLoaded extends PatientState {
  final List<DoctorEntity> doctors;

  const DoctorsLoaded({required this.doctors});

  @override
  List<Object?> get props => [doctors];
}

class DoctorProfileLoaded extends PatientState {
  final DoctorEntity doctor;

  const DoctorProfileLoaded({required this.doctor});

  @override
  List<Object?> get props => [doctor];
}

class AppointmentBooked extends PatientState {
  final AppointmentEntity appointment;

  const AppointmentBooked({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}

class BookingsLoaded extends PatientState {
  final List<AppointmentEntity> bookings;

  const BookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class PatientError extends PatientState {
  final String message;

  const PatientError({required this.message});

  @override
  List<Object?> get props => [message];
}
