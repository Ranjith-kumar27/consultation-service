import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_config.dart';

class PatientHistoryPage extends StatefulWidget {
  const PatientHistoryPage({super.key});

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<PatientBloc>().add(
        FetchPatientBookingsEvent(patientId: authState.user.uid),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Appointments')),
      body: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is BookingsLoaded) {
            if (state.bookings.isEmpty) {
              return EmptyState(
                title: 'No Appointments Found',
                message: 'You haven\'t booked any consultations yet.',
                icon: Icons.history_toggle_off,
                onActionPressed: () => context.go('/patient-dashboard'),
                actionLabel: 'Find a Doctor',
              );
            }
            return ListView.builder(
              itemCount: state.bookings.length,
              padding: EdgeInsets.symmetric(horizontal: 20.rw, vertical: 10.rh),
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(20.rw),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Dr. ${booking.doctorName}',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.rt,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.rw,
                                vertical: 6.rh,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  booking.status.name,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: _getStatusColor(
                                    booking.status.name,
                                  ).withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                booking.status.name.toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: _getStatusColor(booking.status.name),
                                  fontSize: 10.rt,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.rh),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.rw),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                size: 16.rt,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 12.rw),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy  •  hh:mm a',
                              ).format(booking.startTime),
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12.rh),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.rw),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                Icons.payments_outlined,
                                size: 16.rt,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 12.rw),
                            Text(
                              '₹${booking.totalAmount.toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.rt,
                              ),
                            ),
                          ],
                        ),
                        if (booking.status == AppointmentStatus.confirmed ||
                            booking.status == AppointmentStatus.completed)
                          Padding(
                            padding: EdgeInsets.only(top: 20.rh),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                        '/chat/${booking.doctorId}/${booking.doctorName}',
                                      );
                                    },
                                    icon: Icon(
                                      Icons.chat_bubble_outline,
                                      size: 18.rt,
                                    ),
                                    label: const Text('Chat'),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.rh,
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12.rw),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      final channelName = [
                                        booking.patientId,
                                        booking.doctorId,
                                      ]..sort();
                                      context.push(
                                        '/call/${channelName.join('_')}',
                                      );
                                    },
                                    icon: Icon(
                                      Icons.videocam_outlined,
                                      size: 20.rt,
                                    ),
                                    label: const Text('Call'),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12.rh,
                                      ),
                                      side: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          16.r,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
