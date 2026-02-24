import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Auth Imports
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_doctor_usecase.dart';
import '../../features/auth/domain/usecases/register_patient_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/patient/presentation/bloc/patient_bloc.dart';

// Patient Imports
import '../../features/patient/data/datasources/patient_remote_data_source.dart';
import '../../features/patient/data/repositories/patient_repository_impl.dart';
import '../../features/patient/domain/repositories/patient_repository.dart';
import '../../features/patient/domain/usecases/book_appointment_usecase.dart';
import '../../features/patient/domain/usecases/get_doctor_profile_usecase.dart';
import '../../features/patient/domain/usecases/get_doctors_usecase.dart';
import '../../features/patient/domain/usecases/get_patient_bookings_usecase.dart';

// Doctor Imports
import '../../features/doctor/data/datasources/doctor_remote_data_source.dart';
import '../../features/doctor/data/repositories/doctor_repository_impl.dart';
import '../../features/doctor/domain/repositories/doctor_repository.dart';
import '../../features/doctor/domain/usecases/set_availability_usecase.dart';
import '../../features/doctor/domain/usecases/manage_time_slots_usecase.dart';
import '../../features/doctor/domain/usecases/get_doctor_bookings_usecase.dart';
import '../../features/doctor/domain/usecases/update_booking_status_usecase.dart';
import '../../features/doctor/domain/usecases/get_earnings_summary_usecase.dart';
import '../../features/doctor/domain/usecases/get_doctor_info_usecase.dart';
import '../../features/doctor/domain/usecases/update_doctor_profile_usecase.dart';
import '../../features/doctor/presentation/bloc/doctor_bloc.dart';

// Admin Imports
import '../../features/admin/data/datasources/admin_remote_data_source.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/get_pending_doctors_usecase.dart';
import '../../features/admin/domain/usecases/approve_doctor_usecase.dart';
import '../../features/admin/domain/usecases/block_user_usecase.dart';
import '../../features/admin/domain/usecases/get_all_bookings_usecase.dart';
import '../../features/admin/domain/usecases/get_total_transactions_amount_usecase.dart';
import '../../features/admin/domain/usecases/get_all_users_usecase.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

// Chat Imports
import '../../features/chat/data/datasources/chat_remote_data_source.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/domain/usecases/get_chat_stream_usecase.dart';
import '../../features/chat/domain/usecases/send_message_usecase.dart';
import '../../features/chat/domain/usecases/mark_as_read_usecase.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';

// Call Imports
import '../../features/call/data/datasources/call_remote_data_source.dart';
import '../../features/call/data/repositories/call_repository_impl.dart';
import '../../features/call/domain/repositories/call_repository.dart';
import '../../features/call/domain/usecases/initialize_call_usecase.dart';
import '../../features/call/domain/usecases/start_call_usecase.dart';
import '../../features/call/domain/usecases/end_call_usecase.dart';
import '../../features/call/presentation/bloc/call_bloc.dart';

// Notification Imports
import '../../features/notification/data/datasources/notification_remote_data_source.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/repositories/notification_repository.dart';
import '../../features/notification/domain/usecases/get_fcm_token_usecase.dart';
import '../../features/notification/domain/usecases/subscribe_to_topic_usecase.dart';
import '../../features/notification/domain/usecases/send_notification_usecase.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ==================== Features - Auth ====================
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerPatientUseCase: sl(),
      registerDoctorUseCase: sl(),
      authRepository: sl(), // For logout / get current user
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterPatientUseCase(sl()));
  sl.registerLazySingleton(() => RegisterDoctorUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // ==================== Features - Patient ====================
  // Bloc
  sl.registerFactory(
    () => PatientBloc(
      getDoctorsUseCase: sl(),
      getDoctorProfileUseCase: sl(),
      bookAppointmentUseCase: sl(),
      getPatientBookingsUseCase: sl(),
      sendNotificationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorProfileUseCase(sl()));
  sl.registerLazySingleton(() => BookAppointmentUseCase(sl()));
  sl.registerLazySingleton(() => GetPatientBookingsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<PatientRepository>(
    () => PatientRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(firestore: sl()),
  );

  // ==================== Features - Doctor ====================
  // Bloc
  sl.registerFactory(
    () => DoctorBloc(
      setAvailabilityUseCase: sl(),
      manageTimeSlotsUseCase: sl(),
      getDoctorBookingsUseCase: sl(),
      updateBookingStatusUseCase: sl(),
      getEarningsSummaryUseCase: sl(),
      getDoctorInfoUseCase: sl(),
      updateDoctorProfileUseCase: sl(),
      sendNotificationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SetAvailabilityUseCase(sl()));
  sl.registerLazySingleton(() => ManageTimeSlotsUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorBookingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetEarningsSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetDoctorInfoUseCase(sl()));
  sl.registerLazySingleton(() => UpdateDoctorProfileUseCase(sl()));

  // Repository
  sl.registerLazySingleton<DoctorRepository>(
    () => DoctorRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<DoctorRemoteDataSource>(
    () => DoctorRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );

  // ==================== Features - Admin ====================
  // Bloc
  sl.registerFactory(
    () => AdminBloc(
      getPendingDoctorsUseCase: sl(),
      approveDoctorUseCase: sl(),
      blockUserUseCase: sl(),
      getAllBookingsUseCase: sl(),
      getTotalTransactionsAmountUseCase: sl(),
      getAllUsersUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPendingDoctorsUseCase(sl()));
  sl.registerLazySingleton(() => ApproveDoctorUseCase(sl()));
  sl.registerLazySingleton(() => BlockUserUseCase(sl()));
  sl.registerLazySingleton(() => GetAllBookingsUseCase(sl()));
  sl.registerLazySingleton(() => GetTotalTransactionsAmountUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(firestore: sl()),
  );

  // ==================== Features - Chat ====================
  // Bloc
  sl.registerFactory(
    () => ChatBloc(
      getChatStreamUseCase: sl(),
      sendMessageUseCase: sl(),
      markAsReadUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetChatStreamUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(firestore: sl()),
  );

  // ==================== Features - Call ====================
  // Bloc
  sl.registerFactory(
    () => CallBloc(
      initializeCallUseCase: sl(),
      startCallUseCase: sl(),
      endCallUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => InitializeCallUseCase(sl()));
  sl.registerLazySingleton(() => StartCallUseCase(sl()));
  sl.registerLazySingleton(() => EndCallUseCase(sl()));

  // Repository
  sl.registerLazySingleton<CallRepository>(
    () => CallRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CallRemoteDataSource>(
    () => CallRemoteDataSourceImpl(firestore: sl()),
  );

  // ==================== Features - Notification ====================
  // Bloc
  sl.registerFactory(
    () => NotificationBloc(
      getFcmTokenUseCase: sl(),
      subscribeToTopicUseCase: sl(),
      sendNotificationUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFcmTokenUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToTopicUseCase(sl()));
  sl.registerLazySingleton(() => SendNotificationUseCase(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(
      firebaseMessaging: sl(),
      firestore: sl(),
    ),
  );

  // ==================== Core ====================

  // ==================== External ====================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseMessaging.instance);
}
