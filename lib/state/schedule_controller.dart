import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/joke_repository.dart';
import '../services/notification_service.dart';

class ScheduleState {
  final List<TimeOfDay> times;

  const ScheduleState({required this.times});
}

class ScheduleController extends StateNotifier<ScheduleState> {
  ScheduleController(this._repository, this._notificationService)
      : super(ScheduleState(times: _repository.scheduledTimes));

  final JokeRepository _repository;
  final NotificationService _notificationService;

  Future<void> addTime(TimeOfDay time) async {
    await _repository.addTime(time);
    await refresh();
  }

  Future<void> removeTime(TimeOfDay time) async {
    await _repository.removeTime(time);
    await refresh();
  }

  /// Re-reads persisted times and re-syncs the OS-level notification
  /// schedule. Safe to call repeatedly (e.g. on every app start) to keep the
  /// rolling notification window topped up. Independent of the "surprise
  /// me" random feature — this list is always active once it has entries.
  Future<void> refresh() async {
    final times = _repository.scheduledTimes;
    state = ScheduleState(times: times);
    await _notificationService.rescheduleManual(times);
  }
}
