import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;
  const DoctorProfilePage({super.key, required this.doctorId});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  DateTime? _selectedDate;
  String? _selectedSlot;

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(
      FetchDoctorProfileEvent(doctorId: widget.doctorId),
    );
  }

  void _bookAppointment() {
    if (_selectedDate != null && _selectedSlot != null) {
      // Parse slot time
      final time = DateFormat.jm().parse(_selectedSlot!);
      final hour = time.hour;
      final minute = time.minute;

      final startTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
      );
      final endTime = startTime.add(
        const Duration(minutes: 30),
      ); // 30 min duration

      // Assume patientId is accessible or handled in Bloc, but we need it.
      // For now, let's pass a dummy or get it from AuthBloc.
      // Easiest is to fire event, we'll need to grab patientId somehow. Let's assume auth repo has it.
      // We'll pass empty patientId and let BLoC or UseCase get the current user, or adjust later.

      final authState = context.read<AuthBloc>().state;
      String patientId = '';
      if (authState is Authenticated) {
        patientId = authState.user.uid;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to book an appointment')),
        );
        return;
      }

      context.read<PatientBloc>().add(
        BookAppointmentEvent(
          doctorId: widget.doctorId,
          patientId: patientId,
          startTime: startTime,
          endTime: endTime,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time slot')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: BlocConsumer<PatientBloc, PatientState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Appointment Booked Successfully!')),
            );
            context.go('/patient-history');
          } else if (state is PatientError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientLoading && _selectedDate == null) {
            // Only show full screen loader for initial profile fetch
            return const Center(child: CircularProgressIndicator());
          }

          final doctor = (state is DoctorProfileLoaded)
              ? state.doctor
              : (state is AppointmentBooked)
              ? null // Should have navigated away
              : (context.read<PatientBloc>().state is DoctorProfileLoaded)
              ? (context.read<PatientBloc>().state as DoctorProfileLoaded)
                    .doctor
              : null;

          if (doctor == null) {
            // Fallback if state is lost or we are in a transition state
            return const Center(child: Text('Loading profile...'));
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.grey.shade100),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                backgroundImage: const NetworkImage(
                                  'https://cdn-icons-png.flaticon.com/512/3774/3774299.png', // Medical professional vector
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. ${doctor.name}', // Name handling
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displayMedium,
                                  ),
                                  Text(
                                    doctor.specialization,
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (doctor.location != null)
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          doctor.location!,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Fee: ₹${doctor.consultationFee.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: doctor.isOnline
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        doctor.isOnline
                                            ? 'Available Online'
                                            : 'Currently Offline',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            context.push(
                                              '/chat/${doctor.uid}/${doctor.name}',
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.chat_bubble_outline,
                                            size: 18,
                                          ),
                                          label: const Text('Chat'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            final authState = context
                                                .read<AuthBloc>()
                                                .state;
                                            if (authState is Authenticated) {
                                              final pid = authState.user.uid;
                                              final channelName = [
                                                pid,
                                                doctor.uid,
                                              ]..sort();
                                              context.push(
                                                '/call/${channelName.join('_')}',
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.videocam_outlined,
                                            size: 18,
                                          ),
                                          label: const Text('Call'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(doctor.bio ?? 'No biography available.'),

                    const SizedBox(height: 24),
                    const Text(
                      'Book Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Picker
                    ListTile(
                      title: Text(
                        _selectedDate == null
                            ? 'Select Date'
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 30),
                          ),
                        );
                        if (date != null) {
                          setState(() => _selectedDate = date);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Slot Selection
                    const Text('Available Slots'),
                    const SizedBox(height: 8),
                    doctor.availableSlots.isEmpty
                        ? const Text('No slots available')
                        : Wrap(
                            spacing: 8,
                            children: doctor.availableSlots.map((slot) {
                              final isSelected = _selectedSlot == slot;
                              return ChoiceChip(
                                label: Text(slot),
                                selected: isSelected,
                                selectedColor: Theme.of(context).primaryColor,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                onSelected: (selected) {
                                  setState(
                                    () =>
                                        _selectedSlot = selected ? slot : null,
                                  );
                                },
                              );
                            }).toList(),
                          ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is PatientLoading
                            ? null
                            : _bookAppointment,
                        child: state is PatientLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Confirm Booking'),
                      ),
                    ),
                  ],
                ),
              ),
              if (state is PatientLoading && _selectedDate != null)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
