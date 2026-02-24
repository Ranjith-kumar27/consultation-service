import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/doctor_repository.dart';

class SetAvailabilityUseCase implements UseCase<void, SetAvailabilityParams> {
  final DoctorRepository repository;

  SetAvailabilityUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SetAvailabilityParams params) async {
    return await repository.setAvailability(params.isOnline);
  }
}

class SetAvailabilityParams extends Equatable {
  final bool isOnline;

  const SetAvailabilityParams({required this.isOnline});

  @override
  List<Object?> get props => [isOnline];
}
