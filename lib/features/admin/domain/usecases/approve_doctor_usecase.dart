import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class ApproveDoctorUseCase implements UseCase<void, String> {
  final AdminRepository repository;

  ApproveDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.approveDoctor(params);
  }
}
