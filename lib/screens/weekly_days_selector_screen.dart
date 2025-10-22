import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';

class WeeklyDaysSelectorScreen extends StatefulWidget {
  final List<int>? initialSelectedDays;

  const WeeklyDaysSelectorScreen({
    super.key,
    this.initialSelectedDays,
  });

  @override
  State<WeeklyDaysSelectorScreen> createState() => _WeeklyDaysSelectorScreenState();
}

class _WeeklyDaysSelectorScreenState extends State<WeeklyDaysSelectorScreen> {
  late Set<int> _selectedDays;

  static const Map<int, String> _dayAbbreviations = {
    1: 'L',
    2: 'M',
    3: 'X',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };

  Map<int, String> _getDayNames(AppLocalizations l10n) {
    return {
      1: l10n.weeklyDayMonday,
      2: l10n.weeklyDayTuesday,
      3: l10n.weeklyDayWednesday,
      4: l10n.weeklyDayThursday,
      5: l10n.weeklyDayFriday,
      6: l10n.weeklyDaySaturday,
      7: l10n.weeklyDaySunday,
    };
  }

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.initialSelectedDays?.toSet() ?? {};
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _continue() {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.weeklyDaysSelectorSelectAtLeastOne),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sortedDays = _selectedDays.toList()..sort();
    Navigator.pop(context, sortedDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dayNames = _getDayNames(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weeklyDaysSelectorTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyDaysSelectorSelectDays,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.weeklyDaysSelectorDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),
                      // Day buttons
                      ...List.generate(7, (index) {
                        final day = index + 1;
                        final isSelected = _selectedDays.contains(day);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _toggleDay(day),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.teal.withOpacity(0.2)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.teal
                                      : Theme.of(context).dividerColor,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.teal
                                          : Theme.of(context).colorScheme.surfaceVariant,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _dayAbbreviations[day]!,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      dayNames[day]!,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: isSelected
                                                ? Colors.teal
                                                : Theme.of(context).colorScheme.onSurface,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.teal,
                                      size: 28,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      if (_selectedDays.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Colors.teal,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n.weeklyDaysSelectorSelectedCount(_selectedDays.length, _selectedDays.length != 1 ? 's' : ''),
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _continue,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l10n.weeklyDaysSelectorContinue),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: Text(l10n.btnCancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
