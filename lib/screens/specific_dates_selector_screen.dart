import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medicapp/l10n/app_localizations.dart';
import 'specific_dates_selector/widgets/instructions_card.dart';
import 'specific_dates_selector/widgets/selected_dates_list_card.dart';
import 'specific_dates_selector/widgets/continue_cancel_buttons.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('es', 'ES'),
      helpText: l10n.specificDatesSelectorPickerHelp,
      cancelText: l10n.specificDatesSelectorPickerCancel,
      confirmText: l10n.specificDatesSelectorPickerConfirm,
    );

    if (picked != null) {
      final dateString = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (_selectedDates.contains(dateString)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.specificDatesSelectorAlreadySelected),
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
    final l10n = AppLocalizations.of(context)!;
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.specificDatesSelectorSelectAtLeastOne),
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
    final l10n = AppLocalizations.of(context)!;
    // Wait for locale initialization
    if (!_localeInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.specificDatesSelectorTitle),
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
        title: Text(l10n.specificDatesSelectorTitle),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InstructionsCard(onAddDate: _addDate),
              if (_selectedDates.isNotEmpty) ...[
                const SizedBox(height: 16),
                SelectedDatesListCard(
                  sortedDates: sortedDates,
                  onRemoveDate: _removeDate,
                  parseDate: _parseDate,
                ),
              ],
              const SizedBox(height: 16),
              ContinueCancelButtons(
                onContinue: _continue,
                onCancel: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
