import 'package:flutter/material.dart';
import 'package:peer_tutoring_app/providers/app_state.dart';
import 'package:peer_tutoring_app/screens/home_shell.dart';
import 'package:peer_tutoring_app/services/local_storage_service.dart';
import 'package:peer_tutoring_app/services/matching_service.dart';
import 'package:peer_tutoring_app/services/sync_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorage = LocalStorageService();
  await localStorage.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(
        localStorageService: localStorage,
        matchingService: MatchingService(),
        syncService: SyncService(baseUrl: 'http://localhost:4000'),
      )..initialize(),
      child: const PeerTutoringApp(),
    ),
  );
}

class PeerTutoringApp extends StatelessWidget {
  const PeerTutoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Peer Tutoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E7490)),
        scaffoldBackgroundColor: const Color(0xFFF4F8FA),
      ),
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const HomeShell();
        },
      ),
    );
  }
}
