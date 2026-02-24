import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class LoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginRequestedEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class RegisterPatientEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterPatientEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class RegisterDoctorEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String specialization;
  final String location;
  final double consultationFee;

  const RegisterDoctorEvent({
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

class LogoutRequestedEvent extends AuthEvent {}
