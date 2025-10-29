import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/medication.dart';
import '../database/database_helper.dart';
import 'medication_stock/widgets/stock_summary_card.dart';
import 'medication_stock/widgets/empty_stock_view.dart';
import 'medication_stock/widgets/medication_stock_card.dart';

class MedicationStockScreen extends StatefulWidget {
  final bool showAppBar;

  const MedicationStockScreen({super.key, this.showAppBar = true});

  @override
  State<MedicationStockScreen> createState() => _MedicationStockScreenState();
}

class _MedicationStockScreenState extends State<MedicationStockScreen> {
  List<Medication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    final medications = await DatabaseHelper.instance.getAllMedications();

    if (!mounted) return;

    setState(() {
      // Filter out suspended medications from Pastillero
      _medications = medications.where((m) => !m.isSuspended).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(l10n.pillOrganizerTitle),
            )
          : null,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _medications.isEmpty
              ? const EmptyStockView()
              : RefreshIndicator(
                  onRefresh: _loadMedications,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Summary cards
                      Row(
                        children: [
                          Expanded(
                            child: StockSummaryCard(
                              title: l10n.pillOrganizerTotal,
                              value: _medications.length.toString(),
                              icon: Icons.medical_services,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StockSummaryCard(
                              title: l10n.pillOrganizerLowStock,
                              value: _medications
                                  .where((m) => m.isStockLow)
                                  .length
                                  .toString(),
                              icon: Icons.warning,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StockSummaryCard(
                              title: l10n.pillOrganizerNoStock,
                              value: _medications
                                  .where((m) => m.isStockEmpty)
                                  .length
                                  .toString(),
                              icon: Icons.error,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.pillOrganizerMedicationsTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      // Medications list
                      ..._medications.map((medication) => MedicationStockCard(medication: medication)),
                    ],
                  ),
                ),
    );
  }
}
