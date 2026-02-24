import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../doctor/data/models/doctor_model.dart';
import '../../../patient/data/models/appointment_model.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

abstract class DoctorRemoteDataSource {
  Future<void> setAvailability(bool isOnline);
  Future<void> manageTimeSlots(List<String> validSlots);
  Future<List<AppointmentModel>> getDoctorBookings(String doctorId);
  Future<AppointmentModel> updateBookingStatus(
    String appointmentId,
    AppointmentStatus status,
  );
  Future<double> getEarningsSummary(String doctorId);
  Future<DoctorModel> getDoctorInfo(String doctorId);
  Future<void> updateDoctorProfile(
    String doctorId, {
    String? bio,
    String? specialization,
  });
}

class DoctorRemoteDataSourceImpl implements DoctorRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  DoctorRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  String get _uid => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<void> setAvailability(bool isOnline) async {
    try {
      if (_uid.isEmpty) throw AuthException('Not authenticated');
      await firestore.collection('doctors_info').doc(_uid).update({
        'isOnline': isOnline,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> manageTimeSlots(List<String> validSlots) async {
    try {
      if (_uid.isEmpty) throw AuthException('Not authenticated');
      await firestore.collection('doctors_info').doc(_uid).update({
        'availableSlots': validSlots,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getDoctorBookings(String doctorId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();
      final bookings = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final pId = data['patientId'] ?? '';
          final userDoc = await firestore.collection('users').doc(pId).get();
          final pName = userDoc.exists
              ? (userDoc.data()?['name'] ?? 'Patient')
              : 'Patient';
          return AppointmentModel.fromFirestore(doc, patientName: pName);
        }),
      );
      return bookings;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<AppointmentModel> updateBookingStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
      });
      final doc = await firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();
      final data = doc.data() as Map<String, dynamic>;
      final pId = data['patientId'] ?? '';
      final userDoc = await firestore.collection('users').doc(pId).get();
      final pName = userDoc.exists
          ? (userDoc.data()?['name'] ?? 'Patient')
          : 'Patient';

      return AppointmentModel.fromFirestore(doc, patientName: pName);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<double> getEarningsSummary(String doctorId) async {
    try {
      final snapshot = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: AppointmentStatus.completed.name)
          .get();
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['doctorEarning'] ?? 0.0).toDouble();
      }
      return total;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DoctorModel> getDoctorInfo(String doctorId) async {
    try {
      final doc = await firestore
          .collection('doctors_info')
          .doc(doctorId)
          .get();
      if (!doc.exists) throw ServerException('Doctor info not found');

      final userDoc = await firestore.collection('users').doc(doctorId).get();
      final name = userDoc.exists ? (userDoc.data()?['name'] ?? '') : '';

      return DoctorModel.fromFirestore(doc, name: name);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDoctorProfile(
    String doctorId, {
    String? bio,
    String? specialization,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (bio != null) updates['bio'] = bio;
      if (specialization != null) updates['specialization'] = specialization;

      if (updates.isNotEmpty) {
        await firestore
            .collection('doctors_info')
            .doc(doctorId)
            .update(updates);
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
