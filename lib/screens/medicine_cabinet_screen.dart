import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import 'medication_info_screen.dart';
import 'medicine_cabinet/widgets/empty_cabinet_view.dart';
import 'medicine_cabinet/widgets/no_search_results_view.dart';
import 'medicine_cabinet/widgets/medication_card.dart';

class MedicineCabinetScreen extends StatefulWidget {
  final bool showAppBar;

  const MedicineCabinetScreen({super.key, this.showAppBar = true});

  @override
  State<MedicineCabinetScreen> createState() => _MedicineCabinetScreenState();
}

class _MedicineCabinetScreenState extends State<MedicineCabinetScreen> {
  List<Medication> _allMedications = [];
  List<Medication> _filteredMedications = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    final medications = await DatabaseHelper.instance.getAllMedications();

    if (!mounted) return;

    // Sort alphabetically by name
    medications.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    setState(() {
      _allMedications = medications;
      _filteredMedications = medications;
      _isLoading = false;
    });
  }

  void _filterMedications(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMedications = _allMedications;
      } else {
        _filteredMedications = _allMedications.where((medication) {
          return medication.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _navigateToAddMedication() async {
    final newMedication = await Navigator.push<Medication>(
      context,
      MaterialPageRoute(
        builder: (context) => MedicationInfoScreen(
          existingMedications: _allMedications,
        ),
      ),
    );

    if (newMedication != null) {
      // Reload medications after adding a new one
      await _loadMedications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(l10n.medicineCabinetTitle),
            )
          : null,
      body: Column(
        children: [
          // Search bar
          if (_allMedications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.medicineCabinetSearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _filterMedications('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: _filterMedications,
              ),
            ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _allMedications.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadMedications,
                        child: const EmptyCabinetView(),
                      )
                    : _filteredMedications.isEmpty
                        ? const NoSearchResultsView()
                        : RefreshIndicator(
                            onRefresh: _loadMedications,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _filteredMedications.length,
                              itemBuilder: (context, index) {
                                final medication = _filteredMedications[index];
                                return MedicationCard(
                                  medication: medication,
                                  onMedicationUpdated: _loadMedications,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMedication,
        child: const Icon(Icons.add),
      ),
    );
  }
}
