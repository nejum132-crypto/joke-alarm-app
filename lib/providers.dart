import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/joke_repository.dart';
import 'services/notification_service.dart';
import 'state/favorites_controller.dart';
import 'state/random_joke_controller.dart';
import 'state/schedule_controller.dart';

/// Overridden with real instances in main() after async init.
final jokeRepositoryProvider = Provider<JokeRepository>(
  (ref) => throw UnimplementedError('jokeRepositoryProvider not overridden'),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError('notificationServiceProvider not overridden'),
);

final scheduleControllerProvider =
    StateNotifierProvider<ScheduleController, ScheduleState>((ref) {
  return ScheduleController(
    ref.watch(jokeRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});

final favoritesControllerProvider =
    StateNotifierProvider<FavoritesController, List<String>>((ref) {
  return FavoritesController(ref.watch(jokeRepositoryProvider));
});

final randomJokeControllerProvider =
    StateNotifierProvider<RandomJokeController, bool>((ref) {
  return RandomJokeController(
    ref.watch(jokeRepositoryProvider),
    ref.watch(notificationServiceProvider),
  );
});
