import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../datasources/patient_remote_data_source.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DoctorEntity>>> getDoctors(
    String query,
    String? specialization,
  ) async {
    try {
      final doctors = await remoteDataSource.getDoctors(query, specialization);
      return Right(doctors);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DoctorEntity>> getDoctorProfile(
    String doctorId,
  ) async {
    try {
      final doctor = await remoteDataSource.getDoctorProfile(doctorId);
      return Right(doctor);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> bookAppointment(
    String doctorId,
    String patientId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      final appointment = await remoteDataSource.bookAppointment(
        doctorId,
        patientId,
        startTime,
        endTime,
      );
      return Right(appointment);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getPatientBookings(
    String patientId,
  ) async {
    try {
      final bookings = await remoteDataSource.getPatientBookings(patientId);
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
