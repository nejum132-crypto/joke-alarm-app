import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/local_jokes.dart';
import '../models/joke.dart';

/// Persists the user's scheduled notification times and keeps a short
/// history of recently shown jokes so the same one doesn't repeat too soon.
///
/// Jokes come from [localJokes] today. A remote source (e.g. Firestore) can
/// be merged in later by extending [_pool] without changing callers.
class JokeRepository {
  static const _settingsBoxName = 'settings';
  static const _favoritesBoxName = 'favorites';
  static const _timesKey = 'scheduledMinutes';
  static const _enabledKey = 'enabled';
  static const _favoriteIdsKey = 'ids';
  static const _historySize = 5;

  late Box _settingsBox;
  late Box _favoritesBox;
  final _history = <String>[];
  final _random = Random();

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _favoritesBox = await Hive.openBox(_favoritesBoxName);
  }

  List<Joke> get _pool => localJokes;

  List<String> get favoriteIds =>
      (_favoritesBox.get(_favoriteIdsKey, defaultValue: <String>[]) as List)
          .cast<String>();

  List<Joke> get favoriteJokes =>
      _pool.where((j) => favoriteIds.contains(j.id)).toList();

  bool isFavorite(String id) => favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    final ids = [...favoriteIds];
    if (!ids.remove(id)) {
      ids.add(id);
    }
    await _favoritesBox.put(_favoriteIdsKey, ids);
  }

  /// Whether the "surprise me twice a day" random notification feature is on.
  bool get isRandomEnabled =>
      _settingsBox.get(_enabledKey, defaultValue: true) as bool;

  Future<void> setRandomEnabled(bool value) =>
      _settingsBox.put(_enabledKey, value);

  /// Scheduled times stored as minutes-since-midnight, sorted ascending.
  List<TimeOfDay> get scheduledTimes {
    final minutes = (_settingsBox.get(_timesKey, defaultValue: <int>[]) as List)
        .cast<int>();
    final sorted = [...minutes]..sort();
    return sorted.map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60)).toList();
  }

  Future<void> addTime(TimeOfDay time) async {
    final minutes = _minutesList();
    final value = time.hour * 60 + time.minute;
    if (!minutes.contains(value)) {
      minutes.add(value);
      await _settingsBox.put(_timesKey, minutes);
    }
  }

  Future<void> removeTime(TimeOfDay time) async {
    final minutes = _minutesList();
    minutes.remove(time.hour * 60 + time.minute);
    await _settingsBox.put(_timesKey, minutes);
  }

  List<int> _minutesList() =>
      ((_settingsBox.get(_timesKey, defaultValue: <int>[]) as List).cast<int>())
          .toList();

  /// Picks a joke that wasn't shown in the last [_historySize] picks.
  Joke pickNextJoke() {
    final candidates = _pool.where((j) => !_history.contains(j.id)).toList();
    final pickFrom = candidates.isNotEmpty ? candidates : _pool;
    final joke = pickFrom[_random.nextInt(pickFrom.length)];

    _history.add(joke.id);
    if (_history.length > _historySize) {
      _history.removeAt(0);
    }
    return joke;
  }
}
