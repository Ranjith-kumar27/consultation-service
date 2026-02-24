import 'package:equatable/equatable.dart';

enum UserRole { patient, doctor, admin }

class UserEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? fcmToken;
  final String? profileImageUrl;

  final bool isBlocked;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.isBlocked = false,
    this.fcmToken,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    role,
    fcmToken,
    profileImageUrl,
  ];
}
