import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/patient_repository.dart';

class BookAppointmentUseCase
    implements UseCase<AppointmentEntity, BookAppointmentParams> {
  final PatientRepository repository;

  BookAppointmentUseCase(this.repository);

  @override
  Future<Either<Failure, AppointmentEntity>> call(
    BookAppointmentParams params,
  ) async {
    return await repository.bookAppointment(
      params.doctorId,
      params.patientId,
      params.startTime,
      params.endTime,
    );
  }
}

class BookAppointmentParams extends Equatable {
  final String doctorId;
  final String patientId;
  final DateTime startTime;
  final DateTime endTime;

  const BookAppointmentParams({
    required this.doctorId,
    required this.patientId,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [doctorId, patientId, startTime, endTime];
}
