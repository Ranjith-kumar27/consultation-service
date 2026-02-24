import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/network/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/patient/presentation/bloc/patient_bloc.dart';
import 'features/doctor/presentation/bloc/doctor_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/call/presentation/bloc/call_bloc.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<PatientBloc>(create: (_) => di.sl<PatientBloc>()),
        BlocProvider<DoctorBloc>(create: (_) => di.sl<DoctorBloc>()),
        BlocProvider<AdminBloc>(create: (_) => di.sl<AdminBloc>()),
        BlocProvider<ChatBloc>(create: (_) => di.sl<ChatBloc>()),
        BlocProvider<CallBloc>(create: (_) => di.sl<CallBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Doctor Consultation',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
