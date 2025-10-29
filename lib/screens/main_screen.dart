import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';
import 'medication_list_screen.dart';
import 'medication_stock_screen.dart';
import 'medicine_cabinet_screen.dart';
import 'dose_history_screen.dart';
import 'settings_screen.dart';

/// Main screen with adaptive navigation
/// Uses NavigationBar (bottom) on mobile/portrait and NavigationRail (side) on tablets/landscape
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

  @override
  void initState() {
    super.initState();
    // Process any pending notifications after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.processPendingNotification();
    });
  }

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
      case 4:
        return const SettingsScreen();
      default:
        return const MedicationListScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    // Use NavigationRail for tablets (>600px) or landscape mode
    final useNavigationRail = screenWidth > 600 || isLandscape;

    if (useNavigationRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.medical_services_outlined),
                  selectedIcon: const Icon(Icons.medical_services),
                  label: Text(l10n.navMedication),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.inventory_2_outlined),
                  selectedIcon: const Icon(Icons.inventory_2),
                  label: Text(l10n.navPillOrganizer),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.medical_information_outlined),
                  selectedIcon: const Icon(Icons.medical_information),
                  label: Text(l10n.navMedicineCabinet),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.history_outlined),
                  selectedIcon: const Icon(Icons.history),
                  label: Text(l10n.navHistory),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: Text(l10n.navSettings),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: _getCurrentScreen(),
            ),
          ],
        ),
      );
    }

    // Use NavigationBar for mobile/portrait with short labels
    return Scaffold(
      body: _getCurrentScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.medical_services_outlined),
            selectedIcon: const Icon(Icons.medical_services),
            label: l10n.navMedicationShort,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: l10n.navPillOrganizerShort,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medical_information_outlined),
            selectedIcon: const Icon(Icons.medical_information),
            label: l10n.navMedicineCabinetShort,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.navHistoryShort,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettingsShort,
          ),
        ],
      ),
    );
  }
}
