import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterPatientUseCase
    implements UseCase<UserEntity, RegisterPatientParams> {
  final AuthRepository repository;

  RegisterPatientUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterPatientParams params) async {
    return await repository.registerPatient(
      params.name,
      params.email,
      params.password,
    );
  }
}

class RegisterPatientParams extends Equatable {
  final String name;
  final String email;
  final String password;

  const RegisterPatientParams({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}
