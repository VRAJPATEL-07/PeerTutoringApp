import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:provider/provider.dart';

class FeedbackRatingScreen extends StatefulWidget {
  const FeedbackRatingScreen({super.key});

  @override
  State<FeedbackRatingScreen> createState() => _FeedbackRatingScreenState();
}

class _FeedbackRatingScreenState extends State<FeedbackRatingScreen> {
  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final sessions = appState.completedSessions;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Feedback & Rating', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 10),
            Expanded(
              child: sessions.isEmpty
                  ? const Center(child: Text('No completed sessions available for feedback.'))
                  : ListView.builder(
                      itemCount: sessions.length,
                      itemBuilder: (context, index) {
                        final session = sessions[index];
                        final tutor = appState.profileById(session.tutorId);
                        final currentRating = _ratings[session.id] ?? session.rating ?? 3;
                        final controller = _controllers.putIfAbsent(
                          session.id,
                          () => TextEditingController(text: session.feedback ?? ''),
                        );

                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Session: ${session.id}'),
                                Text('Tutor: ${tutor?.name ?? 'Unknown'}'),
                                Text('Subject: ${session.subject}'),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(session.dateTime),
                                ),
                                const SizedBox(height: 8),
                                Text('Rating: $currentRating'),
                                Slider(
                                  value: currentRating.toDouble(),
                                  min: 1,
                                  max: 5,
                                  divisions: 4,
                                  label: currentRating.toString(),
                                  onChanged: (value) {
                                    setState(() {
                                      _ratings[session.id] = value.round();
                                    });
                                  },
                                ),
                                TextField(
                                  controller: controller,
                                  minLines: 2,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                    labelText: 'Feedback comment',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FilledButton(
                                    onPressed: () async {
                                      await appState.submitFeedback(
                                        sessionId: session.id,
                                        rating: _ratings[session.id] ?? session.rating ?? 3,
                                        feedback: controller.text,
                                      );
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Feedback saved')),
                                      );
                                    },
                                    child: const Text('Submit Feedback'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
