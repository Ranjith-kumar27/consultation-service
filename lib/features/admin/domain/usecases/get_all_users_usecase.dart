import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/admin_repository.dart';

class GetAllUsersUseCase implements UseCase<List<UserEntity>, NoParams> {
  final AdminRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getAllUsers();
  }
}
