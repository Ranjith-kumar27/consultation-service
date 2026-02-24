import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_patient_page.dart';
import '../../features/auth/presentation/pages/register_doctor_page.dart';
import '../../features/patient/presentation/pages/patient_dashboard_page.dart';
import '../../features/patient/presentation/pages/doctor_profile_page.dart';
import '../../features/patient/presentation/pages/patient_history_page.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../features/doctor/presentation/pages/doctor_availability_page.dart';
import '../../features/doctor/presentation/pages/doctor_bookings_page.dart';
import '../../features/doctor/presentation/pages/doctor_earnings_page.dart';
import '../../features/doctor/presentation/pages/doctor_profile_settings_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/chat/presentation/pages/recent_chats_page.dart';
import '../../features/call/presentation/pages/call_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation:
        '/splash', // Will change to splash screen or check auth state
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register-patient',
        builder: (context, state) => const RegisterPatientPage(),
      ),
      GoRoute(
        path: '/register-doctor',
        builder: (context, state) => const RegisterDoctorPage(),
      ),
      GoRoute(
        path:
            '/dashboard', // Will redirect based on role later, default patient dashboard
        builder: (context, state) => const PatientDashboardPage(),
      ),
      GoRoute(
        path: '/doctor-profile/:id',
        builder: (context, state) {
          final doctorId = state.pathParameters['id']!;
          return DoctorProfilePage(doctorId: doctorId);
        },
      ),
      GoRoute(
        path: '/patient-history',
        builder: (context, state) => const PatientHistoryPage(),
      ),
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboardPage(),
      ),
      GoRoute(
        path: '/doctor/slots',
        builder: (context, state) => const DoctorAvailabilityPage(),
      ),
      GoRoute(
        path: '/doctor/bookings',
        builder: (context, state) => const DoctorBookingsPage(),
      ),
      GoRoute(
        path: '/doctor/earnings',
        builder: (context, state) => const DoctorEarningsPage(),
      ),
      GoRoute(
        path: '/doctor/profile',
        builder: (context, state) => const DoctorProfileSettingsPage(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/chat/:userId/:userName',
        builder: (context, state) => ChatPage(
          otherUserId: state.pathParameters['userId']!,
          otherUserName: state.pathParameters['userName']!,
        ),
      ),
      GoRoute(
        path: '/call/:channelName',
        builder: (context, state) => CallPage(
          channelName: state.pathParameters['channelName']!,
          callId: state.uri.queryParameters['callId'],
        ),
      ),
      GoRoute(
        path: '/recent-chats',
        builder: (context, state) => const RecentChatsPage(),
      ),
    ],
  );
}
