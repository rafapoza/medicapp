import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class SpecificDatesSelectorScreen extends StatefulWidget {
  final List<String>? initialSelectedDates;

  const SpecificDatesSelectorScreen({
    super.key,
    this.initialSelectedDates,
  });

  @override
  State<SpecificDatesSelectorScreen> createState() => _SpecificDatesSelectorScreenState();
}

class _SpecificDatesSelectorScreenState extends State<SpecificDatesSelectorScreen> {
  late Set<String> _selectedDates; // Store as "yyyy-MM-dd" strings
  bool _localeInitialized = false;

  DateFormat get _dateFormatter => DateFormat('d MMM yyyy', 'es_ES');

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.initialSelectedDates?.toSet() ?? {};
    _initializeLocale();
  }

  Future<void> _initializeLocale() async {
    if (!_localeInitialized) {
      await initializeDateFormatting('es_ES', null);
      setState(() {
        _localeInitialized = true;
      });
    }
  }

  Future<void> _addDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('es', 'ES'),
      helpText: 'Selecciona una fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      final dateString = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (_selectedDates.contains(dateString)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esta fecha ya está seleccionada'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          _selectedDates.add(dateString);
        }
      });
    }
  }

  void _removeDate(String date) {
    setState(() {
      _selectedDates.remove(date);
    });
  }

  void _continue() {
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una fecha'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final sortedDates = _selectedDates.toList()..sort();
    Navigator.pop(context, sortedDates);
  }

  DateTime _parseDate(String dateString) {
    final parts = dateString.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  @override
  Widget build(BuildContext context) {
    // Wait for locale initialization
    if (!_localeInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fechas específicas'),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final sortedDates = _selectedDates.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fechas específicas'),
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
                        'Selecciona fechas',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Elige las fechas específicas en las que tomarás este medicamento',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.tonalIcon(
                        onPressed: _addDate,
                        icon: const Icon(Icons.add),
                        label: const Text('Añadir fecha'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.deepPurple.withOpacity(0.2),
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedDates.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.deepPurple,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fechas seleccionadas (${_selectedDates.length})',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...sortedDates.map((dateString) {
                          final date = _parseDate(dateString);
                          final isToday = DateTime.now().day == date.day &&
                              DateTime.now().month == date.month &&
                              DateTime.now().year == date.year;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        date.day.toString(),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMM', 'es_ES').format(date).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(
                                  _dateFormatter.format(date),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat('EEEE', 'es_ES').format(date),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isToday)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'HOY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    if (isToday) const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red,
                                      onPressed: () => _removeDate(dateString),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
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
