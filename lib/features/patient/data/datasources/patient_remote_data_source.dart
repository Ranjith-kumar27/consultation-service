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

      // Fetch names from users collection
      final doctors = await Future.wait(
        snapshot.docs.map((doc) async {
          final userDoc = await firestore.collection('users').doc(doc.id).get();
          final userData = userDoc.data();
          final name = userDoc.exists
              ? (userData?['name'] ?? 'Doctor')
              : 'Doctor';
          return DoctorModel.fromFirestore(doc, name: name);
        }),
      );

      // Search filtering by name if query is provided
      if (query.isNotEmpty) {
        return doctors
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }

      return doctors;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DoctorModel> getDoctorProfile(String doctorId) async {
    try {
      final docFuture = firestore
          .collection('doctors_info')
          .doc(doctorId)
          .get();
      final userDocFuture = firestore.collection('users').doc(doctorId).get();

      final results = await Future.wait([docFuture, userDocFuture]);
      final doc = results[0] as DocumentSnapshot;
      final userDoc = results[1] as DocumentSnapshot;

      if (!doc.exists) throw ServerException('Doctor not found');

      final name = userDoc.exists
          ? ((userDoc.data() as Map<String, dynamic>?)?['name'] ?? 'Doctor')
          : 'Doctor';
      return DoctorModel.fromFirestore(doc, name: name);
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
      final userDoc = await firestore.collection('users').doc(doctorId).get();
      final doctorName = userDoc.exists
          ? (userDoc.data()?['name'] ?? 'Doctor')
          : 'Doctor';

      // Calculate duration and amount
      final duration = endTime.difference(startTime).inMinutes;
      final fee = userDoc.data()?['consultationFee'] ?? 0.0;
      final amount = fee > 0
          ? (duration / 30.0) * fee
          : duration * 10.0; // Assuming 30 min slots or default
      final commission = amount * 0.15;
      final earning = amount - commission;

      final patientDoc = await firestore
          .collection('users')
          .doc(patientId)
          .get();
      final patientName = patientDoc.exists
          ? (patientDoc.data()?['name'] ?? 'Patient')
          : 'Patient';

      final docRef = firestore.collection('appointments').doc();
      final model = AppointmentModel(
        id: docRef.id,
        doctorId: doctorId,
        doctorName: doctorName,
        patientId: patientId,
        patientName: patientName,
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

      final bookings = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final dName = data['doctorName'] ?? 'Doctor';
          return AppointmentModel.fromFirestore(doc, doctorName: dName);
        }),
      );
      return bookings;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
