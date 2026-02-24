import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class GetTotalTransactionsAmountUseCase implements UseCase<double, NoParams> {
  final AdminRepository repository;

  GetTotalTransactionsAmountUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(NoParams params) async {
    return await repository.getTotalTransactionsAmount();
  }
}
