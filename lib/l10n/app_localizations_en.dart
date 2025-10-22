// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String get validationDuplicateMedication =>
      'This medication already exists in your list';

  @override
  String get validationInvalidNumber => 'Enter a valid number';

  @override
  String validationMinValue(num min) {
    return 'Value must be greater than $min';
  }
}
