import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/doctor_repository.dart';

class GetEarningsSummaryUseCase implements UseCase<double, String> {
  final DoctorRepository repository;

  GetEarningsSummaryUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(String params) async {
    return await repository.getEarningsSummary(params);
  }
}
