import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/call_repository.dart';

class EndCallUseCase implements UseCase<void, String> {
  final CallRepository repository;

  EndCallUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String callId) async {
    return await repository.endCall(callId);
  }
}
