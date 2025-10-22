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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Get the current screen based on selected index
  /// This approach creates screens on-demand instead of keeping all in memory
  /// which is more efficient and prevents test issues with pending timers
  Widget _getCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return const MedicationListScreen();
      case 1:
        return const MedicationStockScreen();
      case 2:
        return const MedicineCabinetScreen();
      case 3:
        return const DoseHistoryScreen();
      default:
        return const MedicationListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentScreen(),
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
