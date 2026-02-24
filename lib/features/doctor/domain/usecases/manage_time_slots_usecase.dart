import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/doctor_repository.dart';

class ManageTimeSlotsUseCase implements UseCase<void, List<String>> {
  final DoctorRepository repository;

  ManageTimeSlotsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(List<String> params) async {
    return await repository.manageTimeSlots(params);
  }
}
