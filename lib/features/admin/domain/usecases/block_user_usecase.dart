import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';

class BlockUserUseCase implements UseCase<void, BlockUserParams> {
  final AdminRepository repository;

  BlockUserUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BlockUserParams params) async {
    return await repository.blockUser(params.userId, params.isBlocked);
  }
}

class BlockUserParams extends Equatable {
  final String userId;
  final bool isBlocked;

  const BlockUserParams({required this.userId, required this.isBlocked});

  @override
  List<Object?> get props => [userId, isBlocked];
}
