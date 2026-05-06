import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/models/user_profile.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:provider/provider.dart';

class SessionBookingScreen extends StatefulWidget {
  const SessionBookingScreen({super.key});

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  String? _subject;
  String? _tutorId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.currentUser;

    final List<UserProfile> tutors = _subject == null
      ? []
        : appState.matchTutors(subject: _subject!, availability: _pickedSlot);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session Booking', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (user == null || user.name.trim().isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Please complete your profile first.'),
                ),
              ),
            DropdownButtonFormField<String>(
              initialValue: _subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: appState.availableSubjects
                  .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _subject = value;
                  _tutorId = null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _tutorId,
              decoration: const InputDecoration(
                labelText: 'Tutor',
                border: OutlineInputBorder(),
              ),
              items: tutors
                  .map(
                    (tutor) => DropdownMenuItem(
                      value: tutor.id,
                      child: Text(
                        '${tutor.name} (${tutor.skillLevel.label})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _tutorId = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _selectedDate == null
                          ? 'Pick Date'
                          : DateFormat('dd MMM yyyy').format(_selectedDate!),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 60)),
                        initialDate: _selectedDate ?? now,
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime == null
                        ? 'Pick Time'
                        : _selectedTime!.format(context)),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  if (_subject == null || _tutorId == null) {
                    _showMessage('Please select subject and tutor');
                    return;
                  }
                  if (_selectedDate == null || _selectedTime == null) {
                    _showMessage('Please pick both date and time');
                    return;
                  }

                  final dateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  final error = appState.bookSession(
                    tutorId: _tutorId!,
                    subject: _subject!,
                    dateTime: dateTime,
                  );

                  if (error != null) {
                    _showMessage(error);
                    return;
                  }

                  _showMessage('Session booked successfully');
                },
                child: const Text('Book Session'),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unique Session ID is generated automatically for each booking.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String? get _pickedSlot {
    if (_selectedTime == null) return null;
    final hour = _selectedTime!.hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
