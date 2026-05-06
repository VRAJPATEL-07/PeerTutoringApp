enum UserRole { tutor, learner, both }

enum SkillLevel { beginner, intermediate, advanced }

enum SessionStatus { scheduled, completed, cancelled }

extension UserRoleLabel on UserRole {
  String get label {
    switch (this) {
      case UserRole.tutor:
        return 'Tutor';
      case UserRole.learner:
        return 'Learner';
      case UserRole.both:
        return 'Both';
    }
  }
}

extension SkillLevelLabel on SkillLevel {
  String get label {
    switch (this) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
    }
  }

  int get weight {
    switch (this) {
      case SkillLevel.beginner:
        return 1;
      case SkillLevel.intermediate:
        return 2;
      case SkillLevel.advanced:
        return 3;
    }
  }
}

extension SessionStatusLabel on SessionStatus {
  String get label {
    switch (this) {
      case SessionStatus.scheduled:
        return 'Scheduled';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }
}
