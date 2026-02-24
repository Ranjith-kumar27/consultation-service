import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/call_repository.dart';
import '../datasources/call_remote_data_source.dart';

class CallRepositoryImpl implements CallRepository {
  final CallRemoteDataSource remoteDataSource;

  CallRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, String>> getAgoraToken(
    String channelName,
    String uid,
  ) async {
    try {
      final token = await remoteDataSource.getAgoraToken(channelName, uid);
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> startCall(
    String receiverId,
    String channelName,
  ) async {
    try {
      await remoteDataSource.startCall(receiverId, channelName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> endCall(String callId) async {
    try {
      await remoteDataSource.endCall(callId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<String?> getIncomingCallStream(String userId) {
    return remoteDataSource.getIncomingCallStream(userId);
  }
}
