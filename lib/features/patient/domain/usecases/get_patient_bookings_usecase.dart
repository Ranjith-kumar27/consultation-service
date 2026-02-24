import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/appointment_entity.dart';
import '../repositories/patient_repository.dart';

class GetPatientBookingsUseCase
    implements UseCase<List<AppointmentEntity>, GetPatientBookingsParams> {
  final PatientRepository repository;

  GetPatientBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(
    GetPatientBookingsParams params,
  ) async {
    return await repository.getPatientBookings(params.patientId);
  }
}

class GetPatientBookingsParams extends Equatable {
  final String patientId;

  const GetPatientBookingsParams({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}
