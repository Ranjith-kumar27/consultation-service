import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

class FetchDoctorsEvent extends PatientEvent {
  final String query;
  final String? specialization;

  const FetchDoctorsEvent({this.query = '', this.specialization});

  @override
  List<Object?> get props => [query, specialization];
}

class FetchDoctorProfileEvent extends PatientEvent {
  final String doctorId;

  const FetchDoctorProfileEvent({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}

class BookAppointmentEvent extends PatientEvent {
  final String doctorId;
  final String patientId;
  final DateTime startTime;
  final DateTime endTime;

  const BookAppointmentEvent({
    required this.doctorId,
    required this.patientId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [doctorId, patientId, startTime, endTime];
}

class FetchPatientBookingsEvent extends PatientEvent {
  final String patientId;

  const FetchPatientBookingsEvent({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}
