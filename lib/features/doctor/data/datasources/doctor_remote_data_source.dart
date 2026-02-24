import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../patient/data/models/appointment_model.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

abstract class DoctorRemoteDataSource {
  Future<void> setAvailability(bool isOnline);
  Future<void> manageTimeSlots(List<String> validSlots);
  Future<List<AppointmentModel>> getDoctorBookings(String doctorId);
  Future<void> updateBookingStatus(
    String appointmentId,
    AppointmentStatus status,
  );
  Future<double> getEarningsSummary(String doctorId);
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
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateBookingStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
      });
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
}
