import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import '../repositories/doctor_repository.dart';

class UpdateBookingStatusUseCase
    implements UseCase<void, UpdateBookingStatusParams> {
  final DoctorRepository repository;

  UpdateBookingStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBookingStatusParams params) async {
    return await repository.updateBookingStatus(
      params.appointmentId,
      params.status,
    );
  }
}

class UpdateBookingStatusParams extends Equatable {
  final String appointmentId;
  final AppointmentStatus status;

  const UpdateBookingStatusParams({
    required this.appointmentId,
    required this.status,
  });

  @override
  List<Object?> get props => [appointmentId, status];
}
