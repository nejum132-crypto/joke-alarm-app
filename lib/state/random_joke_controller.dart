import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/joke_repository.dart';
import '../services/notification_service.dart';

/// Drives the AppBar ON/OFF switch: when on, sends a joke notification at
/// two random times a day, re-rolled each time [refresh] runs (e.g. on
/// every app start) so the times aren't the same day after day.
class RandomJokeController extends StateNotifier<bool> {
  RandomJokeController(this._repository, this._notificationService)
      : super(_repository.isRandomEnabled);

  final JokeRepository _repository;
  final NotificationService _notificationService;

  Future<void> setEnabled(bool value) async {
    await _repository.setRandomEnabled(value);
    state = value;
    await _notificationService.rescheduleRandom(value);
  }

  Future<void> refresh() async {
    final enabled = _repository.isRandomEnabled;
    state = enabled;
    await _notificationService.rescheduleRandom(enabled);
  }
}
