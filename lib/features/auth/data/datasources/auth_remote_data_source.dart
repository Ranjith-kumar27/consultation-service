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
    String location,
    double consultationFee,
  );
  Future<void> logout();
  Future<UserModel> getCurrentUser();
  Future<void> updateFcmToken(String userId, String token);
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

      // Save profile to Firestore (non-blocking: if Firestore DB doesn't
      // exist yet the Auth account still succeeded, so we navigate anyway).
      try {
        print('Firestore: Saving patient to "users" collection...');
        await firestore
            .collection('users')
            .doc(userModel.uid)
            .set(userModel.toFirestore());
        print('Firestore: Patient saved successfully');
      } catch (firestoreError) {
        // Firestore write failed (e.g. database not yet created in Firebase
        // Console). Log the warning but do NOT block registration navigation.
        print(
          'Firestore Warning: Could not save patient profile – $firestoreError. '
          'Please create the Firestore database at '
          'https://console.firebase.google.com/project/_/firestore',
        );
      }

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
    String location,
    double consultationFee,
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

      // Save profile to Firestore (non-blocking: if Firestore DB doesn't
      // exist yet the Auth account still succeeded, so we navigate anyway).
      try {
        print('Firestore: Saving doctor to "users" collection...');
        await firestore
            .collection('users')
            .doc(userModel.uid)
            .set(userModel.toFirestore());
        print('Firestore: Base user info saved');

        print(
          'Firestore: Saving doctor metadata to "doctors_info" collection...',
        );
        await firestore.collection('doctors_info').doc(userModel.uid).set({
          'specialization': specialization,
          'isApproved': false,
          'isOnline': false,
          'earnings': 0.0,
          'commissionRate': 0.15,
          'location': location,
          'consultationFee': consultationFee,
        });
        print('Firestore: Doctor metadata saved successfully');
      } catch (firestoreError) {
        // Firestore write failed (e.g. database not yet created in Firebase
        // Console). Log the warning but do NOT block registration navigation.
        print(
          'Firestore Warning: Could not save doctor profile – $firestoreError. '
          'Please create the Firestore database at '
          'https://console.firebase.google.com/project/_/firestore',
        );
      }

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

    try {
      final doc = await firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        print(
          'Firestore Warning: User document not found for UID: ${user.uid}',
        );
        // Fallback: create a basic user model from auth data
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          role: UserRole.patient, // Default to patient if unknown
        );
      }
    } catch (e) {
      print('Firestore Error in getCurrentUser: $e');
      // Return a basic user model so the app doesn't crash
      return UserModel(
        uid: user.uid,
        name: user.displayName ?? 'User',
        email: user.email ?? '',
        role: UserRole.patient,
      );
    }
  }

  @override
  Future<void> updateFcmToken(String userId, String token) async {
    try {
      await firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
