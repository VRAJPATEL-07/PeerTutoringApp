import 'package:peer_tutoring_app/models/app_enums.dart';

class UserProfile {
  UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.subjects,
    required this.skillLevel,
    required this.availability,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final UserRole role;
  final List<String> subjects;
  final SkillLevel skillLevel;
  final List<String> availability;
  final bool isCurrentUser;

  bool get canTutor => role == UserRole.tutor || role == UserRole.both;

  bool get canLearn => role == UserRole.learner || role == UserRole.both;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'subjects': subjects,
      'skillLevel': skillLevel.name,
      'availability': availability,
      'isCurrentUser': isCurrentUser,
    };
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (value) => value.name == map['role'],
        orElse: () => UserRole.learner,
      ),
      subjects: List<String>.from(map['subjects'] ?? const []),
      skillLevel: SkillLevel.values.firstWhere(
        (value) => value.name == map['skillLevel'],
        orElse: () => SkillLevel.beginner,
      ),
      availability: List<String>.from(map['availability'] ?? const []),
      isCurrentUser: map['isCurrentUser'] as bool? ?? false,
    );
  }
}
