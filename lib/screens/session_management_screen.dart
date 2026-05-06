import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/models/tutoring_session.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:provider/provider.dart';

class SessionManagementScreen extends StatelessWidget {
  const SessionManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Management', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Completed'),
                        Tab(text: 'Cancelled'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _SessionList(
                            sessions: appState.upcomingSessions,
                            emptyMessage: 'No upcoming sessions',
                          ),
                          _SessionList(
                            sessions: appState.completedSessions,
                            emptyMessage: 'No completed sessions',
                          ),
                          _SessionList(
                            sessions: appState.cancelledSessions,
                            emptyMessage: 'No cancelled sessions',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({required this.sessions, required this.emptyMessage});

  final List<TutoringSession> sessions;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();

    if (sessions.isEmpty) {
      return Center(child: Text(emptyMessage));
    }

    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        final tutor = appState.profileById(session.tutorId);
        final dateTime = DateFormat('dd MMM yyyy, hh:mm a').format(session.dateTime);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Session ID: ${session.id}'),
                const SizedBox(height: 4),
                Text('Tutor: ${tutor?.name ?? 'Unknown'}'),
                Text('Subject: ${session.subject}'),
                Text('Date & Time: $dateTime'),
                Text('Status: ${session.status.label}'),
                if (session.status == SessionStatus.scheduled) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          appState.updateSessionStatus(
                            sessionId: session.id,
                            status: SessionStatus.cancelled,
                          );
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () {
                          appState.updateSessionStatus(
                            sessionId: session.id,
                            status: SessionStatus.completed,
                          );
                        },
                        child: const Text('Mark Complete'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
