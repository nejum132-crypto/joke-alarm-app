import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'providers.dart';
import 'screens/home_screen.dart';
import 'services/joke_repository.dart';
import 'services/notification_service.dart';
import 'widgets/loading_character.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const JokeAlarmApp());
}

final _theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD98E4A)),
  scaffoldBackgroundColor: const Color(0xFFFFF6EC),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFF6EC),
    foregroundColor: Color(0xFF4A3222),
    elevation: 0,
  ),
);

class JokeAlarmApp extends StatefulWidget {
  const JokeAlarmApp({super.key});

  @override
  State<JokeAlarmApp> createState() => _JokeAlarmAppState();
}

class _JokeAlarmAppState extends State<JokeAlarmApp> {
  JokeRepository? _repository;
  NotificationService? _notificationService;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repository = JokeRepository();
    await repository.init();

    final notificationService = NotificationService(repository);
    await notificationService.init();
    await notificationService.requestPermissions();

    setState(() {
      _repository = repository;
      _notificationService = notificationService;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = _repository;
    final notificationService = _notificationService;

    return MaterialApp(
      title: '삶은 계란',
      theme: _theme,
      home: (repository == null || notificationService == null)
          ? const Scaffold(body: Center(child: LoadingCharacter()))
          : ProviderScope(
              overrides: [
                jokeRepositoryProvider.overrideWithValue(repository),
                notificationServiceProvider.overrideWithValue(
                  notificationService,
                ),
              ],
              child: const HomeScreen(),
            ),
    );
  }
}
