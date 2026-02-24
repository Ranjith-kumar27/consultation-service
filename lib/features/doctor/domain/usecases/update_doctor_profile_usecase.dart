import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/doctor_repository.dart';

class UpdateDoctorProfileUseCase
    implements UseCase<void, UpdateDoctorProfileParams> {
  final DoctorRepository repository;

  UpdateDoctorProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateDoctorProfileParams params) async {
    return await repository.updateDoctorProfile(
      params.doctorId,
      bio: params.bio,
      specialization: params.specialization,
    );
  }
}

class UpdateDoctorProfileParams {
  final String doctorId;
  final String? bio;
  final String? specialization;

  UpdateDoctorProfileParams({
    required this.doctorId,
    this.bio,
    this.specialization,
  });
}
