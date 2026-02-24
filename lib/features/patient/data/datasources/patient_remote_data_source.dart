import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../doctor/data/models/doctor_model.dart';
import '../../domain/entities/appointment_entity.dart';
import '../models/appointment_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<DoctorModel>> getDoctors(String query, String? specialization);
  Future<DoctorModel> getDoctorProfile(String doctorId);
  Future<AppointmentModel> bookAppointment(
    String doctorId,
    String patientId,
    DateTime startTime,
    DateTime endTime,
  );
  Future<List<AppointmentModel>> getPatientBookings(String patientId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final FirebaseFirestore firestore;

  PatientRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DoctorModel>> getDoctors(
    String query,
    String? specialization,
  ) async {
    try {
      Query collection = firestore
          .collection('doctors_info')
          .where('isApproved', isEqualTo: true);
      if (specialization != null && specialization.isNotEmpty) {
        collection = collection.where(
          'specialization',
          isEqualTo: specialization,
        );
      }
      final snapshot = await collection.get();
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DoctorModel> getDoctorProfile(String doctorId) async {
    try {
      final doc = await firestore
          .collection('doctors_info')
          .doc(doctorId)
          .get();
      if (!doc.exists) throw ServerException('Doctor not found');
      return DoctorModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AppointmentModel> bookAppointment(
    String doctorId,
    String patientId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Calculate duration and amount
      final duration = endTime.difference(startTime).inMinutes;
      final amount = duration * 2.0; // dummy 2 per min
      final commission = amount * 0.15;
      final earning = amount - commission;

      final docRef = firestore.collection('appointments').doc();
      final model = AppointmentModel(
        id: docRef.id,
        doctorId: doctorId,
        patientId: patientId,
        startTime: startTime,
        endTime: endTime,
        durationMinutes: duration,
        totalAmount: amount,
        commissionAmount: commission,
        doctorEarning: earning,
        status: AppointmentStatus.pending,
      );
      await docRef.set(model.toFirestore());
      return model;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getPatientBookings(String patientId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('patientId', isEqualTo: patientId)
          .get();
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
