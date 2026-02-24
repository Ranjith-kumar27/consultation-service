import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import '../repositories/doctor_repository.dart';

class GetDoctorBookingsUseCase
    implements UseCase<List<AppointmentEntity>, String> {
  final DoctorRepository repository;

  GetDoctorBookingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AppointmentEntity>>> call(String params) async {
    return await repository.getDoctorBookings(params);
  }
}
