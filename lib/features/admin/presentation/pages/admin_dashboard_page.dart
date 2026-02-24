import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

import '../../../patient/domain/entities/appointment_entity.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<AdminBloc>().add(LoadPendingDoctorsEvent());
    context.read<AdminBloc>().add(LoadAllBookingsEvent());
    context.read<AdminBloc>().add(LoadTotalTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Approvals', icon: Icon(Icons.how_to_reg)),
              Tab(text: 'Bookings', icon: Icon(Icons.event_note)),
              Tab(text: 'Financials', icon: Icon(Icons.insights)),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is DoctorApproved) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Doctor approved successfully')),
              );
              context.read<AdminBloc>().add(LoadPendingDoctorsEvent());
            }
          },
          builder: (context, state) {
            return TabBarView(
              children: [
                _buildApprovalsTab(state),
                _buildBookingsTab(state),
                _buildFinancialsTab(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildApprovalsTab(AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is PendingDoctorsLoaded) {
      if (state.doctors.isEmpty) {
        return const Center(child: Text('No pending approvals.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.doctors.length,
        itemBuilder: (context, index) {
          final doctor = state.doctors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(doctor.uid), // Replace with doctor name if available
              subtitle: Text(doctor.specialization),
              trailing: ElevatedButton(
                onPressed: () {
                  context.read<AdminBloc>().add(ApproveDoctorEvent(doctor.uid));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Approve'),
              ),
            ),
          );
        },
      );
    }
    return const Center(child: Text('Load pending doctors to view.'));
  }

  Widget _buildBookingsTab(AdminState state) {
    if (state is AllBookingsLoaded) {
      if (state.bookings.isEmpty) {
        return const Center(child: Text('No bookings found.'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.bookings.length,
        itemBuilder: (context, index) {
          final booking = state.bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Booking ID: ${booking.id.substring(0, 8)}'),
              subtitle: Text(
                'Status: ${booking.status.name} | Amount: \$${booking.totalAmount}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Icon(
                _getStatusIcon(booking.status),
                color: _getStatusColor(booking.status),
              ),
            ),
          );
        },
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildFinancialsTab(AdminState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildMetricCard(
            'Global Revenue',
            state is TotalTransactionsLoaded
                ? '\$${state.amount.toStringAsFixed(2)}'
                : 'Loading...',
            Icons.account_balance_wallet,
            AppColors.primary,
          ),
          const SizedBox(height: 20),
          _buildMetricCard(
            'Total Platform Commission',
            state is TotalTransactionsLoaded
                ? '\$${(state.amount * 0.15).toStringAsFixed(2)}'
                : 'Loading...',
            Icons.percent,
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return Icons.timer;
      case AppointmentStatus.confirmed:
        return Icons.check_circle;
      case AppointmentStatus.completed:
        return Icons.verified;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.rejected:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.confirmed:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
      case AppointmentStatus.rejected:
        return AppColors.error;
    }
  }
}
