import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> registerPatient(String name, String email, String password);
  Future<UserModel> registerDoctor(
    String name,
    String email,
    String password,
    String specialization,
  );
  Future<void> logout();
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('Firebase Auth: Attempting login for $email');
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
        'Firebase Auth: Login successful, UID: ${userCredential.user!.uid}',
      );

      print('Firestore: Fetching user document...');
      final doc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        print('Firestore Error: User document not found in "users" collection');
        throw AuthException('User not found in database.');
      }
      print('Firestore: User document fetched successfully');
      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: [${e.code}] ${e.message}');
      throw AuthException(e.message ?? 'Authentication failed.');
    } catch (e) {
      print('Unexpected Login Error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> registerPatient(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('Firebase Auth: Creating patient account for $email');
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase Auth: Account created, UID: ${userCredential.user!.uid}');

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        role: UserRole.patient,
      );

      print('Firestore: Saving patient to "users" collection...');
      await firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toFirestore());
      print('Firestore: Patient saved successfully');

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: [${e.code}] ${e.message}');
      throw AuthException(e.message ?? 'Registration failed.');
    } catch (e) {
      print('Unexpected Registration Error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> registerDoctor(
    String name,
    String email,
    String password,
    String specialization,
  ) async {
    try {
      print('Firebase Auth: Creating doctor account for $email');
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase Auth: Account created, UID: ${userCredential.user!.uid}');

      final userModel = UserModel(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
        role: UserRole.doctor,
      );

      print('Firestore: Saving doctor to "users" collection...');
      await firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toFirestore());
      print('Firestore: Base user info saved');

      print(
        'Firestore: Saving doctor metadata to "doctors_info" collection...',
      );
      // Also save to doctors_info
      await firestore.collection('doctors_info').doc(userModel.uid).set({
        'specialization': specialization,
        'isApproved': false,
        'isOnline': false,
        'earnings': 0.0,
        'commissionRate': 0.15,
      });
      print('Firestore: Doctor metadata saved successfully');

      return userModel;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: [${e.code}] ${e.message}');
      throw AuthException(e.message ?? 'Registration failed.');
    } catch (e) {
      print('Unexpected Registration Error: $e');
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw AuthException('No user logged in.');
    final doc = await firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) throw AuthException('User data not found.');
    return UserModel.fromFirestore(doc);
  }
}
