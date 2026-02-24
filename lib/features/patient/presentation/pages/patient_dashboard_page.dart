import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/patient_bloc.dart';
import '../bloc/patient_event.dart';
import '../bloc/patient_state.dart';

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
            onPressed: () =>
                context.go('/patient-history'), // Not implemented yet
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Not implemented proper logout logic yet in ui, back to login for now
              context.go('/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search doctors...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _fetchDoctors(),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedSpecialization ?? 'All',
                  items: specializations.map((String spec) {
                    return DropdownMenuItem<String>(
                      value: spec,
                      child: Text(spec),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSpecialization = newValue;
                    });
                    _fetchDoctors();
                  },
                ),
              ],
            ),
          ),

          // List Section
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PatientError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is DoctorsLoaded) {
                  if (state.doctors.isEmpty) {
                    return const Center(child: Text('No doctors found.'));
                  }
                  return ListView.builder(
                    itemCount: state.doctors.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final doctor = state.doctors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColorLight,
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            'Dr. ${doctor.uid.substring(0, 5)}...', // Wait, ui lacks doc name since name is in UserEntity. We should probably just display specialization for now or fetch joined data later.
                            // In a real app we'd aggregate UserEntity + DoctorEntity or store name in DoctorEntity. Let's assume name is handled later.
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.specialization,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
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
                                  Text(doctor.isOnline ? 'Online' : 'Offline'),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () =>
                                context.go('/doctor-profile/${doctor.uid}'),
                            child: const Text('Book'),
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
