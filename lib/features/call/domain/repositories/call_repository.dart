import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class CallRepository {
  Future<Either<Failure, String>> getAgoraToken(String channelName, String uid);
  Future<Either<Failure, void>> startCall(
    String receiverId,
    String channelName,
  );
  Future<Either<Failure, void>> endCall(String callId);
  Stream<String?> getIncomingCallStream(String userId);
}
