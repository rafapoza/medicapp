import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicapp/l10n/app_localizations.dart';

/// Widget reutilizable para el formulario de configuración de ayuno
/// Usado tanto en creación como en edición de medicamentos
class FastingConfigurationForm extends StatelessWidget {
  final bool requiresFasting;
  final String? fastingType;
  final TextEditingController hoursController;
  final TextEditingController minutesController;
  final bool notifyFasting;
  final ValueChanged<bool> onRequiresFastingChanged;
  final ValueChanged<String> onFastingTypeChanged;
  final ValueChanged<bool> onNotifyFastingChanged;
  final bool showDescription;

  const FastingConfigurationForm({
    super.key,
    required this.requiresFasting,
    required this.fastingType,
    required this.hoursController,
    required this.minutesController,
    required this.notifyFasting,
    required this.onRequiresFastingChanged,
    required this.onFastingTypeChanged,
    required this.onNotifyFastingChanged,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con icono y descripción
        if (showDescription) ...[
          Row(
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.fastingLabel,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fastingHelp,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 24),
        ],

        // Question: ¿Requiere ayuno?
        Text(
          l10n.requiresFastingQuestion,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),

        // Yes/No buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onRequiresFastingChanged(false),
                icon: Icon(
                  requiresFasting ? Icons.radio_button_off : Icons.radio_button_checked,
                  color: !requiresFasting ? Theme.of(context).colorScheme.primary : null,
                ),
                label: Text(l10n.fastingNo),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: !requiresFasting
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: !requiresFasting ? 2 : 1,
                  ),
                  backgroundColor: !requiresFasting
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => onRequiresFastingChanged(true),
                icon: Icon(
                  requiresFasting ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: requiresFasting ? Theme.of(context).colorScheme.primary : null,
                ),
                label: Text(l10n.fastingYes),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: requiresFasting
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: requiresFasting ? 2 : 1,
                  ),
                  backgroundColor: requiresFasting
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                ),
              ),
            ),
          ],
        ),

        // Show additional fields if fasting is required
        if (requiresFasting) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Question: ¿Cuándo es el ayuno?
          Text(
            l10n.fastingWhenQuestion,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Before/After buttons
          Column(
            children: [
              OutlinedButton.icon(
                onPressed: () => onFastingTypeChanged('before'),
                icon: Icon(
                  fastingType == 'before' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: fastingType == 'before' ? Theme.of(context).colorScheme.primary : null,
                ),
                label: Text(l10n.fastingBefore),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 48),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(
                    color: fastingType == 'before'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: fastingType == 'before' ? 2 : 1,
                  ),
                  backgroundColor: fastingType == 'before'
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => onFastingTypeChanged('after'),
                icon: Icon(
                  fastingType == 'after' ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: fastingType == 'after' ? Theme.of(context).colorScheme.primary : null,
                ),
                label: Text(l10n.fastingAfter),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 48),
                  alignment: Alignment.centerLeft,
                  side: BorderSide(
                    color: fastingType == 'after'
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: fastingType == 'after' ? 2 : 1,
                  ),
                  backgroundColor: fastingType == 'after'
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Question: ¿Cuánto tiempo de ayuno?
          Text(
            l10n.fastingDurationQuestion,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Hours and Minutes input
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        l10n.fastingHours,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    TextField(
                      controller: hoursController,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Text(
                        l10n.fastingMinutes,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    TextField(
                      controller: minutesController,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Question: ¿Deseas recibir notificaciones?
          Text(
            l10n.fastingNotificationsQuestion,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            fastingType == 'before'
                ? l10n.fastingNotificationBeforeHelp
                : l10n.fastingNotificationAfterHelp,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 12),

          // Notification switch
          SwitchListTile(
            value: notifyFasting,
            onChanged: onNotifyFastingChanged,
            title: Text(
              notifyFasting ? l10n.fastingNotificationsOn : l10n.fastingNotificationsOff,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
