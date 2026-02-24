import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_doctor_usecase.dart';
import '../../domain/usecases/register_patient_usecase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC responsible for managing authentication states and logic.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPatientUseCase registerPatientUseCase;
  final RegisterDoctorUseCase registerDoctorUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerPatientUseCase,
    required this.registerDoctorUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    /// Handler for checking the current authentication status.
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);

    /// Handler for login requests.
    on<LoginRequestedEvent>(_onLoginRequested);

    /// Handler for patient registration.
    on<RegisterPatientEvent>(_onRegisterPatient);

    /// Handler for doctor registration.
    on<RegisterDoctorEvent>(_onRegisterDoctor);

    /// Handler for logout requests.
    on<LogoutRequestedEvent>(_onLogoutRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.getCurrentUser();
    result.fold(
      (failure) => emit(AuthUnauthenticated()), // Not logged in
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLoginRequested(
    LoginRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure.message));
      },
      (user) async {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await authRepository.updateFcmToken(user.uid, token);
        }
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterPatient(
    RegisterPatientEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await registerPatientUseCase(
      RegisterPatientParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure.message));
      },
      (user) async {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await authRepository.updateFcmToken(user.uid, token);
        }
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterDoctor(
    RegisterDoctorEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (state is AuthLoading) return;
    emit(AuthLoading());
    final result = await registerDoctorUseCase(
      RegisterDoctorParams(
        name: event.name,
        email: event.email,
        password: event.password,
        specialization: event.specialization,
        location: event.location,
        consultationFee: event.consultationFee,
      ),
    );

    await result.fold(
      (failure) async {
        emit(AuthError(message: failure.message));
      },
      (user) async {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await authRepository.updateFcmToken(user.uid, token);
        }
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.logout();
    result.fold(
      (failure) => emit(
        AuthError(message: failure.message),
      ), // Even on logout error, you might want to force unauthenticated
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
