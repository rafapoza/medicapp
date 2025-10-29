import 'package:flutter/material.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import '../../../../models/medication_type.dart';

class QuantityFormCard extends StatelessWidget {
  final TextEditingController stockController;
  final TextEditingController lowStockThresholdController;
  final MedicationType medicationType;

  const QuantityFormCard({
    super.key,
    required this.stockController,
    required this.lowStockThresholdController,
    required this.medicationType,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.editQuantityMedicationLabel,
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
              l10n.editQuantityDescription,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // Stock quantity label
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.editQuantityAvailableLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${medicationType.stockUnit})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Stock quantity field
            TextFormField(
              controller: stockController,
              decoration: InputDecoration(
                hintText: l10n.availableQuantityHint,
                helperText: l10n.editQuantityAvailableHelp(medicationType.stockUnit),
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.editQuantityValidationRequired;
                }

                final quantity = double.tryParse(value.trim());
                if (quantity == null || quantity < 0) {
                  return l10n.editQuantityValidationMin;
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            // Low stock threshold
            TextFormField(
              controller: lowStockThresholdController,
              decoration: InputDecoration(
                labelText: l10n.editQuantityThresholdLabel,
                hintText: l10n.lowStockAlertHint,
                prefixIcon: const Icon(Icons.notifications_active),
                suffixText: l10n.pillOrganizerDays,
                helperText: l10n.editQuantityThresholdHelp,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.editQuantityThresholdValidationRequired;
                }

                final days = int.tryParse(value.trim());
                if (days == null || days < 1) {
                  return l10n.editQuantityThresholdValidationMin;
                }

                if (days > 30) {
                  return l10n.editQuantityThresholdValidationMax;
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
