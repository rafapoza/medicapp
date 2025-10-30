import 'package:flutter/material.dart';

class SettingSwitchCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingSwitchCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}
