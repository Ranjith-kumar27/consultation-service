import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';

import '../../../patient/domain/entities/appointment_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

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
    context.read<AdminBloc>().add(LoadAllUsersEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Console'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequestedEvent());
                context.go('/login');
              },
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Approvals', icon: Icon(Icons.how_to_reg)),
              Tab(text: 'Users', icon: Icon(Icons.people)),
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
                _buildUsersTab(state),
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
              title: Text(doctor.name),
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
              title: Text(
                'Dr. ${booking.doctorName} | Patient: ${booking.patientName}',
              ),
              subtitle: Text(
                'Status: ${booking.status.name} | Amount: ₹${booking.totalAmount}',
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
    List<AppointmentEntity> bookings = [];
    if (state is AllBookingsLoaded) {
      bookings = state.bookings;
    } else if (context.read<AdminBloc>().state is AllBookingsLoaded) {
      bookings =
          (context.read<AdminBloc>().state as AllBookingsLoaded).bookings;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricCard(
            'Global Revenue',
            state is TotalTransactionsLoaded
                ? '₹${state.amount.toStringAsFixed(2)}'
                : 'Loading...',
            Icons.account_balance_wallet,
            AppColors.primary,
          ),
          const SizedBox(height: 20),
          _buildMetricCard(
            'Total Platform Commission (15%)',
            state is TotalTransactionsLoaded
                ? '₹${(state.amount * 0.15).toStringAsFixed(2)}'
                : 'Loading...',
            Icons.percent,
            AppColors.success,
          ),
          const SizedBox(height: 32),
          const Text(
            'Recent Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (bookings.isEmpty)
            const EmptyState(
              title: 'No Transactions',
              message: 'There is no transaction history available yet.',
              icon: Icons.receipt_long_outlined,
            )
          else
            ...bookings
                .take(10)
                .map((booking) => _buildTransactionItem(booking)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(AppointmentEntity booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dr. ${booking.doctorName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Patient: ${booking.patientName}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${booking.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Comm: ₹${(booking.totalAmount * 0.15).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 10, color: AppColors.success),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(AdminState state) {
    if (state is AdminLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AllUsersLoaded) {
      if (state.users.isEmpty) {
        return const EmptyState(
          title: 'No Users Found',
          message: 'There are no registered patients or doctors yet.',
          icon: Icons.people_outline,
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.users.length,
        itemBuilder: (context, index) {
          final user = state.users[index];
          if (user.role == UserRole.admin) return const SizedBox.shrink();
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: user.role == UserRole.doctor
                    ? AppColors.primary
                    : AppColors.primaryLight,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(user.name),
              subtitle: Text('${user.role.name.toUpperCase()} | ${user.email}'),
              trailing: Switch(
                value: !user.isBlocked,
                activeColor: AppColors.success,
                inactiveThumbColor: AppColors.error,
                onChanged: (value) {
                  context.read<AdminBloc>().add(
                    BlockUserEvent(user.uid, !value),
                  );
                },
              ),
            ),
          );
        },
      );
    }
    return const Center(child: Text('Load users to manage.'));
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
