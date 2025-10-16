import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/treatment_duration_type.dart';

class TreatmentDatesScreen extends StatefulWidget {
  final TreatmentDurationType durationType;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TreatmentDatesScreen({
    super.key,
    required this.durationType,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TreatmentDatesScreen> createState() => _TreatmentDatesScreenState();
}

class _TreatmentDatesScreenState extends State<TreatmentDatesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _useCustomDates = false;

  final DateFormat _dateFormatter = DateFormat('d MMM yyyy', 'es_ES');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _useCustomDates = _startDate != null || _endDate != null;
  }

  Future<void> _selectStartDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de inicio del tratamiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          // If end date is before new start date, clear it
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero selecciona la fecha de inicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate!.add(const Duration(days: 7)),
      firstDate: _startDate!,
      lastDate: DateTime(_startDate!.year + 2, _startDate!.month, _startDate!.day),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de fin del tratamiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearStartDate() {
    setState(() {
      _startDate = null;
      // If clearing start date, also clear end date
      if (_endDate != null) {
        _endDate = null;
      }
    });
  }

  void _clearEndDate() {
    setState(() {
      _endDate = null;
    });
  }

  void _continue() {
    // Return the selected dates
    Navigator.pop(context, {
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  int? get _calculatedTotalDays {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechas del tratamiento'),
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
                        '¿Cuándo tomas este medicamento?',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Puedes especificar las fechas de inicio y fin del tratamiento. Si no las indicas, el tratamiento empezará hoy.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 24),

                      // Start date selection
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _startDate != null
                                ? Colors.green
                                : Theme.of(context).dividerColor,
                            width: _startDate != null ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.calendar_today,
                            color: _startDate != null ? Colors.green : null,
                          ),
                          title: Text(
                            _startDate != null
                                ? 'Inicio: ${_dateFormatter.format(_startDate!)}'
                                : 'Seleccionar fecha de inicio',
                            style: TextStyle(
                              fontWeight: _startDate != null ? FontWeight.bold : FontWeight.normal,
                              color: _startDate != null ? Colors.green : null,
                            ),
                          ),
                          subtitle: _startDate != null
                              ? const Text('Toca para cambiar')
                              : const Text('Opcional - Si no se indica, empieza hoy'),
                          trailing: _startDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.red),
                                  onPressed: _clearStartDate,
                                )
                              : null,
                          onTap: _selectStartDate,
                        ),
                      ),

                      const SizedBox(height: 16),
                        // End date selection
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _endDate != null
                                  ? Colors.deepOrange
                                  : Theme.of(context).dividerColor,
                              width: _endDate != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.event,
                              color: _endDate != null ? Colors.deepOrange : null,
                            ),
                            title: Text(
                              _endDate != null
                                  ? 'Fin: ${_dateFormatter.format(_endDate!)}'
                                  : 'Seleccionar fecha de fin',
                              style: TextStyle(
                                fontWeight: _endDate != null ? FontWeight.bold : FontWeight.normal,
                                color: _endDate != null ? Colors.deepOrange : null,
                              ),
                            ),
                            subtitle: _endDate != null
                                ? const Text('Toca para cambiar')
                                : const Text('Opcional - Si no se indica, no hay fecha límite'),
                            trailing: _endDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.red),
                                    onPressed: _clearEndDate,
                                  )
                                : null,
                            onTap: _selectEndDate,
                          ),
                        ),

                      // Show range summary if both dates are selected
                      if (_startDate != null && _endDate != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tratamiento de $_calculatedTotalDays días\n'
                                  'Del ${_dateFormatter.format(_startDate!)} al ${_dateFormatter.format(_endDate!)}',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
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
                label: const Text('Continuar'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
