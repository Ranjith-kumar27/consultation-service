import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

class GetPendingDoctorsUseCase
    implements UseCase<List<DoctorEntity>, NoParams> {
  final AdminRepository repository;

  GetPendingDoctorsUseCase(this.repository);

  @override
  Future<Either<Failure, List<DoctorEntity>>> call(NoParams params) async {
    return await repository.getPendingDoctors();
  }
}
