import 'package:flutter/material.dart';
import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:provider/provider.dart';

class TutorMatchingScreen extends StatefulWidget {
  const TutorMatchingScreen({super.key});

  @override
  State<TutorMatchingScreen> createState() => _TutorMatchingScreenState();
}

class _TutorMatchingScreenState extends State<TutorMatchingScreen> {
  String? _selectedSubject;
  String? _selectedSlot;
  SkillLevel? _selectedSkillLevel;
  double _minimumRating = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final subject = _selectedSubject ??
        (appState.currentUser?.subjects.isNotEmpty == true
            ? appState.currentUser!.subjects.first
            : null);

    final matchedTutors = subject == null
        ? const []
        : appState.matchTutors(
            subject: subject,
            availability: _selectedSlot,
            learnerSkill: _selectedSkillLevel,
            minRating: _minimumRating > 0 ? _minimumRating : null,
            search: _searchController.text,
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tutor Matching', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            if (appState.currentUser == null ||
                (appState.currentUser?.name.trim().isEmpty ?? true))
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Complete profile first to get matching tutors.'),
                ),
              ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search by tutor name or subject',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => setState(() {}),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: subject,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
              items: appState.availableSubjects
                  .map((subject) => DropdownMenuItem(value: subject, child: Text(subject)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedSubject = value),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedSlot,
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(value: null, child: Text('Any')),
                      ...appState.availabilitySlots.map(
                        (slot) => DropdownMenuItem(value: slot, child: Text(slot)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedSlot = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<SkillLevel>(
                    initialValue: _selectedSkillLevel,
                    decoration: const InputDecoration(
                      labelText: 'Min Skill',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<SkillLevel>(value: null, child: Text('Auto')),
                      ...SkillLevel.values.map(
                        (level) => DropdownMenuItem(value: level, child: Text(level.label)),
                      ),
                    ],
                    onChanged: (value) => setState(() => _selectedSkillLevel = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Minimum Rating: ${_minimumRating.toStringAsFixed(1)}'),
            Slider(
              value: _minimumRating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) => setState(() => _minimumRating = value),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: matchedTutors.isEmpty
                  ? const Center(child: Text('No tutors found for selected filters.'))
                  : ListView.builder(
                      itemCount: matchedTutors.length,
                      itemBuilder: (context, index) {
                        final tutor = matchedTutors[index];
                        final rating = appState.tutorAverageRatings[tutor.id] ?? 0;
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.school),
                            title: Text(tutor.name),
                            subtitle: Text(
                              '${tutor.subjects.join(', ')}\n'
                              'Skill: ${tutor.skillLevel.label} | '
                              'Available: ${tutor.availability.join(', ')}',
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                Text(rating.toStringAsFixed(1)),
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
