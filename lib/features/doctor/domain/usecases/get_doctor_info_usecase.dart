import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/doctor_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorInfoUseCase implements UseCase<DoctorEntity, String> {
  final DoctorRepository repository;

  GetDoctorInfoUseCase(this.repository);

  @override
  Future<Either<Failure, DoctorEntity>> call(String doctorId) async {
    return await repository.getDoctorInfo(doctorId);
  }
}
