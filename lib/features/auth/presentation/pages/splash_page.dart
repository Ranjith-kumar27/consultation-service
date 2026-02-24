import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../../../core/utils/responsive_config.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Start auth check is already handled in main.dart via di..add(CheckAuthStatusEvent())
  }

  void _handleNavigation(AuthState state) async {
    // Ensure splash is visible for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (state is Authenticated) {
      final user = state.user;
      if (user.role == UserRole.doctor) {
        context.go('/doctor/dashboard');
      } else if (user.role == UserRole.admin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/dashboard');
      }
    } else if (state is AuthUnauthenticated || state is AuthError) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated ||
            state is AuthUnauthenticated ||
            state is AuthError) {
          _handleNavigation(state);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset('assets/icons/heartbeat.json', width: 250.rw),
              SizedBox(height: 20.rh),
              Text(
                "Doctor",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4.rh),
              Text(
                "Consultation Service",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
