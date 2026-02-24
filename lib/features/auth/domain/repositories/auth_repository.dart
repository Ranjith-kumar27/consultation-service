import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Repository interface for authentication-related operations.
abstract class AuthRepository {
  /// Logs in a user with email and password.
  Future<Either<Failure, UserEntity>> login(String email, String password);

  /// Registers a new patient.
  Future<Either<Failure, UserEntity>> registerPatient(
    String name,
    String email,
    String password,
  );

  /// Registers a new doctor.
  Future<Either<Failure, UserEntity>> registerDoctor(
    String name,
    String email,
    String password,
    String specialization,
    String location,
    double consultationFee,
  );

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Retrieves the currently authenticated user.
  Future<Either<Failure, UserEntity>> getCurrentUser();

  /// Updates the FCM token for a user.
  Future<Either<Failure, void>> updateFcmToken(String userId, String token);
}
