import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/models/tutoring_session.dart';
import 'package:peer_tutoring_app/models/user_profile.dart';
import 'package:peer_tutoring_app/services/local_storage_service.dart';
import 'package:peer_tutoring_app/services/matching_service.dart';
import 'package:peer_tutoring_app/services/sync_service.dart';

class AppState extends ChangeNotifier {
  AppState({
    required LocalStorageService localStorageService,
    required MatchingService matchingService,
    required SyncService syncService,
  })  : _localStorageService = localStorageService,
        _matchingService = matchingService,
        _syncService = syncService;

  final LocalStorageService _localStorageService;
  final MatchingService _matchingService;
  final SyncService _syncService;

  final List<String> availableSubjects = const [
    'Java',
    'DBMS',
    'Flutter',
    'Python',
    'Data Structures',
    'CLoud Computing',
  ];

  final List<String> availabilitySlots = const ['Morning', 'Afternoon', 'Evening'];

  List<UserProfile> _profiles = [];
  List<TutoringSession> _sessions = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _lastSyncMessage;

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get lastSyncMessage => _lastSyncMessage;

  List<UserProfile> get profiles => List.unmodifiable(_profiles);
  List<TutoringSession> get sessions => List.unmodifiable(_sessions);

  UserProfile? get currentUser {
    for (final profile in _profiles) {
      if (profile.isCurrentUser) return profile;
    }
    return null;
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final storedProfiles = _localStorageService.loadProfiles();
    final storedSessions = _localStorageService.loadSessions();

    if (storedProfiles.isEmpty) {
      _profiles = _seedProfiles();
    } else {
      _profiles = storedProfiles;
    }

    _sessions = storedSessions;

    await _persistAll();
    _isLoading = false;
    notifyListeners();

    await syncIfOnline();
  }

  Future<void> upsertCurrentUserProfile({
    required String name,
    required UserRole role,
    required List<String> subjects,
    required SkillLevel skillLevel,
    required List<String> availability,
  }) async {
    final existing = currentUser;
    if (existing == null) {
      _profiles.add(
        UserProfile(
          id: _createId('USR'),
          name: name,
          role: role,
          subjects: subjects,
          skillLevel: skillLevel,
          availability: availability,
          isCurrentUser: true,
        ),
      );
    } else {
      final index = _profiles.indexWhere((profile) => profile.id == existing.id);
      _profiles[index] = UserProfile(
        id: existing.id,
        name: name,
        role: role,
        subjects: subjects,
        skillLevel: skillLevel,
        availability: availability,
        isCurrentUser: true,
      );
    }

    await _persistAll();
    notifyListeners();
  }

  List<UserProfile> matchTutors({
    required String subject,
    String? availability,
    SkillLevel? learnerSkill,
    double? minRating,
    String? search,
  }) {
    final learner = currentUser;
    if (learner == null) return [];

    var list = _matchingService.findTutors(
      learner: learner,
      allProfiles: _profiles,
      subject: subject,
      availability: availability,
      minimumSkill: learnerSkill,
      minimumRating: minRating,
      tutorRatings: tutorAverageRatings,
    );

    final query = search?.trim().toLowerCase() ?? '';
    if (query.isNotEmpty) {
      list = list.where((profile) {
        return profile.name.toLowerCase().contains(query) ||
            profile.subjects.any((subj) => subj.toLowerCase().contains(query));
      }).toList();
    }

    return list;
  }

  Map<String, double> get tutorAverageRatings {
    final Map<String, List<int>> ratings = {};
    for (final session in _sessions) {
      if (session.rating != null) {
        ratings.putIfAbsent(session.tutorId, () => []).add(session.rating!);
      }
    }

    final Map<String, double> result = {};
    ratings.forEach((tutorId, values) {
      final total = values.fold<int>(0, (sum, value) => sum + value);
      result[tutorId] = total / values.length;
    });

    return result;
  }

  bool hasBookingConflict({required String tutorId, required DateTime dateTime}) {
    for (final session in _sessions) {
      if (session.status == SessionStatus.cancelled) continue;
      final isSameTutor = session.tutorId == tutorId;
      final isSameTime = session.dateTime.isAtSameMomentAs(dateTime);
      if (isSameTutor && isSameTime) {
        return true;
      }
    }
    return false;
  }

  String? bookSession({
    required String tutorId,
    required String subject,
    required DateTime dateTime,
  }) {
    final learner = currentUser;
    if (learner == null) {
      return 'Please complete your profile before booking.';
    }

    if (dateTime.isBefore(DateTime.now())) {
      return 'Session time must be in the future.';
    }

    if (hasBookingConflict(tutorId: tutorId, dateTime: dateTime)) {
      return 'This tutor already has a session at the selected time.';
    }

    final slot = _matchingService.slotFromDateTime(dateTime);
    final tutor = _profiles.where((profile) => profile.id == tutorId).firstOrNull;

    if (tutor == null) {
      return 'Tutor not found.';
    }

    if (!tutor.availability.contains(slot)) {
      return 'Tutor is not available in the selected slot.';
    }

    _sessions.add(
      TutoringSession(
        id: _createId('SES'),
        tutorId: tutorId,
        learnerId: learner.id,
        subject: subject,
        dateTime: dateTime,
        status: SessionStatus.scheduled,
      ),
    );

    _persistAll();
    notifyListeners();
    syncIfOnline();

    return null;
  }

  Future<void> updateSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return;

    _sessions[index] = _sessions[index].copyWith(status: status, isSynced: false);
    await _persistAll();
    notifyListeners();
    await syncIfOnline();
  }

  Future<void> submitFeedback({
    required String sessionId,
    required int rating,
    required String feedback,
  }) async {
    final index = _sessions.indexWhere((session) => session.id == sessionId);
    if (index == -1) return;

    _sessions[index] = _sessions[index].copyWith(
      status: SessionStatus.completed,
      rating: rating,
      feedback: feedback.trim().isEmpty ? null : feedback.trim(),
      isSynced: false,
    );

    await _persistAll();
    notifyListeners();
    await syncIfOnline();
  }

  List<TutoringSession> get upcomingSessions {
    final now = DateTime.now();
    return _sessions
        .where((session) =>
            session.status == SessionStatus.scheduled && session.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<TutoringSession> get completedSessions {
    return _sessions
        .where((session) => session.status == SessionStatus.completed)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  List<TutoringSession> get cancelledSessions {
    return _sessions
        .where((session) => session.status == SessionStatus.cancelled)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  UserProfile? profileById(String id) {
    for (final profile in _profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  Future<void> syncIfOnline() async {
    final connectivity = await Connectivity().checkConnectivity();
    final hasInternet = connectivity.any((result) => result != ConnectivityResult.none);

    if (!hasInternet) {
      _lastSyncMessage = 'Offline mode: Changes saved locally.';
      notifyListeners();
      return;
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final success = await _syncService.sync(profiles: _profiles, sessions: _sessions);
      if (success) {
        _sessions = _sessions
            .map((session) => session.copyWith(isSynced: true))
            .toList(growable: true);
        await _persistAll();
        _lastSyncMessage = 'Sync successful.';
      } else {
        _lastSyncMessage = 'Sync failed: server rejected request.';
      }
    } catch (_) {
      _lastSyncMessage = 'Sync skipped: backend unavailable.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _persistAll() async {
    await _localStorageService.saveProfiles(_profiles);
    await _localStorageService.saveSessions(_sessions);
  }

  List<UserProfile> _seedProfiles() {
    return [
      UserProfile(
        id: 'USR_SELF',
        name: '',
        role: UserRole.learner,
        subjects: const [],
        skillLevel: SkillLevel.beginner,
        availability: const ['Morning'],
        isCurrentUser: true,
      ),
      UserProfile(
        id: 'USR_T1',
        name: 'Aarav Patel',
        role: UserRole.tutor,
        subjects: const ['Java', 'DBMS'],
        skillLevel: SkillLevel.advanced,
        availability: const ['Morning', 'Evening'],
      ),
      UserProfile(
        id: 'USR_T2',
        name: 'Meera Shah',
        role: UserRole.both,
        subjects: const ['Flutter', 'Python'],
        skillLevel: SkillLevel.advanced,
        availability: const ['Afternoon', 'Evening'],
      ),
      UserProfile(
        id: 'USR_T3',
        name: 'Dev Trivedi',
        role: UserRole.tutor,
        subjects: const ['Data Structures', 'Java'],
        skillLevel: SkillLevel.intermediate,
        availability: const ['Morning', 'Afternoon'],
      ),
    ];
  }

  String _createId(String prefix) {
    final random = Random();
    final value = random.nextInt(900000) + 100000;
    return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$value';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
