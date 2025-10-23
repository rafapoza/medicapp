import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/medication.dart';
import '../../widgets/forms/fasting_configuration_form.dart';
import '../../database/database_helper.dart';
import '../../services/notification_service.dart';

/// Pantalla para editar la configuración de ayuno
class EditFastingScreen extends StatefulWidget {
  final Medication medication;

  const EditFastingScreen({
    super.key,
    required this.medication,
  });

  @override
  State<EditFastingScreen> createState() => _EditFastingScreenState();
}

class _EditFastingScreenState extends State<EditFastingScreen> {
  late bool _requiresFasting;
  late String? _fastingType;
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;
  late bool _notifyFasting;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _requiresFasting = widget.medication.requiresFasting;
    _fastingType = widget.medication.fastingType;
    _notifyFasting = widget.medication.notifyFasting;

    // Parse hours and minutes from fastingDurationMinutes
    final totalMinutes = widget.medication.fastingDurationMinutes ?? 0;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    _hoursController = TextEditingController(text: hours.toString());
    _minutesController = TextEditingController(text: minutes.toString());
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  int? get _fastingDurationMinutes {
    if (!_requiresFasting) return null;

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    return (hours * 60) + minutes;
  }

  bool _isValid() {
    if (!_requiresFasting) return true;

    // Check if fasting type is selected
    if (_fastingType == null) return false;

    // Check if duration is valid (at least 1 minute)
    final duration = _fastingDurationMinutes;
    if (duration == null || duration < 1) return false;

    return true;
  }

  Future<void> _saveChanges() async {
    if (!_isValid()) {
      String message = 'Por favor, completa todos los campos';
      if (_fastingType == null) {
        message = 'Por favor, selecciona cuándo es el ayuno';
      } else if (_fastingDurationMinutes == null || _fastingDurationMinutes! < 1) {
        message = 'La duración del ayuno debe ser al menos 1 minuto';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedMedication = Medication(
        id: widget.medication.id,
        name: widget.medication.name,
        type: widget.medication.type,
        dosageIntervalHours: widget.medication.dosageIntervalHours,
        durationType: widget.medication.durationType,
        selectedDates: widget.medication.selectedDates,
        weeklyDays: widget.medication.weeklyDays,
        dayInterval: widget.medication.dayInterval,
        doseSchedule: widget.medication.doseSchedule,
        stockQuantity: widget.medication.stockQuantity,
        takenDosesToday: widget.medication.takenDosesToday,
        skippedDosesToday: widget.medication.skippedDosesToday,
        takenDosesDate: widget.medication.takenDosesDate,
        lastRefillAmount: widget.medication.lastRefillAmount,
        lowStockThresholdDays: widget.medication.lowStockThresholdDays,
        startDate: widget.medication.startDate,
        endDate: widget.medication.endDate,
        requiresFasting: _requiresFasting,
        fastingType: _fastingType,
        fastingDurationMinutes: _fastingDurationMinutes,
        notifyFasting: _notifyFasting,
      );

      await DatabaseHelper.instance.updateMedication(updatedMedication);

      // Always reschedule notifications when fasting settings change
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editFastingUpdated),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.editFastingError(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Configuración de Ayuno'),
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
                  child: FastingConfigurationForm(
                    requiresFasting: _requiresFasting,
                    fastingType: _fastingType,
                    hoursController: _hoursController,
                    minutesController: _minutesController,
                    notifyFasting: _notifyFasting,
                    onRequiresFastingChanged: (value) {
                      setState(() {
                        _requiresFasting = value;
                        if (!value) {
                          _fastingType = null;
                          _notifyFasting = false;
                        }
                      });
                    },
                    onFastingTypeChanged: (value) {
                      setState(() {
                        _fastingType = value;
                      });
                    },
                    onNotifyFastingChanged: (value) {
                      setState(() {
                        _notifyFasting = value;
                      });
                    },
                    showDescription: false,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveChanges,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar Cambios'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
