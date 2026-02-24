import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/set_availability_usecase.dart';
import '../../domain/usecases/manage_time_slots_usecase.dart';
import '../../domain/usecases/get_doctor_bookings_usecase.dart';
import '../../domain/usecases/update_booking_status_usecase.dart';
import '../../domain/usecases/get_earnings_summary_usecase.dart';
import 'doctor_event.dart';
import 'doctor_state.dart';

/// BLoC responsible for managing doctor-facing features like availability and earnings.
class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final SetAvailabilityUseCase setAvailabilityUseCase;
  final ManageTimeSlotsUseCase manageTimeSlotsUseCase;
  final GetDoctorBookingsUseCase getDoctorBookingsUseCase;
  final UpdateBookingStatusUseCase updateBookingStatusUseCase;
  final GetEarningsSummaryUseCase getEarningsSummaryUseCase;

  DoctorBloc({
    required this.setAvailabilityUseCase,
    required this.manageTimeSlotsUseCase,
    required this.getDoctorBookingsUseCase,
    required this.updateBookingStatusUseCase,
    required this.getEarningsSummaryUseCase,
  }) : super(DoctorInitial()) {
    on<ToggleAvailabilityEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await setAvailabilityUseCase(
        SetAvailabilityParams(isOnline: event.isOnline),
      );
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (_) => emit(DoctorAvailabilityUpdated(event.isOnline)),
      );
    });

    on<UpdateSlotsEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await manageTimeSlotsUseCase(event.slots);
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (_) => emit(DoctorSlotsUpdated()),
      );
    });

    on<LoadDoctorBookingsEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await getDoctorBookingsUseCase(event.doctorId);
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (bookings) => emit(DoctorBookingsLoaded(bookings)),
      );
    });

    on<UpdateBookingStatusEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await updateBookingStatusUseCase(
        UpdateBookingStatusParams(
          appointmentId: event.appointmentId,
          status: event.status,
        ),
      );
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (_) => emit(DoctorBookingStatusUpdated()),
      );
    });

    on<LoadEarningsSummaryEvent>((event, emit) async {
      emit(DoctorLoading());
      final result = await getEarningsSummaryUseCase(event.doctorId);
      result.fold(
        (failure) => emit(DoctorError(failure.message)),
        (earnings) => emit(DoctorEarningsLoaded(earnings)),
      );
    });
  }
}
