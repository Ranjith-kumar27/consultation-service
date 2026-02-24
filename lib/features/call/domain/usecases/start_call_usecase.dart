import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/call_repository.dart';

class StartCallUseCase implements UseCase<void, StartCallParams> {
  final CallRepository repository;

  StartCallUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(StartCallParams params) async {
    return await repository.startCall(params.receiverId, params.channelName);
  }
}

class StartCallParams {
  final String receiverId;
  final String channelName;

  StartCallParams({required this.receiverId, required this.channelName});
}
