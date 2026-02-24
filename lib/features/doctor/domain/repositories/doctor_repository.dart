import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import '../../domain/entities/doctor_entity.dart';

/// Repository interface for doctor-related operations.
abstract class DoctorRepository {
  /// Sets the doctor's online availability status.
  Future<Either<Failure, void>> setAvailability(bool isOnline);

  /// Manages the available time slots for the doctor.
  Future<Either<Failure, void>> manageTimeSlots(List<String> validSlots);

  /// Retrieves all bookings assigned to a specific doctor.
  Future<Either<Failure, List<AppointmentEntity>>> getDoctorBookings(
    String doctorId,
  );

  /// Updates the status (e.g., accepted, rejected, completed) of a booking.
  Future<Either<Failure, AppointmentEntity>> updateBookingStatus(
    String appointmentId,
    AppointmentStatus status,
  );

  /// Retrieves a summary of the doctor's total earnings.
  Future<Either<Failure, double>> getEarningsSummary(String doctorId);

  /// Retrieves the doctor's complete information.
  Future<Either<Failure, DoctorEntity>> getDoctorInfo(String doctorId);

  /// Updates the doctor's profile information.
  Future<Either<Failure, void>> updateDoctorProfile(
    String doctorId, {
    String? bio,
    String? specialization,
  });
}
