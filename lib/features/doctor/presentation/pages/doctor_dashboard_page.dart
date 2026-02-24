import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/doctor_bloc.dart';
import '../bloc/doctor_event.dart';
import '../bloc/doctor_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../patient/domain/entities/appointment_entity.dart';
import '../../../../core/widgets/shimmer_loaders.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  bool _isOnline = false;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final docId = authState.user.uid;
      context.read<DoctorBloc>().add(LoadDoctorInfoEvent(docId));
      context.read<DoctorBloc>().add(LoadDoctorBookingsEvent(docId));
      context.read<DoctorBloc>().add(LoadEarningsSummaryEvent(docId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigation to earnings
              context.push('/doctor/earnings');
            },
            icon: const Icon(Icons.wallet),
          ),
          IconButton(
            onPressed: () => context.push('/recent-chats'),
            icon: const Icon(Icons.chat_outlined),
          ),
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
          if (state is DoctorError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is DoctorAvailabilityUpdated) {
            setState(() {
              _isOnline = state.isOnline;
            });
          }
          if (state is DoctorInfoLoaded) {
            setState(() {
              _isOnline = state.doctor.isOnline;
              _isApproved = state.doctor.isApproved;
            });
          }
        },
        builder: (context, state) {
          double totalEarnings = 0;
          int pendingCount = 0;
          int completedCount = 0;

          if (state is DoctorEarningsLoaded) {
            totalEarnings = state.earnings;
          } else if (context.read<DoctorBloc>().state is DoctorEarningsLoaded) {
            totalEarnings =
                (context.read<DoctorBloc>().state as DoctorEarningsLoaded)
                    .earnings;
          }

          if (state is DoctorBookingsLoaded) {
            pendingCount = state.bookings
                .where((b) => b.status == AppointmentStatus.pending)
                .length;
            completedCount = state.bookings
                .where((b) => b.status == AppointmentStatus.completed)
                .length;
          } else if (context.read<DoctorBloc>().state is DoctorBookingsLoaded) {
            final bookings =
                (context.read<DoctorBloc>().state as DoctorBookingsLoaded)
                    .bookings;
            pendingCount = bookings
                .where((b) => b.status == AppointmentStatus.pending)
                .length;
            completedCount = bookings
                .where((b) => b.status == AppointmentStatus.completed)
                .length;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is DoctorLoading) ...[
                  const ShimmerCardLoading(),
                  const SizedBox(height: 16),
                  const ShimmerCardLoading(),
                ] else ...[
                  if (!_isApproved) _buildPendingApprovalBanner(),
                  if (!_isApproved) const SizedBox(height: 16),
                  _buildAvailabilityCard(),
                ],
                const SizedBox(height: 20),
                state is DoctorLoading
                    ? const ShimmerListLoading(itemCount: 4)
                    : _buildStatsGrid(
                        totalEarnings,
                        pendingCount,
                        completedCount,
                      ),
                const SizedBox(height: 20),
                _buildRecentBookings(state),
                const SizedBox(height: 20),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPendingApprovalBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Approval Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'You will appear in search results once an admin approves your profile.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings(DoctorState state) {
    List<AppointmentEntity> recentBookings = [];
    if (state is DoctorBookingsLoaded) {
      recentBookings = state.bookings.take(3).toList();
    } else if (context.read<DoctorBloc>().state is DoctorBookingsLoaded) {
      recentBookings =
          (context.read<DoctorBloc>().state as DoctorBookingsLoaded).bookings
              .take(3)
              .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Appointments',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (recentBookings.isNotEmpty)
              TextButton(
                onPressed: () => context.push('/doctor/bookings'),
                child: Text(
                  'See All',
                  style: GoogleFonts.inter(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (recentBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(width: 12),
                Text(
                  'No upcoming appointments today',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentBookings.map((booking) => _buildBookingCard(booking)),
      ],
    );
  }

  Widget _buildBookingCard(AppointmentEntity booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.patientName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${DateFormat.jm().format(booking.startTime)} - ${DateFormat.yMMMd().format(booking.startTime)}',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              booking.status.name.toUpperCase(),
              style: GoogleFonts.inter(
                color: AppColors.success,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isOnline
            ? AppColors.success.withOpacity(0.1)
            : AppColors.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isOnline ? AppColors.success : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _isOnline
                ? AppColors.success
                : AppColors.textSecondary,
            radius: 8,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isOnline
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isOnline
                      ? 'Active for consultations'
                      : 'Not accepting consultations',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isOnline,
            onChanged: (value) {
              context.read<DoctorBloc>().add(ToggleAvailabilityEvent(value));
            },
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(double earnings, int pending, int completed) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Earnings',
          '₹${earnings.toStringAsFixed(0)}',
          Icons.currency_rupee,
          AppColors.success,
        ),
        _buildStatCard(
          'Pending',
          pending.toString(),
          Icons.pending_actions,
          AppColors.warning,
        ),
        _buildStatCard(
          'Completed',
          completed.toString(),
          Icons.check_circle_outline,
          AppColors.primary,
        ),
        _buildStatCard('Ratings', '4.8', Icons.star_border, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          'Manage Bookings',
          'View and accept appointments',
          Icons.calendar_month,
          () => context.push('/doctor/bookings'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Manage Slots',
          'Edit your availability schedule',
          Icons.access_time,
          () => context.push('/doctor/slots'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Earnings History',
          'View transactions and payouts',
          Icons.payments_outlined,
          () => context.push('/doctor/earnings'),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          'Profile Settings',
          'Update your bio and price',
          Icons.person_outline,
          () => context.push('/doctor/profile'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
