// Unit test for the joke-picking logic. Avoids Hive/plugin init since those
// need platform channels that aren't available in a plain widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:joke_alarm_app/services/joke_repository.dart';

void main() {
  test('pickNextJoke avoids repeating the last few jokes', () {
    final repository = JokeRepository();

    final seen = <String>[];
    for (var i = 0; i < 10; i++) {
      final joke = repository.pickNextJoke();
      if (seen.length >= 5) {
        expect(seen.sublist(seen.length - 5), isNot(contains(joke.id)));
      }
      seen.add(joke.id);
    }
  });
}
