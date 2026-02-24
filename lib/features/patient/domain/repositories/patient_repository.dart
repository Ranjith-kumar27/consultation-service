import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/appointment_entity.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

/// Repository interface for patient-related operations.
abstract class PatientRepository {
  /// Searches for doctors based on a query and optional specialization.
  Future<Either<Failure, List<DoctorEntity>>> getDoctors(
    String query,
    String? specialization,
  );

  /// Retrieves the detailed profile of a specific doctor.
  Future<Either<Failure, DoctorEntity>> getDoctorProfile(String doctorId);

  /// Books an appointment with a doctor.
  Future<Either<Failure, AppointmentEntity>> bookAppointment(
    String doctorId,
    String patientId,
    DateTime startTime,
    DateTime endTime,
  );

  /// Retrieves all bookings for a specific patient.
  Future<Either<Failure, List<AppointmentEntity>>> getPatientBookings(
    String patientId,
  );
}
