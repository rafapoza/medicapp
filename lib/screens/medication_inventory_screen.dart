import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'medication_stock_screen.dart';
import 'medicine_cabinet_screen.dart';

/// Screen that combines Pill Organizer and Medicine Cabinet with tabs
/// This provides a unified inventory view with two tabs:
/// - Stock tab: Shows medications with stock information (MedicationStockScreen)
/// - Cabinet tab: Shows all medications in alphabetical order (MedicineCabinetScreen)
class MedicationInventoryScreen extends StatefulWidget {
  const MedicationInventoryScreen({super.key});

  @override
  State<MedicationInventoryScreen> createState() => _MedicationInventoryScreenState();
}

class _MedicationInventoryScreenState extends State<MedicationInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navInventory),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.inventory_2),
              text: l10n.pillOrganizerTitle,
            ),
            Tab(
              icon: const Icon(Icons.medical_information),
              text: l10n.medicineCabinetTitle,
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MedicationStockScreen(showAppBar: false),
          MedicineCabinetScreen(showAppBar: false),
        ],
      ),
    );
  }
}
