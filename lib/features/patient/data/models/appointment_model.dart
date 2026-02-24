import '../../domain/entities/appointment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel extends AppointmentEntity {
  const AppointmentModel({
    required super.id,
    required super.doctorId,
    required super.patientId,
    required super.startTime,
    required super.endTime,
    required super.durationMinutes,
    required super.totalAmount,
    required super.commissionAmount,
    required super.doctorEarning,
    required super.status,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      durationMinutes: data['durationMinutes'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      commissionAmount: (data['commissionAmount'] ?? 0.0).toDouble(),
      doctorEarning: (data['doctorEarning'] ?? 0.0).toDouble(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AppointmentStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'durationMinutes': durationMinutes,
      'totalAmount': totalAmount,
      'commissionAmount': commissionAmount,
      'doctorEarning': doctorEarning,
      'status': status.name,
    };
  }
}
