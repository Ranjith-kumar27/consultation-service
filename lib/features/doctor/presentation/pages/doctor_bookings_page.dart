import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/responsive_config.dart';

class DoctorBookingsPage extends StatefulWidget {
  const DoctorBookingsPage({super.key});

  @override
  State<DoctorBookingsPage> createState() => _DoctorBookingsPageState();
}

class _DoctorBookingsPageState extends State<DoctorBookingsPage> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<DoctorBloc>().add(LoadDoctorBookingsEvent(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DoctorBookingsLoaded) {
            if (state.bookings.isEmpty) {
              return EmptyState(
                title: 'No Bookings Found',
                message: 'You don\'t have any appointments booked yet.',
                icon: Icons.calendar_today_outlined,
                onActionPressed: () {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid != null) {
                    context.read<DoctorBloc>().add(
                      LoadDoctorBookingsEvent(uid),
                    );
                  }
                },
                actionLabel: 'Refresh',
              );
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.rw),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return _buildBookingCard(booking);
              },
            );
          }
          if (state is DoctorError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('Something went wrong.'));
        },
      ),
    );
  }

  Widget _buildBookingCard(AppointmentEntity booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.rh),
      padding: EdgeInsets.all(16.rw),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.patientName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.rt,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          SizedBox(height: 8.rh),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16.rt,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8.rw),
              Text(
                '${booking.startTime.hour}:${booking.startTime.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 16.rh),
          if (booking.status == AppointmentStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<DoctorBloc>().add(
                        UpdateBookingStatusEvent(
                          booking.id,
                          AppointmentStatus.cancelled,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 12.rw),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<DoctorBloc>().add(
                        UpdateBookingStatusEvent(
                          booking.id,
                          AppointmentStatus.confirmed,
                        ),
                      );
                    },
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          if (booking.status == AppointmentStatus.confirmed ||
              booking.status == AppointmentStatus.completed)
            Padding(
              padding: EdgeInsets.only(top: 12.rh),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/chat/${booking.patientId}/${booking.patientName}',
                        );
                      },
                      icon: Icon(Icons.chat_bubble_outline, size: 18.rt),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.rw),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final channelName = [
                          booking.doctorId,
                          booking.patientId,
                        ]..sort();
                        context.push('/call/${channelName.join('_')}');
                      },
                      icon: Icon(Icons.videocam_outlined, size: 18.rt),
                      label: const Text('Call'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color color;
    switch (status) {
      case AppointmentStatus.pending:
        color = AppColors.warning;
        break;
      case AppointmentStatus.confirmed:
        color = AppColors.primary;
        break;
      case AppointmentStatus.completed:
        color = AppColors.success;
        break;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.rejected:
        color = AppColors.error;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.rw, vertical: 4.rh),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.rt,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
