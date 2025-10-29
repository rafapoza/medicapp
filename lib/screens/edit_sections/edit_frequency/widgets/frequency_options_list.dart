import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../../widgets/forms/frequency_option_card.dart';
import '../../edit_frequency_screen.dart';

class FrequencyOptionsList extends StatelessWidget {
  final FrequencyMode selectedMode;
  final ValueChanged<FrequencyMode> onModeChanged;

  const FrequencyOptionsList({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.everyday,
          selectedValue: selectedMode,
          icon: Icons.calendar_today,
          title: l10n.editFrequencyEveryday,
          subtitle: l10n.editFrequencyEverydayDesc,
          color: Colors.blue,
          onTap: onModeChanged,
        ),
        const SizedBox(height: 12),
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.untilFinished,
          selectedValue: selectedMode,
          icon: Icons.hourglass_bottom,
          title: l10n.editFrequencyUntilFinished,
          subtitle: l10n.editFrequencyUntilFinishedDesc,
          color: Colors.green,
          onTap: onModeChanged,
        ),
        const SizedBox(height: 12),
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.specificDates,
          selectedValue: selectedMode,
          icon: Icons.event,
          title: l10n.editFrequencySpecificDates,
          subtitle: l10n.editFrequencySpecificDatesDesc,
          color: Colors.purple,
          onTap: onModeChanged,
        ),
        const SizedBox(height: 12),
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.weeklyPattern,
          selectedValue: selectedMode,
          icon: Icons.view_week,
          title: l10n.editFrequencyWeeklyDays,
          subtitle: l10n.editFrequencyWeeklyDaysDesc,
          color: Colors.indigo,
          onTap: onModeChanged,
        ),
        const SizedBox(height: 12),
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.alternateDays,
          selectedValue: selectedMode,
          icon: Icons.repeat,
          title: l10n.editFrequencyAlternateDays,
          subtitle: l10n.editFrequencyAlternateDaysDesc,
          color: Colors.orange,
          onTap: onModeChanged,
        ),
        const SizedBox(height: 12),
        FrequencyOptionCard<FrequencyMode>(
          value: FrequencyMode.customInterval,
          selectedValue: selectedMode,
          icon: Icons.timeline,
          title: l10n.editFrequencyCustomInterval,
          subtitle: l10n.editFrequencyCustomIntervalDesc,
          color: Colors.teal,
          onTap: onModeChanged,
        ),
      ],
    );
  }
}
