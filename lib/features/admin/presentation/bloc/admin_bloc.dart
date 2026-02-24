import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_pending_doctors_usecase.dart';
import '../../domain/usecases/approve_doctor_usecase.dart';
import '../../domain/usecases/block_user_usecase.dart';
import '../../domain/usecases/get_all_bookings_usecase.dart';
import '../../domain/usecases/get_total_transactions_amount_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetPendingDoctorsUseCase getPendingDoctorsUseCase;
  final ApproveDoctorUseCase approveDoctorUseCase;
  final BlockUserUseCase blockUserUseCase;
  final GetAllBookingsUseCase getAllBookingsUseCase;
  final GetTotalTransactionsAmountUseCase getTotalTransactionsAmountUseCase;

  AdminBloc({
    required this.getPendingDoctorsUseCase,
    required this.approveDoctorUseCase,
    required this.blockUserUseCase,
    required this.getAllBookingsUseCase,
    required this.getTotalTransactionsAmountUseCase,
  }) : super(AdminInitial()) {
    on<LoadPendingDoctorsEvent>((event, emit) async {
      emit(AdminLoading());
      final result = await getPendingDoctorsUseCase(NoParams());
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (doctors) => emit(PendingDoctorsLoaded(doctors)),
      );
    });

    on<ApproveDoctorEvent>((event, emit) async {
      emit(AdminLoading());
      final result = await approveDoctorUseCase(event.doctorId);
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (_) => emit(DoctorApproved()),
      );
    });

    on<BlockUserEvent>((event, emit) async {
      emit(AdminLoading());
      final result = await blockUserUseCase(
        BlockUserParams(userId: event.userId, isBlocked: event.isBlocked),
      );
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (_) => emit(UserBlockedStatusChanged()),
      );
    });

    on<LoadAllBookingsEvent>((event, emit) async {
      emit(AdminLoading());
      final result = await getAllBookingsUseCase(NoParams());
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (bookings) => emit(AllBookingsLoaded(bookings)),
      );
    });

    on<LoadTotalTransactionsEvent>((event, emit) async {
      emit(AdminLoading());
      final result = await getTotalTransactionsAmountUseCase(NoParams());
      result.fold(
        (failure) => emit(AdminError(failure.message)),
        (amount) => emit(TotalTransactionsLoaded(amount)),
      );
    });
  }
}
