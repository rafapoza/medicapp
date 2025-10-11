import 'package:flutter/material.dart';
import '../models/treatment_duration_type.dart';
import 'weekly_days_selector_screen.dart';
import 'specific_dates_selector_screen.dart';
import 'treatment_dates_screen.dart';

class TreatmentDurationScreen extends StatefulWidget {
  final TreatmentDurationType? initialDurationType;
  final int? initialCustomDays;
  final List<String>? initialSelectedDates;
  final List<int>? initialWeeklyDays;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TreatmentDurationScreen({
    super.key,
    this.initialDurationType,
    this.initialCustomDays,
    this.initialSelectedDates,
    this.initialWeeklyDays,
    this.initialStartDate,
    this.initialEndDate,
  });

  @override
  State<TreatmentDurationScreen> createState() =>
      _TreatmentDurationScreenState();
}

class _TreatmentDurationScreenState extends State<TreatmentDurationScreen> {
  late TreatmentDurationType _selectedDurationType;
  final _customDaysController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String>? _selectedDates;
  List<int>? _weeklyDays;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedDurationType =
        widget.initialDurationType ?? TreatmentDurationType.everyday;
    if (widget.initialCustomDays != null) {
      _customDaysController.text = widget.initialCustomDays.toString();
    }
    _selectedDates = widget.initialSelectedDates;
    _weeklyDays = widget.initialWeeklyDays;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    // Validate custom days if selected
    if (_selectedDurationType == TreatmentDurationType.custom) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    // Navigate to date/day selector if needed
    if (_selectedDurationType == TreatmentDurationType.specificDates) {
      final result = await Navigator.push<List<String>>(
        context,
        MaterialPageRoute(
          builder: (context) => SpecificDatesSelectorScreen(
            initialSelectedDates: _selectedDates,
          ),
        ),
      );

      if (result == null) {
        // User cancelled the date selection
        return;
      }

      _selectedDates = result;
    } else if (_selectedDurationType == TreatmentDurationType.weeklyPattern) {
      final result = await Navigator.push<List<int>>(
        context,
        MaterialPageRoute(
          builder: (context) => WeeklyDaysSelectorScreen(
            initialSelectedDays: _weeklyDays,
          ),
        ),
      );

      if (result == null) {
        // User cancelled the day selection
        return;
      }

      _weeklyDays = result;
    }

    final customDays = _selectedDurationType == TreatmentDurationType.custom
        ? int.parse(_customDaysController.text)
        : null;

    // Phase 2: Navigate to treatment dates screen (optional)
    final datesResult = await Navigator.push<Map<String, DateTime?>>(
      context,
      MaterialPageRoute(
        builder: (context) => TreatmentDatesScreen(
          durationType: _selectedDurationType,
          customDays: customDays,
          initialStartDate: _startDate,
          initialEndDate: _endDate,
        ),
      ),
    );

    if (datesResult != null) {
      _startDate = datesResult['startDate'];
      _endDate = datesResult['endDate'];
    } else {
      // User cancelled - stay on this screen
      return;
    }

    if (!mounted) return;

    Navigator.pop(context, {
      'durationType': _selectedDurationType,
      'customDays': customDays,
      'selectedDates': _selectedDates,
      'weeklyDays': _weeklyDays,
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duración del tratamiento'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                          '¿Cuántos días vas a tomar este medicamento?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ...TreatmentDurationType.values.map((type) {
                          final isSelected = _selectedDurationType == type;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedDurationType = type;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? type.getColor(context).withOpacity(0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? type.getColor(context)
                                        : Theme.of(context).dividerColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      type.icon,
                                      color: isSelected
                                          ? type.getColor(context)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        type.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: isSelected
                                                  ? type.getColor(context)
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: type.getColor(context),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        if (_selectedDurationType ==
                            TreatmentDurationType.custom) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _customDaysController,
                            decoration: InputDecoration(
                              labelText: 'Número de días',
                              hintText: 'Ej: 7',
                              prefixIcon: const Icon(Icons.calendar_today),
                              suffixText: 'días',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, introduce el número de días';
                              }

                              final days = int.tryParse(value.trim());
                              if (days == null || days <= 0) {
                                return 'El número de días debe ser mayor a 0';
                              }

                              if (days > 365) {
                                return 'El número de días no puede ser mayor a 365';
                              }

                              return null;
                            },
                          ),
                        ],
                        if (_selectedDurationType ==
                            TreatmentDurationType.specificDates &&
                            _selectedDates != null &&
                            _selectedDates!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_selectedDates!.length} fecha${_selectedDates!.length != 1 ? 's' : ''} seleccionada${_selectedDates!.length != 1 ? 's' : ''}',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (_selectedDurationType ==
                            TreatmentDurationType.weeklyPattern &&
                            _weeklyDays != null &&
                            _weeklyDays!.isNotEmpty) ...[
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
                                  Icons.date_range,
                                  color: Colors.teal,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_weeklyDays!.length} día${_weeklyDays!.length != 1 ? 's' : ''} seleccionado${_weeklyDays!.length != 1 ? 's' : ''}',
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
      ),
    );
  }
}
