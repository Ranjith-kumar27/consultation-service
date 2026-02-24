import 'package:equatable/equatable.dart';

class DoctorEntity extends Equatable {
  final String uid; // Relates to UserEntity's uid
  final String name; // Name from UserEntity
  final String specialization;
  final bool isApproved;
  final bool isOnline;
  final double earnings;
  final double commissionRate;
  final List<String> availableSlots; // e.g., ["09:00", "10:00"]
  final String? bio;
  final String? location; // District/City in Tamil Nadu
  final double consultationFee; // Fee in Rupees

  const DoctorEntity({
    required this.uid,
    required this.name,
    required this.specialization,
    this.isApproved = false,
    this.isOnline = false,
    this.earnings = 0.0,
    this.commissionRate = 0.15, // 15% default platform commission
    this.availableSlots = const [],
    this.bio,
    this.location,
    this.consultationFee = 0.0,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    specialization,
    isApproved,
    isOnline,
    earnings,
    commissionRate,
    availableSlots,
    bio,
    location,
    consultationFee,
  ];
}
