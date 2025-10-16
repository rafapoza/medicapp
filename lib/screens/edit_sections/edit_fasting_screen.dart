import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/medication.dart';
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

      // Reschedule notifications to include fasting notifications
      await NotificationService.instance.scheduleMedicationNotifications(updatedMedication);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuración de ayuno actualizada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, updatedMedication);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar cambios: $e'),
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
        title: const Text('Editar Ayuno'),
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
                              'Ayuno',
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
                        'Algunos medicamentos requieren ayuno antes o después de la toma',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Question: ¿Requiere ayuno?
                      Text(
                        '¿Este medicamento requiere ayuno?',
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
                              onPressed: () {
                                setState(() {
                                  _requiresFasting = false;
                                  _fastingType = null;
                                  _notifyFasting = false;
                                });
                              },
                              icon: Icon(
                                _requiresFasting ? Icons.radio_button_off : Icons.radio_button_checked,
                                color: !_requiresFasting ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('No'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: !_requiresFasting
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: !_requiresFasting ? 2 : 1,
                                ),
                                backgroundColor: !_requiresFasting
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _requiresFasting = true;
                                });
                              },
                              icon: Icon(
                                _requiresFasting ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _requiresFasting ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Sí'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(
                                  color: _requiresFasting
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _requiresFasting ? 2 : 1,
                                ),
                                backgroundColor: _requiresFasting
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Show additional fields if fasting is required
                      if (_requiresFasting) ...[
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),

                        // Question: ¿Cuándo es el ayuno?
                        Text(
                          '¿Cuándo es el ayuno?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Before/After buttons
                        Column(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _fastingType = 'before';
                                });
                              },
                              icon: Icon(
                                _fastingType == 'before' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _fastingType == 'before' ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Antes de la toma'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 48),
                                alignment: Alignment.centerLeft,
                                side: BorderSide(
                                  color: _fastingType == 'before'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _fastingType == 'before' ? 2 : 1,
                                ),
                                backgroundColor: _fastingType == 'before'
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _fastingType = 'after';
                                });
                              },
                              icon: Icon(
                                _fastingType == 'after' ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: _fastingType == 'after' ? Theme.of(context).colorScheme.primary : null,
                              ),
                              label: const Text('Después de la toma'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                minimumSize: const Size(double.infinity, 48),
                                alignment: Alignment.centerLeft,
                                side: BorderSide(
                                  color: _fastingType == 'after'
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline,
                                  width: _fastingType == 'after' ? 2 : 1,
                                ),
                                backgroundColor: _fastingType == 'after'
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Question: ¿Cuánto tiempo de ayuno?
                        Text(
                          '¿Cuánto tiempo de ayuno?',
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
                                      'Horas',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _hoursController,
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
                                      'Minutos',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  TextField(
                                    controller: _minutesController,
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
                          '¿Deseas recibir notificaciones de ayuno?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _fastingType == 'before'
                              ? 'Te notificaremos cuándo debes dejar de comer antes de la toma'
                              : 'Te notificaremos cuándo puedes volver a comer después de la toma',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                        const SizedBox(height: 12),

                        // Notification switch
                        SwitchListTile(
                          value: _notifyFasting,
                          onChanged: (value) {
                            setState(() {
                              _notifyFasting = value;
                            });
                          },
                          title: Text(
                            _notifyFasting ? 'Notificaciones activadas' : 'Notificaciones desactivadas',
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
