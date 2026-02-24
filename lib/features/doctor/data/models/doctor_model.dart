import '../../domain/entities/doctor_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel extends DoctorEntity {
  const DoctorModel({
    required super.uid,
    required super.specialization,
    super.isApproved,
    super.isOnline,
    super.earnings,
    super.commissionRate,
    super.availableSlots,
    super.bio,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      uid: doc.id,
      specialization: data['specialization'] ?? '',
      isApproved: data['isApproved'] ?? false,
      isOnline: data['isOnline'] ?? false,
      earnings: (data['earnings'] ?? 0.0).toDouble(),
      commissionRate: (data['commissionRate'] ?? 0.15).toDouble(),
      availableSlots: List<String>.from(data['availableSlots'] ?? []),
      bio: data['bio'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'specialization': specialization,
      'isApproved': isApproved,
      'isOnline': isOnline,
      'earnings': earnings,
      'commissionRate': commissionRate,
      'availableSlots': availableSlots,
      'bio': bio,
    };
  }
}
