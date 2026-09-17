import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/joke_repository.dart';

class FavoritesController extends StateNotifier<List<String>> {
  FavoritesController(this._repository) : super(_repository.favoriteIds);

  final JokeRepository _repository;

  bool isFavorite(String id) => state.contains(id);

  Future<void> toggle(String id) async {
    await _repository.toggleFavorite(id);
    state = _repository.favoriteIds;
  }
}
