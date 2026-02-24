import 'package:equatable/equatable.dart';

enum AppointmentStatus { pending, confirmed, completed, cancelled, rejected }

class AppointmentEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double totalAmount;
  final double commissionAmount;
  final double doctorEarning;
  final AppointmentStatus status;

  const AppointmentEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.totalAmount,
    required this.commissionAmount,
    required this.doctorEarning,
    required this.status,
  });

  @override
  List<Object?> get props => [
    id,
    doctorId,
    patientId,
    startTime,
    endTime,
    durationMinutes,
    totalAmount,
    commissionAmount,
    doctorEarning,
    status,
  ];
}
