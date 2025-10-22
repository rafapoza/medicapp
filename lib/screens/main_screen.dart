import 'package:flutter/material.dart';
import 'medication_list_screen.dart';
import 'medication_stock_screen.dart';
import 'medicine_cabinet_screen.dart';
import 'dose_history_screen.dart';

/// Main screen with bottom navigation bar
/// Provides navigation between the main sections of the app:
/// - Medications: Main list of medications with today's doses
/// - Pill organizer: Weekly medication schedule view
/// - Medicine cabinet: Inventory view of all medications
/// - History: Complete dose history
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // The screens corresponding to each navigation item
  final List<Widget> _screens = [
    const MedicationListScreen(),
    const MedicationStockScreen(),
    const MedicineCabinetScreen(),
    const DoseHistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Medicación',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Pastillero',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_information_outlined),
            selectedIcon: Icon(Icons.medical_information),
            label: 'Botiquín',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}
