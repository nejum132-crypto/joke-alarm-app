import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'joke_repository.dart';

/// Schedules joke notifications as concrete one-shot alarms for the next
/// [daysAhead] days (instead of a single repeating alarm) so that each
/// firing can show a different, non-repeating joke.
///
/// Two independent notification sets are managed, kept apart by their id
/// ranges so toggling one never disturbs the other:
///  - "manual" ids (< [_randomIdBase]): the user's own times from the
///    지정 시간 tab.
///  - "random" ids (>= [_randomIdBase]): the "surprise me twice a day"
///    feature driven by the ON/OFF switch.
class NotificationService {
  NotificationService(this._repository);

  final JokeRepository _repository;
  final _plugin = FlutterLocalNotificationsPlugin();
  final _random = Random();

  static const int daysAhead = 14;
  static const int _randomIdBase = 500000;
  static const int _randomSlotsPerDay = 2;
  static const int _randomWindowStartHour = 9;
  static const int _randomWindowEndHour = 21; // exclusive-ish upper bound

  static const _androidChannel = AndroidNotificationChannel(
    'joke_channel',
    '아재개그 알림',
    description: '지정한 시간에 아재개그를 보여줍니다',
    importance: Importance.high,
  );

  Future<void> init() async {
    tz_data.initializeTimeZones();
    final deviceTimeZone = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(deviceTimeZone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  Future<bool> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final notifGranted =
        await androidImpl?.requestNotificationsPermission() ?? true;

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await iosImpl?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;

    return notifGranted && iosGranted;
  }

  Future<void> _schedule(int id, tz.TZDateTime when, String content) {
    return _plugin.zonedSchedule(
      id,
      '아재개그 타임 😄',
      content,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _cancelWhere(bool Function(int id) matches) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (matches(request.id)) {
        await _plugin.cancel(request.id);
      }
    }
  }

  Future<void> cancelManual() =>
      _cancelWhere((id) => id < _randomIdBase);

  Future<void> cancelRandom() =>
      _cancelWhere((id) => id >= _randomIdBase);

  /// Cancels and re-schedules [daysAhead] days of notifications for the
  /// user's own times from the 지정 시간 tab. Call whenever that list
  /// changes, and once on app start to keep the rolling window topped up.
  Future<void> rescheduleManual(List<TimeOfDay> times) async {
    await cancelManual();
    if (times.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    for (var dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      for (var timeIndex = 0; timeIndex < times.length; timeIndex++) {
        final time = times[timeIndex];
        final scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
          time.hour,
          time.minute,
        );
        if (scheduled.isBefore(now)) continue;

        final joke = _repository.pickNextJoke();
        final id = dayOffset * 1000 + timeIndex;
        await _schedule(id, scheduled, joke.content);
      }
    }
  }

  /// Cancels and, if [enabled], re-rolls [_randomSlotsPerDay] random times a
  /// day for the next [daysAhead] days ("surprise me" mode driven by the
  /// ON/OFF switch). Re-running this re-randomizes the whole window, which
  /// is why it's called again on every app start.
  Future<void> rescheduleRandom(bool enabled) async {
    await cancelRandom();
    if (!enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    final windowSpanMinutes =
        (_randomWindowEndHour - _randomWindowStartHour) * 60;

    for (var dayOffset = 0; dayOffset < daysAhead; dayOffset++) {
      for (var slot = 0; slot < _randomSlotsPerDay; slot++) {
        final minuteOfWindow = _random.nextInt(windowSpanMinutes);
        final hour = _randomWindowStartHour + minuteOfWindow ~/ 60;
        final minute = minuteOfWindow % 60;

        final scheduled = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + dayOffset,
          hour,
          minute,
        );
        if (scheduled.isBefore(now)) continue;

        final joke = _repository.pickNextJoke();
        final id = _randomIdBase + dayOffset * 10 + slot;
        await _schedule(id, scheduled, joke.content);
      }
    }
  }
}
