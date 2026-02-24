import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../doctor/data/models/doctor_model.dart';
import '../../../patient/data/models/appointment_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AdminRemoteDataSource {
  Future<List<DoctorModel>> getPendingDoctors();
  Future<void> approveDoctor(String doctorId);
  Future<void> blockUser(String userId, bool isBlocked);
  Future<List<AppointmentModel>> getAllBookings();
  Future<double> getTotalTransactionsAmount();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<DoctorModel>> getPendingDoctors() async {
    try {
      final snapshot = await firestore
          .collection('doctors_info')
          .where('isApproved', isEqualTo: false)
          .get();
      return snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> approveDoctor(String doctorId) async {
    try {
      await firestore.collection('doctors_info').doc(doctorId).update({
        'isApproved': true,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> blockUser(String userId, bool isBlocked) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'isBlocked': isBlocked,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<AppointmentModel>> getAllBookings() async {
    try {
      final snapshot = await firestore.collection('appointments').get();
      return snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<double> getTotalTransactionsAmount() async {
    try {
      final snapshot = await firestore.collection('appointments').get();
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['totalAmount'] ?? 0.0).toDouble();
      }
      return total;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
