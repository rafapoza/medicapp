import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';

class ManualDoseInputDialog {
  static Future<double?> show(
    BuildContext context, {
    required Medication medication,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final doseController = TextEditingController(text: '1.0');

    final doseQuantity = await showDialog<double>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.registerDoseOfMedication(medication.name)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.availableStock(medication.stockDisplayText),
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
                      const Icon(Icons.medication, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        l10n.quantityTaken,
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
                  controller: doseController,
                  decoration: InputDecoration(
                    hintText: l10n.example('1'),
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
                final quantity = double.tryParse(doseController.text.trim());
                if (quantity != null && quantity > 0) {
                  Navigator.pop(dialogContext, quantity);
                }
              },
              child: Text(l10n.registerButton),
            ),
          ],
        );
      },
    );

    // Dispose controller after dialog closes
    Future.delayed(const Duration(milliseconds: 100), () {
      doseController.dispose();
    });

    return doseQuantity;
  }
}
