import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_doctors_usecase.dart';
import '../../domain/usecases/get_doctor_profile_usecase.dart';
import '../../domain/usecases/book_appointment_usecase.dart';
import '../../domain/usecases/get_patient_bookings_usecase.dart';
import '../../../notification/domain/usecases/send_notification_usecase.dart';
import 'patient_event.dart';
import 'patient_state.dart';

/// BLoC responsible for managing patient-facing features like doctor searching and booking.
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetDoctorsUseCase getDoctorsUseCase;
  final GetDoctorProfileUseCase getDoctorProfileUseCase;
  final BookAppointmentUseCase bookAppointmentUseCase;
  final GetPatientBookingsUseCase getPatientBookingsUseCase;
  final SendNotificationUseCase sendNotificationUseCase;

  PatientBloc({
    required this.getDoctorsUseCase,
    required this.getDoctorProfileUseCase,
    required this.bookAppointmentUseCase,
    required this.getPatientBookingsUseCase,
    required this.sendNotificationUseCase,
  }) : super(PatientInitial()) {
    /// Handler for searching and fetching doctor lists.
    on<FetchDoctorsEvent>(_onFetchDoctors);

    /// Handler for fetching detailed doctor profile.
    on<FetchDoctorProfileEvent>(_onFetchDoctorProfile);

    /// Handler for booking an appointment.
    on<BookAppointmentEvent>(_onBookAppointment);

    /// Handler for fetching a patient's booking history.
    on<FetchPatientBookingsEvent>(_onFetchPatientBookings);
  }

  Future<void> _onFetchDoctors(
    FetchDoctorsEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    final result = await getDoctorsUseCase(
      GetDoctorsParams(
        query: event.query,
        specialization: event.specialization,
      ),
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (doctors) => emit(DoctorsLoaded(doctors: doctors)),
    );
  }

  Future<void> _onFetchDoctorProfile(
    FetchDoctorProfileEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    final result = await getDoctorProfileUseCase(
      GetDoctorProfileParams(doctorId: event.doctorId),
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (doctor) => emit(DoctorProfileLoaded(doctor: doctor)),
    );
  }

  Future<void> _onBookAppointment(
    BookAppointmentEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    final result = await bookAppointmentUseCase(
      BookAppointmentParams(
        doctorId: event.doctorId,
        patientId: event.patientId,
        startTime: event.startTime,
        endTime: event.endTime,
      ),
    );
    result.fold((failure) => emit(PatientError(message: failure.message)), (
      appointment,
    ) {
      // Notify Doctor
      sendNotificationUseCase(
        SendNotificationParams(
          userId: event.doctorId,
          title: 'New Booking Request',
          body: 'You have a new appointment request for ${event.startTime}',
        ),
      );
      emit(AppointmentBooked(appointment: appointment));
    });
  }

  Future<void> _onFetchPatientBookings(
    FetchPatientBookingsEvent event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());
    final result = await getPatientBookingsUseCase(
      GetPatientBookingsParams(patientId: event.patientId),
    );
    result.fold(
      (failure) => emit(PatientError(message: failure.message)),
      (bookings) => emit(BookingsLoaded(bookings: bookings)),
    );
  }
}
