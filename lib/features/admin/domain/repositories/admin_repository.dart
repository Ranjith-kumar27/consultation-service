import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Repository interface for administrative operations.
abstract class AdminRepository {
  /// Retrieves a list of doctors awaiting approval.
  Future<Either<Failure, List<DoctorEntity>>> getPendingDoctors();

  /// Approves a doctor's registration request.
  Future<Either<Failure, void>> approveDoctor(String doctorId);

  /// Blocks or unblocks a user based on their ID.
  Future<Either<Failure, void>> blockUser(String userId, bool isBlocked);

  /// Retrieves all bookings across the entire application.
  Future<Either<Failure, List<AppointmentEntity>>> getAllBookings();

  /// Calculates the total amount of all transactions.
  Future<Either<Failure, double>> getTotalTransactionsAmount();

  /// Retrieves all users (patients and doctors) for management.
  Future<Either<Failure, List<UserEntity>>> getAllUsers();
}
