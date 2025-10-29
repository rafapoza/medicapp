import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/medication.dart';
import '../../../models/treatment_duration_type.dart';

class MedicationOptionsModal extends StatelessWidget {
  final Medication medication;
  final VoidCallback? onResume;
  final VoidCallback? onRegisterDose;
  final VoidCallback onRefill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicationOptionsModal({
    super.key,
    required this.medication,
    this.onResume,
    this.onRegisterDose,
    required this.onRefill,
    required this.onEdit,
    required this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    required Medication medication,
    VoidCallback? onResume,
    VoidCallback? onRegisterDose,
    required VoidCallback onRefill,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return MedicationOptionsModal(
          medication: medication,
          onResume: onResume,
          onRegisterDose: onRegisterDose,
          onRefill: onRefill,
          onEdit: onEdit,
          onDelete: onDelete,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAsNeeded = medication.durationType == TreatmentDurationType.asNeeded;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header with medication info
          Row(
            children: [
              Icon(
                medication.type.icon,
                size: 36,
                color: medication.type.getColor(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      medication.type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: medication.type.getColor(context),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.medicineCabinetStock} ${medication.stockDisplayText}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Action buttons
          if (medication.isSuspended && onResume != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onResume!();
                },
                icon: const Icon(Icons.play_arrow, size: 18),
                label: Text(l10n.medicineCabinetResumeMedication),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (isAsNeeded && !medication.isSuspended && onRegisterDose != null) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onRegisterDose!();
                },
                icon: const Icon(Icons.medication, size: 18),
                label: Text(l10n.medicineCabinetRegisterDose),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onRefill();
              },
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: Text(l10n.medicineCabinetRefillMedication),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onEdit();
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(l10n.medicineCabinetEditMedication),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onDelete();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(l10n.medicineCabinetDeleteMedication),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
              label: Text(l10n.btnClose),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
