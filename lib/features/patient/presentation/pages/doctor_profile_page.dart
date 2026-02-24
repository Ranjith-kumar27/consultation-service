import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

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
      final timeParts = _selectedSlot!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

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

      context.read<PatientBloc>().add(
        BookAppointmentEvent(
          doctorId: widget.doctorId,
          patientId:
              'patient_dummy_id', // Need to fetch from Auth state instead
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
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DoctorProfileLoaded) {
            final doctor = state.doctor;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColorLight,
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${doctor.uid.substring(0, 5)}', // Name handling
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Text(
                              doctor.specialization,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(doctor.bio ?? 'No biography available.'),

                  const SizedBox(height: 24),
                  const Text(
                    'Book Appointment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        lastDate: DateTime.now().add(const Duration(days: 30)),
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
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              onSelected: (selected) {
                                setState(
                                  () => _selectedSlot = selected ? slot : null,
                                );
                              },
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookAppointment,
                      child: const Text('Confirm Booking'),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Loading profile...'));
        },
      ),
    );
  }
}
