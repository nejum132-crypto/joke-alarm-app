import 'dart:async';

import 'package:flutter/material.dart';

/// Alternates between two tilt poses while the app initializes, so the
/// startup wait doesn't look frozen.
class LoadingCharacter extends StatefulWidget {
  const LoadingCharacter({super.key});

  @override
  State<LoadingCharacter> createState() => _LoadingCharacterState();
}

class _LoadingCharacterState extends State<LoadingCharacter> {
  bool _left = true;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      setState(() => _left = !_left);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _left
          ? 'assets/images/character_tilt_left.png'
          : 'assets/images/character_tilt_right.png',
      width: 160,
    );
  }
}
