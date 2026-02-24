import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../../../../core/widgets/wave_dot_loader.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginRequestedEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            print('LoginPage: Authenticated as ${state.user.role}');
            if (state.user.role == UserRole.doctor) {
              context.go('/doctor/dashboard');
            } else if (state.user.role == UserRole.admin) {
              context.go('/admin/dashboard');
            } else {
              context.go('/dashboard');
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Lottie.asset(
                        'assets/icons/heartbeat.json',
                        // height: 200,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Lottie.asset(
                        'assets/icons/welcome.json',
                        height: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sign in to continue to Doctor Consultation',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (value) =>
                          value!.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _login,
                      child: state is AuthLoading
                          ? const WaveDotLoader()
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () => context.push('/register-patient'),
                          child: const Text('Register Here'),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.push('/register-doctor'),
                      child: const Text('Register as a Doctor'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
