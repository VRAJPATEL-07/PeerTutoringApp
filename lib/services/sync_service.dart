import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:peer_tutoring_app/models/tutoring_session.dart';
import 'package:peer_tutoring_app/models/user_profile.dart';

class SyncService {
  SyncService({required this.baseUrl});

  final String baseUrl;

  Future<bool> sync({
    required List<UserProfile> profiles,
    required List<TutoringSession> sessions,
  }) async {
    final uri = Uri.parse('$baseUrl/api/sync');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'profiles': profiles.map((profile) => profile.toMap()).toList(),
        'sessions': sessions.map((session) => session.toMap()).toList(),
      }),
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }
}
