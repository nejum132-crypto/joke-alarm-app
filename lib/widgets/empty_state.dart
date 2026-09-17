import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.imagePath = 'assets/images/character.png',
  });

  final String message;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 160),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF8A7462)),
          ),
        ],
      ),
    );
  }
}
