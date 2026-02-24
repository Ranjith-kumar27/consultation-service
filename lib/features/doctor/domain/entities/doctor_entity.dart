import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final String uid; // Relates to UserEntity's uid
  final String specialization;
  final bool isApproved;
  final bool isOnline;
  final double earnings;
  final double commissionRate;
  final List<String> availableSlots; // e.g., ["09:00", "10:00"]
  final String? bio;

  const DoctorEntity({
    required this.uid,
    required this.specialization,
    this.isApproved = false,
    this.isOnline = false,
    this.earnings = 0.0,
    this.commissionRate = 0.15, // 15% default platform commission
    this.availableSlots = const [],
    this.bio,
  });

  @override
  List<Object?> get props => [
    uid,
    specialization,
    isApproved,
    isOnline,
    earnings,
    commissionRate,
    availableSlots,
    bio,
  ];
}
