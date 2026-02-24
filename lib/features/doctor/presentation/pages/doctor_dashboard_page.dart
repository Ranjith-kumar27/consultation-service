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
import '../../../../core/utils/responsive_config.dart';

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
            padding: EdgeInsets.all(16.rw),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is DoctorLoading) ...[
                  const ShimmerCardLoading(),
                  SizedBox(height: 16.rh),
                  const ShimmerCardLoading(),
                ] else ...[
                  if (!_isApproved) _buildPendingApprovalBanner(),
                  if (!_isApproved) SizedBox(height: 16.rh),
                  _buildAvailabilityCard(),
                ],
                SizedBox(height: 20.rh),
                state is DoctorLoading
                    ? const ShimmerListLoading(itemCount: 4)
                    : _buildStatsGrid(
                        totalEarnings,
                        pendingCount,
                        completedCount,
                      ),
                SizedBox(height: 20.rh),
                _buildRecentBookings(state),
                SizedBox(height: 20.rh),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.inter(
                    fontSize: 20.rt,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.rh),
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
      padding: EdgeInsets.all(16.rw),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning),
          SizedBox(width: 12.rw),
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
                    fontSize: 12.rt,
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
                fontSize: 20.rt,
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
        SizedBox(height: 12.rh),
        if (recentBookings.isEmpty)
          Container(
            padding: EdgeInsets.all(20.rw),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.divider.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(width: 12.rw),
                Text(
                  'No upcoming appointments today',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 14.rt,
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
      margin: EdgeInsets.only(bottom: 12.rh),
      padding: EdgeInsets.all(16.rw),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
            padding: EdgeInsets.all(12.rw),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: AppColors.primary, size: 20.rt),
          ),
          SizedBox(width: 16.rw),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.patientName,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 15.rt,
                  ),
                ),
                SizedBox(height: 2.rh),
                Text(
                  '${DateFormat.jm().format(booking.startTime)} - ${DateFormat.yMMMd().format(booking.startTime)}',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12.rt,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.rw, vertical: 4.rh),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              booking.status.name.toUpperCase(),
              style: GoogleFonts.inter(
                color: AppColors.success,
                fontSize: 10.rt,
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
      padding: EdgeInsets.all(16.rw),
      decoration: BoxDecoration(
        color: _isOnline
            ? AppColors.success.withOpacity(0.1)
            : AppColors.divider.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16.r),
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
            radius: 8.r,
          ),
          SizedBox(width: 12.rw),
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
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.rt,
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
      crossAxisSpacing: 16.rw,
      mainAxisSpacing: 16.rh,
      childAspectRatio: 1.35,
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
      padding: EdgeInsets.all(16.rw),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
            padding: EdgeInsets.all(8.rw),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.rt),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 22.rt,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.rt,
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
        SizedBox(height: 12.rh),
        _buildActionButton(
          'Manage Slots',
          'Edit your availability schedule',
          Icons.access_time,
          () => context.push('/doctor/slots'),
        ),
        SizedBox(height: 12.rh),
        _buildActionButton(
          'Earnings History',
          'View transactions and payouts',
          Icons.payments_outlined,
          () => context.push('/doctor/earnings'),
        ),
        SizedBox(height: 12.rh),
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
      padding: EdgeInsets.only(bottom: 16.rh),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsets.all(16.rw),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
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
                padding: EdgeInsets.all(12.rw),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24.rt),
              ),
              SizedBox(width: 16.rw),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 16.rt,
                      ),
                    ),
                    SizedBox(height: 2.rh),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13.rt,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.rw),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20.rt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
