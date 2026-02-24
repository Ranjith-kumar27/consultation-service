import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DoctorProfileSettingsPage extends StatefulWidget {
  const DoctorProfileSettingsPage({super.key});

  @override
  State<DoctorProfileSettingsPage> createState() =>
      _DoctorProfileSettingsPageState();
}

class _DoctorProfileSettingsPageState extends State<DoctorProfileSettingsPage> {
  final _bioController = TextEditingController();
  final _specializationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
  }

  void _loadDoctorInfo() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<DoctorBloc>().add(LoadDoctorInfoEvent(authState.user.uid));
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<DoctorBloc, DoctorState>(
        listener: (context, state) {
          if (state is DoctorInfoLoaded) {
            _bioController.text = state.doctor.bio ?? '';
            _specializationController.text = state.doctor.specialization;
          }
          if (state is DoctorProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
          if (state is DoctorError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _specializationController,
                  decoration: const InputDecoration(
                    labelText: 'Specialization',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is DoctorLoading
                        ? null
                        : () {
                            context.read<DoctorBloc>().add(
                              UpdateDoctorProfileEvent(
                                bio: _bioController.text,
                                specialization: _specializationController.text,
                              ),
                            );
                          },
                    child: state is DoctorLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
