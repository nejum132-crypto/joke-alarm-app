import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/joke.dart';
import '../providers.dart';

class CharacterTab extends ConsumerStatefulWidget {
  const CharacterTab({super.key});

  @override
  ConsumerState<CharacterTab> createState() => _CharacterTabState();
}

class _CharacterTabState extends ConsumerState<CharacterTab> {
  bool _pressed = false;
  bool _cracked = false;
  Joke? _joke;
  Timer? _closeTimer;

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _crackOpen() {
    final joke = ref.read(jokeRepositoryProvider).pickNextJoke();
    _closeTimer?.cancel();
    setState(() {
      _cracked = true;
      _joke = joke;
    });
    _closeTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _cracked = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final joke = _joke;
    final isFavorite = joke != null &&
        ref.watch(favoritesControllerProvider).contains(joke.id);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) {
              setState(() => _pressed = false);
              _crackOpen();
            },
            child: AnimatedScale(
              scale: _pressed ? 0.96 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedSlide(
                      offset: _cracked ? const Offset(0, 0.05) : Offset.zero,
                      duration: const Duration(milliseconds: 175),
                      curve: Curves.easeOut,
                      child: Image.asset(
                        _cracked
                            ? 'assets/images/character_crack_bottom_surprised.png'
                            : 'assets/images/character_crack_bottom.png',
                        width: 260,
                      ),
                    ),
                    AnimatedSlide(
                      offset:
                          _cracked ? const Offset(-0.06, -0.16) : Offset.zero,
                      duration: const Duration(milliseconds: 175),
                      curve: Curves.easeOut,
                      child: AnimatedRotation(
                        turns: _cracked ? -0.03 : 0,
                        duration: const Duration(milliseconds: 175),
                        child: Image.asset(
                          'assets/images/character_crack_top.png',
                          width: 260,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 125),
            child: (_cracked && joke != null)
                ? Padding(
                    key: ValueKey(joke.id),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Text(
                          joke.content,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4A3222),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(favoritesControllerProvider.notifier)
                              .toggle(joke.id),
                          icon: Icon(
                            isFavorite ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          label: Text(isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가'),
                        ),
                      ],
                    ),
                  )
                : const Text(
                    '눌러서 오늘의 아재개그 보기',
                    key: ValueKey('hint'),
                    style: TextStyle(color: Color(0xFF8A7462)),
                  ),
          ),
        ],
      ),
    );
  }
}
