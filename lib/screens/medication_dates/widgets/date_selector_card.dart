import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorCard extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final String optionalLabel;
  final String defaultText;
  final Color selectedColor;

  const DateSelectorCard({
    super.key,
    required this.selectedDate,
    required this.onTap,
    required this.icon,
    required this.label,
    required this.optionalLabel,
    required this.defaultText,
    required this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isSelected = selectedDate != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? selectedColor : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? selectedColor : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          optionalLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSelected ? dateFormat.format(selectedDate!) : defaultText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? selectedColor : null,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: isSelected ? selectedColor : Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
