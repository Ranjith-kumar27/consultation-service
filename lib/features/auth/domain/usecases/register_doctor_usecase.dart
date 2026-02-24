import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterDoctorUseCase
    implements UseCase<UserEntity, RegisterDoctorParams> {
  final AuthRepository repository;

  RegisterDoctorUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterDoctorParams params) async {
    return await repository.registerDoctor(
      params.name,
      params.email,
      params.password,
      params.specialization,
      params.location,
      params.consultationFee,
    );
  }
}

class RegisterDoctorParams extends Equatable {
  final String name;
  final String email;
  final String password;
  final String specialization;
  final String location;
  final double consultationFee;

  const RegisterDoctorParams({
    required this.name,
    required this.email,
    required this.password,
    required this.specialization,
    required this.location,
    required this.consultationFee,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    specialization,
    location,
    consultationFee,
  ];
}
