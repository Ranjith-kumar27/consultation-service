import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../repositories/patient_repository.dart';

class GetDoctorProfileUseCase
    implements UseCase<DoctorEntity, GetDoctorProfileParams> {
  final PatientRepository repository;

  GetDoctorProfileUseCase(this.repository);

  @override
  Future<Either<Failure, DoctorEntity>> call(
    GetDoctorProfileParams params,
  ) async {
    return await repository.getDoctorProfile(params.doctorId);
  }
}

class GetDoctorProfileParams extends Equatable {
  final String doctorId;

  const GetDoctorProfileParams({required this.doctorId});

  @override
  List<Object?> get props => [doctorId];
}
