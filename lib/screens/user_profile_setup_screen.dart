import 'package:flutter/material.dart';
import 'package:peer_tutoring_app/models/app_enums.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:provider/provider.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  UserRole _role = UserRole.learner;
  SkillLevel _skillLevel = SkillLevel.beginner;
  final Set<String> _subjects = {};
  final Set<String> _availability = {'Morning'};

  bool _didLoadInitial = false;

  static const List<String> _demoSubjects = [
    'Java',
    'Flutter',
    'Python',
    'Data Structures',
  ];

  static const List<String> _demoAvailability = [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadFromState(AppState appState) {
    if (_didLoadInitial) return;
    final user = appState.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _role = user.role;
      _skillLevel = user.skillLevel;
      _subjects
        ..clear()
        ..addAll(user.subjects);
      _availability
        ..clear()
        ..addAll(user.availability);
    }
    _didLoadInitial = true;
  }

  void _applyDemoExample() {
    setState(() {
      _nameController.text = 'Demo Learner';
      _role = UserRole.both;
      _skillLevel = SkillLevel.intermediate;
      _subjects
        ..clear()
        ..addAll(_demoSubjects);
      _availability
        ..clear()
        ..addAll(_demoAvailability);
    });
  }

  Future<void> _saveProfile(AppState appState) async {
    if (!_formKey.currentState!.validate()) return;
    if (_subjects.isEmpty) {
      _showMessage('Select at least one subject');
      return;
    }
    if (_availability.isEmpty) {
      _showMessage('Select at least one availability slot');
      return;
    }

    await appState.upsertCurrentUserProfile(
      name: _nameController.text.trim(),
      role: _role,
      subjects: _subjects.toList(),
      skillLevel: _skillLevel,
      availability: _availability.toList(),
    );

    if (!mounted) return;
    _showMessage('Profile saved successfully');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _loadFromState(appState);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Profile Setup',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: UserRole.values
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _role = value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<SkillLevel>(
                initialValue: _skillLevel,
                decoration: const InputDecoration(
                  labelText: 'Skill Level',
                  border: OutlineInputBorder(),
                ),
                items: SkillLevel.values
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text(level.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _skillLevel = value);
                },
              ),
              const SizedBox(height: 16),
              Text('Subjects', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: appState.availableSubjects.map((subject) {
                  final selected = _subjects.contains(subject);
                  return FilterChip(
                    label: Text(subject),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _subjects.add(subject);
                        } else {
                          _subjects.remove(subject);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('Availability', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: appState.availabilitySlots.map((slot) {
                  final selected = _availability.contains(slot);
                  return FilterChip(
                    label: Text(slot),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _availability.add(slot);
                        } else {
                          _availability.remove(slot);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _saveProfile(appState),
                  child: const Text('Save Profile'),
                ),
              ),
              const SizedBox(height: 12),
              if (appState.lastSyncMessage != null)
                Text(
                  appState.lastSyncMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
