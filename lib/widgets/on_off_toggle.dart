import 'package:flutter/material.dart';

/// A pill-shaped toggle that shows "ON"/"OFF" text directly on the button,
/// instead of a plain switch with a separate label next to it.
class OnOffToggle extends StatelessWidget {
  const OnOffToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = value ? scheme.primary : Colors.grey.shade400;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => onChanged(!value),
        child: Container(
          width: 64,
          height: 36,
          alignment: Alignment.center,
          child: Text(
            value ? 'ON' : 'OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
