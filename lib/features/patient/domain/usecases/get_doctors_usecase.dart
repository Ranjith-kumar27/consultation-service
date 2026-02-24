import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../repositories/patient_repository.dart';

class GetDoctorsUseCase
    implements UseCase<List<DoctorEntity>, GetDoctorsParams> {
  final PatientRepository repository;

  GetDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(
    GetDoctorsParams params,
  ) async {
    return await repository.getDoctors(params.query, params.specialization);
  }
}

class GetDoctorsParams extends Equatable {
  final String query;
  final String? specialization;

  const GetDoctorsParams({required this.query, this.specialization});

  @override
  List<Object?> get props => [query, specialization];
}
