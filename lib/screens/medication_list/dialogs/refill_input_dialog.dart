import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class RefillInputDialog {
  static Future<double?> show(
    BuildContext context, {
    required Medication medication,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final refillController = TextEditingController(
      text: medication.lastRefillAmount?.toString() ?? '',
    );

    final refillAmount = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.refillMedicationTitle(medication.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.currentStock(medication.stockDisplayText),
                  style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                // Quantity label
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.add_box, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.quantityToAdd,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${medication.type.stockUnit})',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Quantity field
                TextField(
                  controller: refillController,
                  decoration: InputDecoration(
                    hintText: medication.lastRefillAmount != null
                        ? l10n.example(medication.lastRefillAmount.toString())
                        : l10n.example('30'),
                    helperText: medication.lastRefillAmount != null
                        ? l10n.lastRefill(medication.lastRefillAmount.toString(), medication.type.stockUnit)
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, null),
              child: Text(l10n.btnCancel),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(refillController.text.trim());
                if (amount != null && amount > 0) {
                  Navigator.pop(dialogContext, amount);
                }
              },
              child: Text(l10n.refillButton),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      refillController.dispose();
    });

    return refillAmount;
  }
}
