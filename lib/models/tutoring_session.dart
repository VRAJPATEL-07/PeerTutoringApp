import 'package:peer_tutoring_app/models/app_enums.dart';

class TutoringSession {
  TutoringSession({
    required this.id,
    required this.tutorId,
    required this.learnerId,
    required this.subject,
    required this.dateTime,
    required this.status,
    this.rating,
    this.feedback,
    this.isSynced = false,
  });

  final String id;
  final String tutorId;
  final String learnerId;
  final String subject;
  final DateTime dateTime;
  final SessionStatus status;
  final int? rating;
  final String? feedback;
  final bool isSynced;

  TutoringSession copyWith({
    String? id,
    String? tutorId,
    String? learnerId,
    String? subject,
    DateTime? dateTime,
    SessionStatus? status,
    int? rating,
    String? feedback,
    bool? isSynced,
    bool clearFeedback = false,
  }) {
    return TutoringSession(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      learnerId: learnerId ?? this.learnerId,
      subject: subject ?? this.subject,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorId': tutorId,
      'learnerId': learnerId,
      'subject': subject,
      'dateTime': dateTime.toIso8601String(),
      'status': status.name,
      'rating': rating,
      'feedback': feedback,
      'isSynced': isSynced,
    };
  }

  factory TutoringSession.fromMap(Map<dynamic, dynamic> map) {
    return TutoringSession(
      id: map['id'] as String,
      tutorId: map['tutorId'] as String,
      learnerId: map['learnerId'] as String,
      subject: map['subject'] as String,
      dateTime: DateTime.tryParse(map['dateTime'] as String? ?? '') ?? DateTime.now(),
      status: SessionStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => SessionStatus.scheduled,
      ),
      rating: map['rating'] as int?,
      feedback: map['feedback'] as String?,
      isSynced: map['isSynced'] as bool? ?? false,
    );
  }
}
