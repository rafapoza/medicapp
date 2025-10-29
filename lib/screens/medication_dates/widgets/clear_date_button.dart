import 'package:flutter/material.dart';

class ClearDateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const ClearDateButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.clear, size: 18),
      label: Text(label),
    );
  }
}
