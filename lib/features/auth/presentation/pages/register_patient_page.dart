import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/custom_text_field.dart';
import '../../../../core/widgets/wave_dot_loader.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_config.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() => _RegisterPatientPageState();
}

class _RegisterPatientPageState extends State<RegisterPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        RegisterPatientEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 30.rw),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 40.rh),
                    Text(
                      'Create Patient Account',
                      style: GoogleFonts.inter(
                        fontSize: 28.rt,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.rh),
                    Text(
                      'Join our healthcare community today',
                      style: GoogleFonts.inter(
                        fontSize: 16.rt,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.rh),
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your name' : null,
                    ),
                    SizedBox(height: 20.rh),
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.isEmpty ? 'Please enter your email' : null,
                    ),
                    SizedBox(height: 20.rh),
                    CustomTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      validator: (v) => v!.length < 6
                          ? 'Password must be at least 6 chars'
                          : null,
                    ),
                    SizedBox(height: 40.rh),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _register,
                      child: state is AuthLoading
                          ? const WaveDotLoader()
                          : const Text('Sign Up'),
                    ),
                    SizedBox(height: 20.rh),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 14.rt,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Login',
                            style: GoogleFonts.inter(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14.rt,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40.rh),
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
