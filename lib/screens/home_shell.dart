import 'package:flutter/material.dart';
import 'package:peer_tutoring_app/screens/feedback_rating_screen.dart';
import 'package:peer_tutoring_app/screens/session_booking_screen.dart';
import 'package:peer_tutoring_app/screens/session_management_screen.dart';
import 'package:peer_tutoring_app/screens/tutor_matching_screen.dart';
import 'package:peer_tutoring_app/screens/user_profile_setup_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    UserProfileSetupScreen(),
    TutorMatchingScreen(),
    SessionBookingScreen(),
    SessionManagementScreen(),
    FeedbackRatingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Match'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Book'),
          NavigationDestination(icon: Icon(Icons.track_changes), label: 'Sessions'),
          NavigationDestination(icon: Icon(Icons.star_outline), label: 'Feedback'),
        ],
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
