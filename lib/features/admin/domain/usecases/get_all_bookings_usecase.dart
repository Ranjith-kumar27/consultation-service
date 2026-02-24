import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/admin_repository.dart';
import '../../../patient/domain/entities/appointment_entity.dart';

class GetAllBookingsUseCase
    implements UseCase<List<AppointmentEntity>, NoParams> {
  final AdminRepository repository;

  GetAllBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(NoParams params) async {
    return await repository.getAllBookings();
  }
}
