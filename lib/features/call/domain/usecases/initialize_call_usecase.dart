import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/call_repository.dart';

class InitializeCallUseCase implements UseCase<String, CallParams> {
  final CallRepository repository;

  InitializeCallUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(CallParams params) async {
    return await repository.getAgoraToken(params.channelName, params.uid);
  }
}

class CallParams {
  final String channelName;
  final String uid;

  CallParams({required this.channelName, required this.uid});
}
