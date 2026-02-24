import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../doctor/data/models/doctor_model.dart';
import '../../../patient/data/models/appointment_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AdminRemoteDataSource {
  Future<List<DoctorModel>> getPendingDoctors();
  Future<void> approveDoctor(String doctorId);
  Future<void> blockUser(String userId, bool isBlocked);
  Future<List<AppointmentModel>> getAllBookings();
  Future<double> getTotalTransactionsAmount();
  Future<List<UserModel>> getAllUsers();
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

      final pendingDoctors = await Future.wait(
        snapshot.docs.map((doc) async {
          final userDoc = await firestore.collection('users').doc(doc.id).get();
          final name = userDoc.exists
              ? (userDoc.data()?['name'] ?? 'Doctor')
              : 'Doctor';
          return DoctorModel.fromFirestore(doc, name: name);
        }),
      );

      return pendingDoctors;
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
      final bookings = await Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final dId = data['doctorId'] ?? '';
          final pId = data['patientId'] ?? '';

          final dDocFuture = firestore.collection('users').doc(dId).get();
          final pDocFuture = firestore.collection('users').doc(pId).get();
          final results = await Future.wait([dDocFuture, pDocFuture]);

          final dName = results[0].exists
              ? (results[0].data()?['name'] ?? 'Doctor')
              : 'Doctor';
          final pName = results[1].exists
              ? (results[1].data()?['name'] ?? 'Patient')
              : 'Patient';

          return AppointmentModel.fromFirestore(
            doc,
            doctorName: dName,
            patientName: pName,
          );
        }),
      );
      return bookings;
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

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
