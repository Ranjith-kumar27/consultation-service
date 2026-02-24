import 'package:flutter/material.dart';
import '../../../../core/widgets/empty_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/widgets/shimmer_loaders.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/responsive_config.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final _searchController = TextEditingController();
  String? _selectedSpecialization;

  final List<String> specializations = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'Neurologist',
    'Pediatrician',
    'Psychiatrist',
    'General Physician',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() {
    context.read<PatientBloc>().add(
      FetchDoctorsEvent(
        query: _searchController.text,
        specialization: _selectedSpecialization == 'All'
            ? null
            : _selectedSpecialization,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Doctor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/patient-history'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            onPressed: () => context.push('/recent-chats'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequestedEvent());
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: EdgeInsets.fromLTRB(20.rw, 10.rh, 20.rw, 20.rh),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for doctors or symptoms...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (_) => _fetchDoctors(),
                  ),
                ),
                SizedBox(height: 20.rh),
                SizedBox(
                  height: 40.rh,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: specializations.length,
                    itemBuilder: (context, index) {
                      final spec = specializations[index];
                      final isSelected =
                          (_selectedSpecialization ?? 'All') == spec;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.rw),
                        child: ChoiceChip(
                          label: Text(spec),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedSpecialization = selected ? spec : 'All';
                            });
                            _fetchDoctors();
                          },
                          backgroundColor: Colors.white,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : AppColors.divider,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // List Section
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientLoading) {
                  return const ShimmerListLoading();
                } else if (state is PatientError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is DoctorsLoaded) {
                  if (state.doctors.isEmpty) {
                    return EmptyState(
                      title: 'No Doctors Found',
                      message:
                          'Try searching with a different name or specialization.',
                      icon: Icons.search_off,
                      onActionPressed: () {
                        _searchController.clear();
                        setState(() => _selectedSpecialization = 'All');
                        _fetchDoctors();
                      },
                      actionLabel: 'Clear Filters',
                    );
                  }
                  return ListView.builder(
                    itemCount: state.doctors.length,
                    padding: EdgeInsets.symmetric(horizontal: 20.rw),
                    itemBuilder: (context, index) {
                      final doctor = state.doctors[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push('/doctor-profile/${doctor.uid}'),
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.rw),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.05,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 35.r,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        backgroundImage: const NetworkImage(
                                          'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 2.rw,
                                      bottom: 2.rh,
                                      child: Container(
                                        width: 14.rw,
                                        height: 14.rh,
                                        decoration: BoxDecoration(
                                          color: doctor.isOnline
                                              ? Colors.green
                                              : Colors.grey,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 20.rw),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dr. ${doctor.name}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      SizedBox(height: 4.rh),
                                      Text(
                                        doctor.specialization,
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 8.rh),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14.rt,
                                            color: AppColors.textSecondary,
                                          ),
                                          SizedBox(width: 4.rw),
                                          Text(
                                            doctor.location ?? 'Online',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.rw),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.chevron_right,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start searching'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
