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
  String get navSettings => 'Settings';

  @override
  String get navInventory => 'Inventory';

  @override
  String get navMedicationShort => 'Home';

  @override
  String get navPillOrganizerShort => 'Stock';

  @override
  String get navMedicineCabinetShort => 'Cabinet';

  @override
  String get navHistoryShort => 'History';

  @override
  String get navSettingsShort => 'Settings';

  @override
  String get navInventoryShort => 'Meds';

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
  String get pillOrganizerEmptySubtitle =>
      'Add medications to view your pill organizer';

  @override
  String get pillOrganizerCurrentStock => 'Current stock';

  @override
  String get pillOrganizerEstimatedDuration => 'Estimated duration';

  @override
  String get pillOrganizerDays => 'days';

  @override
  String get medicineCabinetTitle => 'Medicine Cabinet';

  @override
  String get medicineCabinetSearchHint => 'Search medication...';

  @override
  String get medicineCabinetEmptyTitle => 'No medications registered';

  @override
  String get medicineCabinetEmptySubtitle =>
      'Add medications to view your medicine cabinet';

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
  String medicineCabinetRefillTitle(String name) {
    return 'Refill $name';
  }

  @override
  String medicineCabinetRegisterDoseTitle(String name) {
    return 'Register dose of $name';
  }

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
  String medicineCabinetDeleteConfirmMessage(String name) {
    return 'Are you sure you want to delete \"$name\"?\n\nThis action cannot be undone and all history for this medication will be lost.';
  }

  @override
  String get medicineCabinetNoStockAvailable =>
      'No stock available for this medication';

  @override
  String medicineCabinetInsufficientStock(
    String needed,
    String unit,
    String available,
  ) {
    return 'Insufficient stock for this dose\nNeeded: $needed $unit\nAvailable: $available';
  }

  @override
  String medicineCabinetRefillSuccess(
    String name,
    String amount,
    String unit,
    String newStock,
  ) {
    return 'Stock of $name refilled\nAdded: $amount $unit\nNew stock: $newStock';
  }

  @override
  String medicineCabinetDoseRegistered(
    String name,
    String amount,
    String unit,
    String remaining,
  ) {
    return 'Dose of $name registered\nQuantity: $amount $unit\nRemaining stock: $remaining';
  }

  @override
  String medicineCabinetDeleteSuccess(String name) {
    return '$name deleted successfully';
  }

  @override
  String medicineCabinetResumeSuccess(String name) {
    return '$name resumed successfully\nNotifications rescheduled';
  }

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
  String doseHistoryEditEntry(String name) {
    return 'Edit $name record';
  }

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
  String get doseHistoryConfirmDeleteMessage =>
      'Are you sure you want to delete this record?';

  @override
  String get doseHistoryRecordDeleted => 'Record deleted successfully';

  @override
  String doseHistoryDeleteError(String error) {
    return 'Error deleting: $error';
  }

  @override
  String get addMedicationTitle => 'Add Medication';

  @override
  String stepIndicator(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get medicationInfoTitle => 'Medication information';

  @override
  String get medicationInfoSubtitle =>
      'Start by providing the medication name and type';

  @override
  String get medicationNameLabel => 'Medication name';

  @override
  String get medicationNameHint => 'E.g.: Paracetamol';

  @override
  String get medicationTypeLabel => 'Medication type';

  @override
  String get validationMedicationName => 'Please enter the medication name';

  @override
  String get medicationDurationTitle => 'Treatment Type';

  @override
  String get medicationDurationSubtitle => 'How will you take this medication?';

  @override
  String get durationContinuousTitle => 'Continuous treatment';

  @override
  String get durationContinuousDesc => 'Every day, with regular pattern';

  @override
  String get durationUntilEmptyTitle => 'Until medication runs out';

  @override
  String get durationUntilEmptyDesc => 'Ends when stock is depleted';

  @override
  String get durationSpecificDatesTitle => 'Specific dates';

  @override
  String get durationSpecificDatesDesc => 'Only selected specific days';

  @override
  String get durationAsNeededTitle => 'As-needed medication';

  @override
  String get durationAsNeededDesc => 'Only when necessary, no schedules';

  @override
  String get selectDatesButton => 'Select dates';

  @override
  String get selectDatesTitle => 'Select the dates';

  @override
  String get selectDatesSubtitle =>
      'Choose the exact days you will take the medication';

  @override
  String dateSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates selected',
      one: '1 date selected',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectDates => 'Please select at least one date';

  @override
  String get medicationDatesTitle => 'Treatment Dates';

  @override
  String get medicationDatesSubtitle =>
      'When will you start and end this treatment?';

  @override
  String get medicationDatesHelp =>
      'Both dates are optional. If you don\'t set them, the treatment will start today and have no end date.';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get startDateOptional => 'Optional';

  @override
  String get startDateDefault => 'Starts today';

  @override
  String get endDateLabel => 'End date';

  @override
  String get endDateDefault => 'No end date';

  @override
  String get startDatePickerTitle => 'Treatment start date';

  @override
  String get endDatePickerTitle => 'Treatment end date';

  @override
  String get startTodayButton => 'Start today';

  @override
  String get noEndDateButton => 'No end date';

  @override
  String treatmentDuration(int days) {
    return '$days-day treatment';
  }

  @override
  String get medicationFrequencyTitle => 'Medication Frequency';

  @override
  String get medicationFrequencySubtitle =>
      'How often should you take this medication';

  @override
  String get frequencyDailyTitle => 'Every day';

  @override
  String get frequencyDailyDesc => 'Continuous daily medication';

  @override
  String get frequencyAlternateTitle => 'Alternate days';

  @override
  String get frequencyAlternateDesc => 'Every 2 days from treatment start';

  @override
  String get frequencyWeeklyTitle => 'Specific days of the week';

  @override
  String get frequencyWeeklyDesc => 'Select which days to take the medication';

  @override
  String get selectWeeklyDaysButton => 'Select days';

  @override
  String get selectWeeklyDaysTitle => 'Days of the week';

  @override
  String get selectWeeklyDaysSubtitle =>
      'Select the specific days you will take the medication';

  @override
  String daySelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days selected',
      one: '1 day selected',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectWeekdays => 'Please select the days of the week';

  @override
  String get medicationDosageTitle => 'Dose Configuration';

  @override
  String get medicationDosageSubtitle =>
      'How do you prefer to configure daily doses?';

  @override
  String get dosageFixedTitle => 'Same every day';

  @override
  String get dosageFixedDesc =>
      'Specify how often to take the medication in hours';

  @override
  String get dosageCustomTitle => 'Custom';

  @override
  String get dosageCustomDesc => 'Define the number of doses per day';

  @override
  String get dosageIntervalLabel => 'Interval between doses';

  @override
  String get dosageIntervalHelp => 'The interval must divide 24 exactly';

  @override
  String get dosageIntervalFieldLabel => 'Every how many hours';

  @override
  String get dosageIntervalHint => 'E.g.: 8';

  @override
  String get dosageIntervalUnit => 'hours';

  @override
  String get dosageIntervalValidValues =>
      'Valid values: 1, 2, 3, 4, 6, 8, 12, 24';

  @override
  String get dosageTimesLabel => 'Number of doses per day';

  @override
  String get dosageTimesHelp =>
      'Define how many times a day you\'ll take the medication';

  @override
  String get dosageTimesFieldLabel => 'Doses per day';

  @override
  String get dosageTimesHint => 'E.g.: 3';

  @override
  String get dosageTimesUnit => 'doses';

  @override
  String get dosageTimesDescription => 'Total number of daily doses';

  @override
  String get dosesPerDay => 'Doses per day';

  @override
  String doseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses',
      one: '1 dose',
    );
    return '$_temp0';
  }

  @override
  String get validationInvalidInterval => 'Please enter a valid interval';

  @override
  String get validationIntervalTooLarge =>
      'The interval cannot be greater than 24 hours';

  @override
  String get validationIntervalNotDivisor =>
      'The interval must divide 24 exactly (1, 2, 3, 4, 6, 8, 12, 24)';

  @override
  String get validationInvalidDoseCount =>
      'Please enter a valid number of doses';

  @override
  String get validationTooManyDoses =>
      'You cannot take more than 24 doses per day';

  @override
  String get medicationTimesTitle => 'Dose Schedule';

  @override
  String dosesPerDayLabel(int count) {
    return 'Doses per day: $count';
  }

  @override
  String frequencyEveryHours(int hours) {
    return 'Frequency: Every $hours hours';
  }

  @override
  String get selectTimeAndAmount => 'Select the time and amount for each dose';

  @override
  String doseNumber(int number) {
    return 'Dose $number';
  }

  @override
  String get selectTimeButton => 'Select time';

  @override
  String get amountPerDose => 'Amount per dose';

  @override
  String get amountHint => 'E.g.: 1, 0.5, 2';

  @override
  String get removeDoseButton => 'Remove dose';

  @override
  String get validationSelectAllTimes => 'Please select all dose times';

  @override
  String get validationEnterValidAmounts =>
      'Please enter valid amounts (greater than 0)';

  @override
  String get validationDuplicateTimes => 'Dose times cannot be repeated';

  @override
  String get validationAtLeastOneDose =>
      'There must be at least one dose per day';

  @override
  String get medicationFastingTitle => 'Fasting Configuration';

  @override
  String get fastingLabel => 'Fasting';

  @override
  String get fastingHelp =>
      'Some medications require fasting before or after taking';

  @override
  String get requiresFastingQuestion => 'Does this medication require fasting?';

  @override
  String get fastingNo => 'No';

  @override
  String get fastingYes => 'Yes';

  @override
  String get fastingWhenQuestion => 'When is the fasting?';

  @override
  String get fastingBefore => 'Before taking';

  @override
  String get fastingAfter => 'After taking';

  @override
  String get fastingDurationQuestion => 'How long is the fasting?';

  @override
  String get fastingHours => 'Hours';

  @override
  String get fastingMinutes => 'Minutes';

  @override
  String get fastingNotificationsQuestion =>
      'Do you want to receive fasting notifications?';

  @override
  String get fastingNotificationBeforeHelp =>
      'We\'ll notify you when to stop eating before taking';

  @override
  String get fastingNotificationAfterHelp =>
      'We\'ll notify you when you can eat again after taking';

  @override
  String get fastingNotificationsOn => 'Notifications enabled';

  @override
  String get fastingNotificationsOff => 'Notifications disabled';

  @override
  String get validationCompleteAllFields => 'Please complete all fields';

  @override
  String get validationSelectFastingWhen => 'Please select when the fasting is';

  @override
  String get validationFastingDuration =>
      'Fasting duration must be at least 1 minute';

  @override
  String get medicationQuantityTitle => 'Medication Quantity';

  @override
  String get medicationQuantitySubtitle =>
      'Set the available quantity and when you want to receive alerts';

  @override
  String get availableQuantityLabel => 'Available quantity';

  @override
  String get availableQuantityHint => 'E.g.: 30';

  @override
  String availableQuantityHelp(String unit) {
    return 'Amount of $unit you currently have';
  }

  @override
  String get lowStockAlertLabel => 'Alert when remaining';

  @override
  String get lowStockAlertHint => 'E.g.: 3';

  @override
  String get lowStockAlertUnit => 'days';

  @override
  String get lowStockAlertHelp =>
      'Days in advance to receive the low stock alert';

  @override
  String get validationEnterQuantity => 'Please enter the available quantity';

  @override
  String get validationQuantityNonNegative =>
      'Quantity must be greater than or equal to 0';

  @override
  String get validationEnterAlertDays => 'Please enter the days in advance';

  @override
  String get validationAlertMinDays => 'Must be at least 1 day';

  @override
  String get validationAlertMaxDays => 'Cannot be greater than 30 days';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get summaryMedication => 'Medication';

  @override
  String get summaryType => 'Type';

  @override
  String get summaryDosesPerDay => 'Doses per day';

  @override
  String get summarySchedules => 'Schedules';

  @override
  String get summaryFrequency => 'Frequency';

  @override
  String get summaryFrequencyDaily => 'Every day';

  @override
  String get summaryFrequencyUntilEmpty => 'Until medication runs out';

  @override
  String summaryFrequencySpecificDates(int count) {
    return '$count specific dates';
  }

  @override
  String summaryFrequencyWeekdays(int count) {
    return '$count days of the week';
  }

  @override
  String summaryFrequencyEveryNDays(int days) {
    return 'Every $days days';
  }

  @override
  String get summaryFrequencyAsNeeded => 'As needed';

  @override
  String msgMedicationAddedSuccess(String name) {
    return '$name added successfully';
  }

  @override
  String msgMedicationAddError(String error) {
    return 'Error saving medication: $error';
  }

  @override
  String get saveMedicationButton => 'Save Medication';

  @override
  String get savingButton => 'Saving...';

  @override
  String get doseActionTitle => 'Dose Action';

  @override
  String get doseActionLoading => 'Loading...';

  @override
  String get doseActionError => 'Error';

  @override
  String get doseActionMedicationNotFound => 'Medication not found';

  @override
  String get doseActionBack => 'Back';

  @override
  String doseActionScheduledTime(String time) {
    return 'Scheduled time: $time';
  }

  @override
  String get doseActionThisDoseQuantity => 'This dose quantity';

  @override
  String get doseActionWhatToDo => 'What do you want to do?';

  @override
  String get doseActionRegisterTaken => 'Register dose';

  @override
  String get doseActionWillDeductStock => 'Will deduct from stock';

  @override
  String get doseActionMarkAsNotTaken => 'Mark as not taken';

  @override
  String get doseActionWillNotDeductStock => 'Will not deduct from stock';

  @override
  String get doseActionPostpone15Min => 'Postpone 15 minutes';

  @override
  String get doseActionQuickReminder => 'Quick reminder';

  @override
  String get doseActionPostponeCustom => 'Postpone (choose time)';

  @override
  String doseActionInsufficientStock(
    String needed,
    String unit,
    String available,
  ) {
    return 'Insufficient stock for this dose\nNeeded: $needed $unit\nAvailable: $available';
  }

  @override
  String doseActionTakenRegistered(String name, String time, String stock) {
    return 'Dose of $name registered at $time\nRemaining stock: $stock';
  }

  @override
  String doseActionSkippedRegistered(String name, String time, String stock) {
    return 'Dose of $name marked as not taken at $time\nStock: $stock (no changes)';
  }

  @override
  String doseActionPostponed(String name, String time) {
    return 'Dose of $name postponed\nNew time: $time';
  }

  @override
  String doseActionPostponed15(String name, String time) {
    return 'Dose of $name postponed 15 minutes\nNew time: $time';
  }

  @override
  String get editMedicationMenuTitle => 'Edit Medication';

  @override
  String get editMedicationMenuWhatToEdit => 'What do you want to edit?';

  @override
  String get editMedicationMenuSelectSection =>
      'Select the section you want to modify';

  @override
  String get editMedicationMenuBasicInfo => 'Basic Information';

  @override
  String get editMedicationMenuBasicInfoDesc => 'Name and type of medication';

  @override
  String get editMedicationMenuDuration => 'Treatment Duration';

  @override
  String get editMedicationMenuFrequency => 'Frequency';

  @override
  String get editMedicationMenuSchedules => 'Schedules and Quantities';

  @override
  String editMedicationMenuSchedulesDesc(int count) {
    return '$count doses per day';
  }

  @override
  String get editMedicationMenuFasting => 'Fasting Configuration';

  @override
  String get editMedicationMenuQuantity => 'Available Quantity';

  @override
  String editMedicationMenuQuantityDesc(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get editMedicationMenuFreqEveryday => 'Every day';

  @override
  String get editMedicationMenuFreqUntilFinished => 'Until medication runs out';

  @override
  String editMedicationMenuFreqSpecificDates(int count) {
    return '$count specific dates';
  }

  @override
  String editMedicationMenuFreqWeeklyDays(int count) {
    return '$count days of the week';
  }

  @override
  String editMedicationMenuFreqInterval(int interval) {
    return 'Every $interval days';
  }

  @override
  String get editMedicationMenuFreqNotDefined => 'Frequency not defined';

  @override
  String get editMedicationMenuFastingNone => 'No fasting';

  @override
  String editMedicationMenuFastingDuration(String duration, String type) {
    return 'Fasting $duration $type';
  }

  @override
  String get editMedicationMenuFastingBefore => 'before';

  @override
  String get editMedicationMenuFastingAfter => 'after';

  @override
  String get editBasicInfoTitle => 'Edit Basic Information';

  @override
  String get editBasicInfoUpdated => 'Information updated successfully';

  @override
  String get editBasicInfoSaving => 'Saving...';

  @override
  String get editBasicInfoSaveChanges => 'Save Changes';

  @override
  String editBasicInfoError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String get editDurationTitle => 'Edit Duration';

  @override
  String get editDurationTypeLabel => 'Duration type';

  @override
  String editDurationCurrentType(String type) {
    return 'Current type: $type';
  }

  @override
  String get editDurationChangeTypeInfo =>
      'To change the duration type, edit the \"Frequency\" section';

  @override
  String get editDurationTreatmentDates => 'Treatment dates';

  @override
  String get editDurationStartDate => 'Start date';

  @override
  String get editDurationEndDate => 'End date';

  @override
  String get editDurationNotSelected => 'Not selected';

  @override
  String editDurationDays(int days) {
    return 'Duration: $days days';
  }

  @override
  String get editDurationSelectDates => 'Please select start and end dates';

  @override
  String get editDurationUpdated => 'Duration updated successfully';

  @override
  String editDurationError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String get editFastingTitle => 'Edit Fasting Configuration';

  @override
  String get editFastingCompleteFields => 'Please complete all fields';

  @override
  String get editFastingSelectWhen => 'Please select when the fasting is';

  @override
  String get editFastingMinDuration =>
      'Fasting duration must be at least 1 minute';

  @override
  String get editFastingUpdated => 'Fasting configuration updated successfully';

  @override
  String editFastingError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String get editFrequencyTitle => 'Edit Frequency';

  @override
  String get editFrequencyPattern => 'Frequency pattern';

  @override
  String get editFrequencyQuestion =>
      'How often will you take this medication?';

  @override
  String get editFrequencyEveryday => 'Every day';

  @override
  String get editFrequencyEverydayDesc => 'Take the medication daily';

  @override
  String get editFrequencyUntilFinished => 'Until finished';

  @override
  String get editFrequencyUntilFinishedDesc => 'Until the medication runs out';

  @override
  String get editFrequencySpecificDates => 'Specific dates';

  @override
  String get editFrequencySpecificDatesDesc => 'Select specific dates';

  @override
  String get editFrequencyWeeklyDays => 'Days of the week';

  @override
  String get editFrequencyWeeklyDaysDesc => 'Select specific days each week';

  @override
  String get editFrequencyAlternateDays => 'Alternate days';

  @override
  String get editFrequencyAlternateDaysDesc =>
      'Every 2 days from treatment start';

  @override
  String get editFrequencyCustomInterval => 'Custom interval';

  @override
  String get editFrequencyCustomIntervalDesc => 'Every N days from start';

  @override
  String get editFrequencySelectedDates => 'Selected dates';

  @override
  String editFrequencyDatesCount(int count) {
    return '$count dates selected';
  }

  @override
  String get editFrequencyNoDatesSelected => 'No dates selected';

  @override
  String get editFrequencySelectDatesButton => 'Select dates';

  @override
  String get editFrequencyWeeklyDaysLabel => 'Days of the week';

  @override
  String editFrequencyWeeklyDaysCount(int count) {
    return '$count days selected';
  }

  @override
  String get editFrequencyNoDaysSelected => 'No days selected';

  @override
  String get editFrequencySelectDaysButton => 'Select days';

  @override
  String get editFrequencyIntervalLabel => 'Day interval';

  @override
  String get editFrequencyIntervalField => 'Every how many days';

  @override
  String get editFrequencyIntervalHint => 'E.g.: 3';

  @override
  String get editFrequencyIntervalHelp => 'Must be at least 2 days';

  @override
  String get editFrequencySelectAtLeastOneDate =>
      'Please select at least one date';

  @override
  String get editFrequencySelectAtLeastOneDay =>
      'Please select at least one day of the week';

  @override
  String get editFrequencyIntervalMin => 'Interval must be at least 2 days';

  @override
  String get editFrequencyUpdated => 'Frequency updated successfully';

  @override
  String editFrequencyError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String get editQuantityTitle => 'Edit Quantity';

  @override
  String get editQuantityMedicationLabel => 'Medication quantity';

  @override
  String get editQuantityDescription =>
      'Set the available quantity and when you want to receive alerts';

  @override
  String get editQuantityAvailableLabel => 'Available quantity';

  @override
  String editQuantityAvailableHelp(String unit) {
    return 'Amount of $unit you currently have';
  }

  @override
  String get editQuantityValidationRequired =>
      'Please enter the available quantity';

  @override
  String get editQuantityValidationMin =>
      'Quantity must be greater than or equal to 0';

  @override
  String get editQuantityThresholdLabel => 'Alert when remaining';

  @override
  String get editQuantityThresholdHelp =>
      'Days in advance to receive the low stock alert';

  @override
  String get editQuantityThresholdValidationRequired =>
      'Please enter the days in advance';

  @override
  String get editQuantityThresholdValidationMin => 'Must be at least 1 day';

  @override
  String get editQuantityThresholdValidationMax =>
      'Cannot be greater than 30 days';

  @override
  String get editQuantityUpdated => 'Quantity updated successfully';

  @override
  String editQuantityError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String get editScheduleTitle => 'Edit Schedules';

  @override
  String get editScheduleAddDose => 'Add dose';

  @override
  String get editScheduleValidationQuantities =>
      'Please enter valid quantities (greater than 0)';

  @override
  String get editScheduleValidationDuplicates =>
      'Dose times cannot be repeated';

  @override
  String get editScheduleUpdated => 'Schedules updated successfully';

  @override
  String editScheduleError(String error) {
    return 'Error saving changes: $error';
  }

  @override
  String editScheduleDosesPerDay(int count) {
    return 'Doses per day: $count';
  }

  @override
  String get editScheduleAdjustTimeAndQuantity =>
      'Adjust the time and quantity of each dose';

  @override
  String get specificDatesSelectorTitle => 'Specific dates';

  @override
  String get specificDatesSelectorSelectDates => 'Select dates';

  @override
  String get specificDatesSelectorDescription =>
      'Choose the specific dates when you will take this medication';

  @override
  String get specificDatesSelectorAddDate => 'Add date';

  @override
  String specificDatesSelectorSelectedDates(int count) {
    return 'Selected dates ($count)';
  }

  @override
  String get specificDatesSelectorToday => 'TODAY';

  @override
  String get specificDatesSelectorContinue => 'Continue';

  @override
  String get specificDatesSelectorAlreadySelected =>
      'This date is already selected';

  @override
  String get specificDatesSelectorSelectAtLeastOne =>
      'Select at least one date';

  @override
  String get specificDatesSelectorPickerHelp => 'Select a date';

  @override
  String get specificDatesSelectorPickerCancel => 'Cancel';

  @override
  String get specificDatesSelectorPickerConfirm => 'Accept';

  @override
  String get weeklyDaysSelectorTitle => 'Days of the week';

  @override
  String get weeklyDaysSelectorSelectDays => 'Select the days';

  @override
  String get weeklyDaysSelectorDescription =>
      'Choose which days of the week you will take this medication';

  @override
  String weeklyDaysSelectorSelectedCount(int count, String plural) {
    return '$count day$plural selected';
  }

  @override
  String get weeklyDaysSelectorContinue => 'Continue';

  @override
  String get weeklyDaysSelectorSelectAtLeastOne =>
      'Select at least one day of the week';

  @override
  String get weeklyDayMonday => 'Monday';

  @override
  String get weeklyDayTuesday => 'Tuesday';

  @override
  String get weeklyDayWednesday => 'Wednesday';

  @override
  String get weeklyDayThursday => 'Thursday';

  @override
  String get weeklyDayFriday => 'Friday';

  @override
  String get weeklyDaySaturday => 'Saturday';

  @override
  String get weeklyDaySunday => 'Sunday';

  @override
  String get dateFromLabel => 'From';

  @override
  String get dateToLabel => 'To';

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get adherenceLabel => 'Adherence';

  @override
  String get emptyDosesWithFilters => 'No doses with these filters';

  @override
  String get emptyDoses => 'No doses registered';

  @override
  String get permissionRequired => 'Permission required';

  @override
  String get notNowButton => 'Not now';

  @override
  String get openSettingsButton => 'Open settings';

  @override
  String medicationUpdatedMsg(String name) {
    return '$name updated';
  }

  @override
  String get noScheduledTimes => 'This medication has no scheduled times';

  @override
  String get allDosesTakenToday => 'You\'ve taken all doses for today';

  @override
  String get extraDoseOption => 'Extra dose';

  @override
  String extraDoseConfirmationMessage(String name) {
    return 'You\'ve already registered all scheduled doses for today. Do you want to register an extra dose of $name?';
  }

  @override
  String get extraDoseConfirm => 'Register extra dose';

  @override
  String extraDoseRegistered(String name, String time, String stock) {
    return 'Extra dose of $name registered at $time ($stock available)';
  }

  @override
  String registerDoseOfMedication(String name) {
    return 'Register dose of $name';
  }

  @override
  String refillMedicationTitle(String name) {
    return 'Refill $name';
  }

  @override
  String doseRegisteredAt(String time) {
    return 'Registered at $time';
  }

  @override
  String statusUpdatedTo(String status) {
    return 'Status updated to: $status';
  }

  @override
  String get dateLabel => 'Date:';

  @override
  String get scheduledTimeLabel => 'Scheduled time:';

  @override
  String get currentStatusLabel => 'Current status:';

  @override
  String get changeStatusToQuestion => 'Change status to:';

  @override
  String get filterApplied => 'Filter applied';

  @override
  String filterFrom(String date) {
    return 'From $date';
  }

  @override
  String filterTo(String date) {
    return 'To $date';
  }

  @override
  String get insufficientStockForDose => 'Insufficient stock to mark as taken';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsDisplaySection => 'Display';

  @override
  String get settingsShowActualTimeTitle => 'Show actual dose time';

  @override
  String get settingsShowActualTimeSubtitle =>
      'Display the actual time doses were taken instead of the scheduled time';

  @override
  String get settingsShowFastingCountdownTitle => 'Show fasting countdown';

  @override
  String get settingsShowFastingCountdownSubtitle =>
      'Display remaining fasting time on main screen';

  @override
  String get settingsShowFastingNotificationTitle =>
      'Fixed countdown notification';

  @override
  String get settingsShowFastingNotificationSubtitle =>
      'Show a fixed notification with remaining fasting time (Android only)';

  @override
  String get fastingNotificationTitle => 'Fasting in progress';

  @override
  String fastingNotificationBody(
    String medication,
    String timeRemaining,
    String endTime,
  ) {
    return '$medication • $timeRemaining remaining (until $endTime)';
  }

  @override
  String fastingRemainingMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String fastingRemainingHours(int hours) {
    return '${hours}h';
  }

  @override
  String fastingRemainingHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String fastingActive(String time, String endTime) {
    return 'Fasting: $time remaining (until $endTime)';
  }

  @override
  String fastingUpcoming(String time, String endTime) {
    return 'Next fasting: $time (until $endTime)';
  }

  @override
  String get settingsBackupSection => 'Backup & Restore';

  @override
  String get settingsExportTitle => 'Export Database';

  @override
  String get settingsExportSubtitle =>
      'Save a copy of all your medications and history';

  @override
  String get settingsImportTitle => 'Import Database';

  @override
  String get settingsImportSubtitle => 'Restore a previously exported backup';

  @override
  String get settingsInfoTitle => 'Information';

  @override
  String get settingsInfoContent =>
      '• When exporting, a backup file will be created that you can save on your device or share.\n\n• When importing, all current data will be replaced with the data from the selected file.\n\n• It is recommended to make backups regularly.';

  @override
  String get settingsShareText => 'MedicApp Database Backup';

  @override
  String get settingsExportSuccess => 'Database exported successfully';

  @override
  String get settingsImportSuccess => 'Database imported successfully';

  @override
  String settingsExportError(String error) {
    return 'Export error: $error';
  }

  @override
  String settingsImportError(String error) {
    return 'Import error: $error';
  }

  @override
  String get settingsFilePathError => 'Could not get file path';

  @override
  String get settingsImportDialogTitle => 'Import Database';

  @override
  String get settingsImportDialogMessage =>
      'This action will replace all your current data with the data from the imported file.\n\nAre you sure you want to continue?';

  @override
  String get settingsRestartDialogTitle => 'Import Completed';

  @override
  String get settingsRestartDialogMessage =>
      'The database has been imported successfully.\n\nPlease restart the application to see the changes.';

  @override
  String get settingsRestartDialogButton => 'OK';

  @override
  String get notificationsWillNotWork =>
      'Notifications will NOT work without this permission.';

  @override
  String get debugMenuActivated => 'Debug menu activated';

  @override
  String get debugMenuDeactivated => 'Debug menu deactivated';

  @override
  String nextDoseAt(String time) {
    return 'Next dose: $time';
  }

  @override
  String pendingDose(String time) {
    return '⚠️ Pending dose: $time';
  }

  @override
  String nextDoseTomorrow(String time) {
    return 'Next dose: tomorrow at $time';
  }

  @override
  String nextDoseOnDay(String dayName, int day, int month, String time) {
    return 'Next dose: $dayName $day/$month at $time';
  }

  @override
  String get dayNameMon => 'Mon';

  @override
  String get dayNameTue => 'Tue';

  @override
  String get dayNameWed => 'Wed';

  @override
  String get dayNameThu => 'Thu';

  @override
  String get dayNameFri => 'Fri';

  @override
  String get dayNameSat => 'Sat';

  @override
  String get dayNameSun => 'Sun';

  @override
  String get whichDoseDidYouTake => 'Which dose did you take?';

  @override
  String insufficientStockForThisDose(
    String needed,
    String unit,
    String available,
  ) {
    return 'Insufficient stock for this dose\nNeeded: $needed $unit\nAvailable: $available';
  }

  @override
  String doseRegisteredAtTime(String name, String time, String stock) {
    return 'Dose of $name registered at $time\nRemaining stock: $stock';
  }

  @override
  String get allDosesCompletedToday => '✓ All doses for today completed';

  @override
  String remainingDosesToday(int count) {
    return 'Remaining doses today: $count';
  }

  @override
  String manualDoseRegistered(
    String name,
    String quantity,
    String unit,
    String stock,
  ) {
    return 'Manual dose of $name registered\nQuantity: $quantity $unit\nRemaining stock: $stock';
  }

  @override
  String medicationSuspended(String name) {
    return '$name suspended\nNo more notifications will be scheduled';
  }

  @override
  String medicationReactivated(String name) {
    return '$name reactivated\nNotifications rescheduled';
  }

  @override
  String currentStock(String stock) {
    return 'Current stock: $stock';
  }

  @override
  String get quantityToAdd => 'Quantity to add';

  @override
  String example(String example) {
    return 'E.g.: $example';
  }

  @override
  String lastRefill(String amount, String unit) {
    return 'Last refill: $amount $unit';
  }

  @override
  String get refillButton => 'Refill';

  @override
  String stockRefilled(
    String name,
    String amount,
    String unit,
    String newStock,
  ) {
    return 'Stock of $name refilled\nAdded: $amount $unit\nNew stock: $newStock';
  }

  @override
  String availableStock(String stock) {
    return 'Available stock: $stock';
  }

  @override
  String get quantityTaken => 'Quantity taken';

  @override
  String get registerButton => 'Register';

  @override
  String get registerManualDose => 'Register manual dose';

  @override
  String get refillMedication => 'Refill medication';

  @override
  String get resumeMedication => 'Resume medication';

  @override
  String get suspendMedication => 'Suspend medication';

  @override
  String get editMedicationButton => 'Edit medication';

  @override
  String get deleteMedicationButton => 'Delete medication';

  @override
  String medicationDeletedShort(String name) {
    return '$name deleted';
  }

  @override
  String get noMedicationsRegistered => 'No medications registered';

  @override
  String get addMedicationHint => 'Press the + button to add one';

  @override
  String get pullToRefresh => 'Pull down to refresh';

  @override
  String get batteryOptimizationWarning =>
      'For notifications to work, disable battery restrictions:';

  @override
  String get batteryOptimizationInstructions =>
      'Settings → Apps → MedicApp → Battery → \"Unrestricted\"';

  @override
  String get openSettings => 'Open settings';

  @override
  String get todayDosesLabel => 'Today\'s doses:';

  @override
  String doseOfMedicationAt(String name, String time) {
    return 'Dose of $name at $time';
  }

  @override
  String currentStatus(String status) {
    return 'Current status: $status';
  }

  @override
  String get whatDoYouWantToDo => 'What do you want to do?';

  @override
  String get deleteButton => 'Delete';

  @override
  String get markAsSkipped => 'Mark as Skipped';

  @override
  String get markAsTaken => 'Mark as Taken';

  @override
  String doseDeletedAt(String time) {
    return 'Dose at $time deleted';
  }

  @override
  String errorDeleting(String error) {
    return 'Error deleting: $error';
  }

  @override
  String doseMarkedAs(String time, String status) {
    return 'Dose at $time marked as $status';
  }

  @override
  String errorChangingStatus(String error) {
    return 'Error changing status: $error';
  }

  @override
  String medicationUpdatedShort(String name) {
    return '$name updated';
  }

  @override
  String get activateAlarmsPermission => 'Activate \"Alarms & reminders\"';

  @override
  String get alarmsPermissionDescription =>
      'This permission allows notifications to trigger exactly at the scheduled time.';

  @override
  String get notificationDebugTitle => 'Notification Debug';

  @override
  String notificationPermissions(String enabled) {
    return '✓ Notification permissions: $enabled';
  }

  @override
  String exactAlarmsAndroid12(String enabled) {
    return '⏰ Exact alarms (Android 12+): $enabled';
  }

  @override
  String get importantWarning => '⚠️ IMPORTANT';

  @override
  String get withoutPermissionNoNotifications =>
      'Without this permission notifications will NOT trigger.';

  @override
  String get alarmsSettings =>
      'Settings → Apps → MedicApp → Alarms & reminders';

  @override
  String pendingNotificationsCount(int count) {
    return '📊 Pending notifications: $count';
  }

  @override
  String medicationsWithSchedules(int withSchedules, int total) {
    return '💊 Medications with schedules: $withSchedules/$total';
  }

  @override
  String get scheduledNotifications => 'Scheduled notifications:';

  @override
  String get noScheduledNotifications => '⚠️ No scheduled notifications';

  @override
  String get noTitle => 'No title';

  @override
  String get medicationsAndSchedules => 'Medications and schedules:';

  @override
  String get noSchedulesConfigured => '⚠️ No schedules configured';

  @override
  String get closeButton => 'Close';

  @override
  String get testNotification => 'Test notification';

  @override
  String get testNotificationSent => 'Test notification sent';

  @override
  String get testScheduledNotification => 'Test scheduled (1 min)';

  @override
  String get scheduledNotificationInOneMin =>
      'Notification scheduled for 1 minute';

  @override
  String get rescheduleNotifications => 'Reschedule notifications';

  @override
  String get notificationsInfo => 'Notification info';

  @override
  String notificationsRescheduled(int count) {
    return 'Notifications rescheduled: $count';
  }

  @override
  String get yesText => 'Yes';

  @override
  String get noText => 'No';

  @override
  String get notificationTypeDynamicFasting => 'Dynamic fasting';

  @override
  String get notificationTypeScheduledFasting => 'Scheduled fasting';

  @override
  String get notificationTypeWeeklyPattern => 'Weekly pattern';

  @override
  String get notificationTypeSpecificDate => 'Specific date';

  @override
  String get notificationTypePostponed => 'Postponed';

  @override
  String get notificationTypeDailyRecurring => 'Daily recurring';

  @override
  String get beforeTaking => 'Before taking';

  @override
  String get afterTaking => 'After taking';

  @override
  String get basedOnActualDose => 'Based on actual dose';

  @override
  String get basedOnSchedule => 'Based on schedule';

  @override
  String today(int day, int month, int year) {
    return 'Today $day/$month/$year';
  }

  @override
  String tomorrow(int day, int month, int year) {
    return 'Tomorrow $day/$month/$year';
  }

  @override
  String get todayOrLater => 'Today or later';

  @override
  String get pastDueWarning => '⚠️ PAST DUE';

  @override
  String get batteryOptimizationMenu => '⚙️ Battery optimization';

  @override
  String get alarmsAndReminders => '⚙️ Alarms & reminders';

  @override
  String get notificationTypeScheduledFastingShort => 'Scheduled fasting';

  @override
  String get basedOnActualDoseShort => 'Based on actual dose';

  @override
  String get basedOnScheduleShort => 'Based on schedule';

  @override
  String pendingNotifications(int count) {
    return '📊 Pending notifications: $count';
  }

  @override
  String medicationsWithSchedulesInfo(int withSchedules, int total) {
    return '💊 Medications with schedules: $withSchedules/$total';
  }

  @override
  String get noSchedulesConfiguredWarning => '⚠️ No schedules configured';

  @override
  String medicationInfo(String name) {
    return '💊 $name';
  }

  @override
  String notificationType(String type) {
    return '📋 Type: $type';
  }

  @override
  String scheduleDate(String date) {
    return '📅 Date: $date';
  }

  @override
  String scheduleTime(String time) {
    return '⏰ Time: $time';
  }

  @override
  String notificationId(int id) {
    return 'ID: $id';
  }

  @override
  String get takenStatus => 'Taken';

  @override
  String get skippedStatus => 'Skipped';

  @override
  String durationEstimate(String name, String stock, int days) {
    return '$name\nStock: $stock\nEstimated duration: $days days';
  }

  @override
  String errorChanging(String error) {
    return 'Error changing status: $error';
  }

  @override
  String get testScheduled1Min => 'Test scheduled (1 min)';

  @override
  String get alarmsAndRemindersMenu => '⚙️ Alarms & reminders';

  @override
  String medicationStockInfo(String name, String stock) {
    return '$name\nStock: $stock';
  }

  @override
  String takenTodaySingle(String quantity, String unit, String time) {
    return 'Taken today: $quantity $unit at $time';
  }

  @override
  String takenTodayMultiple(int count, String quantity, String unit) {
    return 'Taken today: $count times ($quantity $unit)';
  }

  @override
  String get done => 'Done';

  @override
  String get suspended => 'Suspended';
}
