import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/models/user_profile.dart';

class MatchingService {
  List<UserProfile> findTutors({
    required UserProfile learner,
    required List<UserProfile> allProfiles,
    required String subject,
    String? availability,
    SkillLevel? minimumSkill,
    double? minimumRating,
    Map<String, double>? tutorRatings,
  }) {
    return allProfiles.where((profile) {
      if (profile.id == learner.id) return false;
      if (!profile.canTutor) return false;
      if (!profile.subjects.contains(subject)) return false;

      final requiredSkill = minimumSkill ?? learner.skillLevel;
      if (profile.skillLevel.weight < requiredSkill.weight) return false;

      if (availability != null && availability.isNotEmpty) {
        if (!profile.availability.contains(availability)) return false;
      }

      if (minimumRating != null && minimumRating > 0) {
        final rating = tutorRatings?[profile.id] ?? 0;
        if (rating < minimumRating) return false;
      }

      return true;
    }).toList();
  }

  String slotFromDateTime(DateTime dateTime) {
    final hour = dateTime.hour;
    if (hour < 12) {
      return 'Morning';
    }
    if (hour < 17) {
      return 'Afternoon';
    }
    return 'Evening';
  }
}
