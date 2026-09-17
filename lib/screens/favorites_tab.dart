import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/empty_state.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(favoritesControllerProvider);
    final favoriteJokes = ref.read(jokeRepositoryProvider).favoriteJokes;

    if (favoriteJokes.isEmpty) {
      return const EmptyState(
        message: '즐겨찾기가 텅 비어서 시무룩해요',
        imagePath: 'assets/images/character_dejected.png',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: favoriteJokes.length,
      itemBuilder: (context, index) {
        final joke = favoriteJokes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFEEDFC9)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    joke.content,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF4A3222),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref
                      .read(favoritesControllerProvider.notifier)
                      .toggle(joke.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
