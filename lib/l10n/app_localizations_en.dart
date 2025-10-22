// ignore_for_file: type=lint
import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedicApp';

  @override
  String get navMedication => 'Medication';

  @override
  String get navPillOrganizer => 'Pill Organizer';

  @override
  String get navMedicineCabinet => 'Medicine Cabinet';

  @override
  String get navHistory => 'History';

  @override
  String get btnContinue => 'Continue';

  @override
  String get btnBack => 'Back';

  @override
  String get btnSave => 'Save';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnDelete => 'Delete';

  @override
  String get btnEdit => 'Edit';

  @override
  String get btnClose => 'Close';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnAccept => 'Accept';

  @override
  String get medicationTypePill => 'Pill';

  @override
  String get medicationTypeCapsule => 'Capsule';

  @override
  String get medicationTypeTablet => 'Tablet';

  @override
  String get medicationTypeSyrup => 'Syrup';

  @override
  String get medicationTypeDrops => 'Drops';

  @override
  String get medicationTypeInjection => 'Injection';

  @override
  String get medicationTypePatch => 'Patch';

  @override
  String get medicationTypeInhaler => 'Inhaler';

  @override
  String get medicationTypeCream => 'Cream';

  @override
  String get medicationTypeOther => 'Other';

  @override
  String get doseStatusTaken => 'Taken';

  @override
  String get doseStatusSkipped => 'Skipped';

  @override
  String get doseStatusPending => 'Pending';

  @override
  String get durationContinuous => 'Continuous';

  @override
  String get durationSpecificDates => 'Specific Dates';

  @override
  String get durationAsNeeded => 'As Needed';

  @override
  String get mainScreenTitle => 'My Medications';

  @override
  String get mainScreenEmptyTitle => 'No medications registered';

  @override
  String get mainScreenEmptySubtitle => 'Add medications using the + button';

  @override
  String get mainScreenTodayDoses => 'Today\'s Doses';

  @override
  String get mainScreenNoMedications => 'You don\'t have active medications';

  @override
  String get msgMedicationAdded => 'Medication added successfully';

  @override
  String get msgMedicationUpdated => 'Medication updated successfully';

  @override
  String msgMedicationDeleted(String name) {
    return '$name deleted successfully';
  }

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationDuplicateMedication => 'This medication already exists in your list';

  @override
  String get validationInvalidNumber => 'Enter a valid number';

  @override
  String validationMinValue(num min) {
    return 'Value must be greater than $min';
  }

  // Pill Organizer Screen
  @override
  String get pillOrganizerTitle => 'Pill Organizer';
  @override
  String get pillOrganizerTotal => 'Total';
  @override
  String get pillOrganizerLowStock => 'Low stock';
  @override
  String get pillOrganizerNoStock => 'No stock';
  @override
  String get pillOrganizerAvailableStock => 'Available stock';
  @override
  String get pillOrganizerMedicationsTitle => 'Medications';
  @override
  String get pillOrganizerEmptyTitle => 'No medications registered';
  @override
  String get pillOrganizerEmptySubtitle => 'Add medications to view your pill organizer';
  @override
  String get pillOrganizerCurrentStock => 'Current stock';
  @override
  String get pillOrganizerEstimatedDuration => 'Estimated duration';
  @override
  String get pillOrganizerDays => 'days';

  // Medicine Cabinet Screen
  @override
  String get medicineCabinetTitle => 'Medicine Cabinet';
  @override
  String get medicineCabinetSearchHint => 'Search medication...';
  @override
  String get medicineCabinetEmptyTitle => 'No medications registered';
  @override
  String get medicineCabinetEmptySubtitle => 'Add medications to view your medicine cabinet';
  @override
  String get medicineCabinetPullToRefresh => 'Pull down to refresh';
  @override
  String get medicineCabinetNoResults => 'No medications found';
  @override
  String get medicineCabinetNoResultsHint => 'Try another search term';
  @override
  String get medicineCabinetStock => 'Stock:';
  @override
  String get medicineCabinetSuspended => 'Suspended';
  @override
  String get medicineCabinetTapToRegister => 'Tap to register';
  @override
  String get medicineCabinetResumeMedication => 'Resume medication';
  @override
  String get medicineCabinetRegisterDose => 'Register dose';
  @override
  String get medicineCabinetRefillMedication => 'Refill medication';
  @override
  String get medicineCabinetEditMedication => 'Edit medication';
  @override
  String get medicineCabinetDeleteMedication => 'Delete medication';
  @override
  String medicineCabinetRefillTitle(String name) => 'Refill $name';
  @override
  String medicineCabinetRegisterDoseTitle(String name) => 'Register dose of $name';
  @override
  String get medicineCabinetCurrentStock => 'Current stock:';
  @override
  String get medicineCabinetAddQuantity => 'Quantity to add:';
  @override
  String get medicineCabinetAddQuantityLabel => 'Quantity to add';
  @override
  String get medicineCabinetExample => 'Ex:';
  @override
  String get medicineCabinetLastRefill => 'Last refill:';
  @override
  String get medicineCabinetRefillButton => 'Refill';
  @override
  String get medicineCabinetAvailableStock => 'Available stock:';
  @override
  String get medicineCabinetDoseTaken => 'Quantity taken';
  @override
  String get medicineCabinetRegisterButton => 'Register';
  @override
  String get medicineCabinetNewStock => 'New stock:';
  @override
  String get medicineCabinetDeleteConfirmTitle => 'Delete medication';
  @override
  String medicineCabinetDeleteConfirmMessage(String name) => 'Are you sure you want to delete "$name"?\n\nThis action cannot be undone and all history for this medication will be lost.';
  @override
  String get medicineCabinetNoStockAvailable => 'No stock available for this medication';
  @override
  String medicineCabinetInsufficientStock(String needed, String unit, String available) => 'Insufficient stock for this dose\nNeeded: $needed $unit\nAvailable: $available';
  @override
  String medicineCabinetRefillSuccess(String name, String amount, String unit, String newStock) => 'Stock of $name refilled\nAdded: $amount $unit\nNew stock: $newStock';
  @override
  String medicineCabinetDoseRegistered(String name, String amount, String unit, String remaining) => 'Dose of $name registered\nQuantity: $amount $unit\nRemaining stock: $remaining';
  @override
  String medicineCabinetDeleteSuccess(String name) => '$name deleted successfully';
  @override
  String medicineCabinetResumeSuccess(String name) => '$name resumed successfully\nNotifications rescheduled';

  // Dose History Screen
  @override
  String get doseHistoryTitle => 'Dose History';
  @override
  String get doseHistoryFilterTitle => 'Filter history';
  @override
  String get doseHistoryMedicationLabel => 'Medication:';
  @override
  String get doseHistoryAllMedications => 'All medications';
  @override
  String get doseHistoryDateRangeLabel => 'Date range:';
  @override
  String get doseHistoryClearDates => 'Clear dates';
  @override
  String get doseHistoryApply => 'Apply';
  @override
  String get doseHistoryTotal => 'Total';
  @override
  String get doseHistoryTaken => 'Taken';
  @override
  String get doseHistorySkipped => 'Skipped';
  @override
  String get doseHistoryClear => 'Clear';
  @override
  String doseHistoryEditEntry(String name) => 'Edit $name record';
  @override
  String get doseHistoryScheduledTime => 'Scheduled time:';
  @override
  String get doseHistoryActualTime => 'Actual time:';
  @override
  String get doseHistoryStatus => 'Status:';
  @override
  String get doseHistoryMarkAsSkipped => 'Mark as Skipped';
  @override
  String get doseHistoryMarkAsTaken => 'Mark as Taken';
  @override
  String get doseHistoryConfirmDelete => 'Confirm deletion';
  @override
  String get doseHistoryConfirmDeleteMessage => 'Are you sure you want to delete this record?';
  @override
  String get doseHistoryRecordDeleted => 'Record deleted successfully';
  @override
  String doseHistoryDeleteError(String error) => 'Error deleting: $error';
}
