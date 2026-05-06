import 'package:hive_flutter/hive_flutter.dart';
import 'package:peer_tutoring_app/models/tutoring_session.dart';
import 'package:peer_tutoring_app/models/user_profile.dart';

class LocalStorageService {
  static const String _profilesBox = 'profiles_box';
  static const String _sessionsBox = 'sessions_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_profilesBox);
    await Hive.openBox(_sessionsBox);
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    final box = Hive.box(_profilesBox);
    final data = profiles.map((profile) => profile.toMap()).toList();
    await box.put('profiles', data);
  }

  List<UserProfile> loadProfiles() {
    final box = Hive.box(_profilesBox);
    final dynamic data = box.get('profiles', defaultValue: <Map<dynamic, dynamic>>[]);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((map) => UserProfile.fromMap(Map<dynamic, dynamic>.from(map)))
        .toList();
  }

  Future<void> saveSessions(List<TutoringSession> sessions) async {
    final box = Hive.box(_sessionsBox);
    final data = sessions.map((session) => session.toMap()).toList();
    await box.put('sessions', data);
  }

  List<TutoringSession> loadSessions() {
    final box = Hive.box(_sessionsBox);
    final dynamic data = box.get('sessions', defaultValue: <Map<dynamic, dynamic>>[]);
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((map) => TutoringSession.fromMap(Map<dynamic, dynamic>.from(map)))
        .toList();
  }
}
