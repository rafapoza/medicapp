// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'MedicApp';

  @override
  String get navMedication => 'Medicació';

  @override
  String get navPillOrganizer => 'Pastiller';

  @override
  String get navMedicineCabinet => 'Farmaciola';

  @override
  String get navHistory => 'Historial';

  @override
  String get navSettings => 'Configuració';

  @override
  String get navInventory => 'Inventari';

  @override
  String get navMedicationShort => 'Inici';

  @override
  String get navPillOrganizerShort => 'Estoc';

  @override
  String get navMedicineCabinetShort => 'Farmaciola';

  @override
  String get navHistoryShort => 'Historial';

  @override
  String get navSettingsShort => 'Ajustos';

  @override
  String get navInventoryShort => 'Medicines';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnBack => 'Enrere';

  @override
  String get btnSave => 'Desar';

  @override
  String get btnCancel => 'Cancel·lar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnClose => 'Tancar';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get btnAccept => 'Acceptar';

  @override
  String get medicationTypePill => 'Pastilla';

  @override
  String get medicationTypeCapsule => 'Càpsula';

  @override
  String get medicationTypeTablet => 'Comprimit';

  @override
  String get medicationTypeSyrup => 'Xarop';

  @override
  String get medicationTypeDrops => 'Gotes';

  @override
  String get medicationTypeInjection => 'Injecció';

  @override
  String get medicationTypePatch => 'Pegat';

  @override
  String get medicationTypeInhaler => 'Inhalador';

  @override
  String get medicationTypeCream => 'Crema';

  @override
  String get medicationTypeOther => 'Altre';

  @override
  String get doseStatusTaken => 'Presa';

  @override
  String get doseStatusSkipped => 'Omesa';

  @override
  String get doseStatusPending => 'Pendent';

  @override
  String get durationContinuous => 'Continu';

  @override
  String get durationSpecificDates => 'Dates específiques';

  @override
  String get durationAsNeeded => 'Segons necessitat';

  @override
  String get mainScreenTitle => 'Els meus medicaments';

  @override
  String get mainScreenEmptyTitle => 'No hi ha medicaments registrats';

  @override
  String get mainScreenEmptySubtitle =>
      'Afegeix medicaments utilitzant el botó +';

  @override
  String get mainScreenTodayDoses => 'Preses d\'avui';

  @override
  String get mainScreenNoMedications => 'No tens medicaments actius';

  @override
  String get msgMedicationAdded => 'Medicament afegit correctament';

  @override
  String get msgMedicationUpdated => 'Medicament actualitzat correctament';

  @override
  String msgMedicationDeleted(String name) {
    return '$name eliminat correctament';
  }

  @override
  String get validationRequired => 'Aquest camp és obligatori';

  @override
  String get validationDuplicateMedication =>
      'Aquest medicament ja existeix a la teva llista';

  @override
  String get validationInvalidNumber => 'Introdueix un número vàlid';

  @override
  String validationMinValue(num min) {
    return 'El valor ha de ser major que $min';
  }

  @override
  String get pillOrganizerTitle => 'Pastiller';

  @override
  String get pillOrganizerTotal => 'Total';

  @override
  String get pillOrganizerLowStock => 'Estoc baix';

  @override
  String get pillOrganizerNoStock => 'Sense estoc';

  @override
  String get pillOrganizerAvailableStock => 'Estoc disponible';

  @override
  String get pillOrganizerMedicationsTitle => 'Medicaments';

  @override
  String get pillOrganizerEmptyTitle => 'No hi ha medicaments registrats';

  @override
  String get pillOrganizerEmptySubtitle =>
      'Afegeix medicaments per veure el teu pastiller';

  @override
  String get pillOrganizerCurrentStock => 'Estoc actual';

  @override
  String get pillOrganizerEstimatedDuration => 'Durada estimada';

  @override
  String get pillOrganizerDays => 'dies';

  @override
  String get medicineCabinetTitle => 'Farmaciola';

  @override
  String get medicineCabinetSearchHint => 'Buscar medicament...';

  @override
  String get medicineCabinetEmptyTitle => 'No hi ha medicaments registrats';

  @override
  String get medicineCabinetEmptySubtitle =>
      'Afegeix medicaments per veure la teva farmaciola';

  @override
  String get medicineCabinetPullToRefresh =>
      'Arrossega cap avall per recarregar';

  @override
  String get medicineCabinetNoResults => 'No s\'han trobat medicaments';

  @override
  String get medicineCabinetNoResultsHint =>
      'Prova amb un altre terme de cerca';

  @override
  String get medicineCabinetStock => 'Estoc:';

  @override
  String get medicineCabinetSuspended => 'Suspès';

  @override
  String get medicineCabinetTapToRegister => 'Toca per registrar';

  @override
  String get medicineCabinetResumeMedication => 'Reprendre medicació';

  @override
  String get medicineCabinetRegisterDose => 'Registrar presa';

  @override
  String get medicineCabinetRefillMedication => 'Recarregar medicament';

  @override
  String get medicineCabinetEditMedication => 'Editar medicament';

  @override
  String get medicineCabinetDeleteMedication => 'Eliminar medicament';

  @override
  String medicineCabinetRefillTitle(String name) {
    return 'Recarregar $name';
  }

  @override
  String medicineCabinetRegisterDoseTitle(String name) {
    return 'Registrar presa de $name';
  }

  @override
  String get medicineCabinetCurrentStock => 'Estoc actual:';

  @override
  String get medicineCabinetAddQuantity => 'Quantitat a afegir:';

  @override
  String get medicineCabinetAddQuantityLabel => 'Quantitat a agregar';

  @override
  String get medicineCabinetExample => 'Ex:';

  @override
  String get medicineCabinetLastRefill => 'Última recàrrega:';

  @override
  String get medicineCabinetRefillButton => 'Recarregar';

  @override
  String get medicineCabinetAvailableStock => 'Estoc disponible:';

  @override
  String get medicineCabinetDoseTaken => 'Quantitat presa';

  @override
  String get medicineCabinetRegisterButton => 'Registrar';

  @override
  String get medicineCabinetNewStock => 'Nou estoc:';

  @override
  String get medicineCabinetDeleteConfirmTitle => 'Eliminar medicament';

  @override
  String medicineCabinetDeleteConfirmMessage(String name) {
    return 'Estàs segur que vols eliminar \"$name\"?\n\nAquesta acció no es pot desfer i es perdrà tot l\'historial d\'aquest medicament.';
  }

  @override
  String get medicineCabinetNoStockAvailable =>
      'No hi ha estoc disponible d\'aquest medicament';

  @override
  String medicineCabinetInsufficientStock(
    String needed,
    String unit,
    String available,
  ) {
    return 'Estoc insuficient per aquesta presa\nNecessites: $needed $unit\nDisponible: $available';
  }

  @override
  String medicineCabinetRefillSuccess(
    String name,
    String amount,
    String unit,
    String newStock,
  ) {
    return 'Estoc de $name recarregat\nAfegit: $amount $unit\nNou estoc: $newStock';
  }

  @override
  String medicineCabinetDoseRegistered(
    String name,
    String amount,
    String unit,
    String remaining,
  ) {
    return 'Presa de $name registrada\nQuantitat: $amount $unit\nEstoc restant: $remaining';
  }

  @override
  String medicineCabinetDeleteSuccess(String name) {
    return '$name eliminat correctament';
  }

  @override
  String medicineCabinetResumeSuccess(String name) {
    return '$name reprès correctament\nNotificacions reprogramades';
  }

  @override
  String get doseHistoryTitle => 'Historial de preses';

  @override
  String get doseHistoryFilterTitle => 'Filtrar historial';

  @override
  String get doseHistoryMedicationLabel => 'Medicament:';

  @override
  String get doseHistoryAllMedications => 'Tots els medicaments';

  @override
  String get doseHistoryDateRangeLabel => 'Rang de dates:';

  @override
  String get doseHistoryClearDates => 'Netejar dates';

  @override
  String get doseHistoryApply => 'Aplicar';

  @override
  String get doseHistoryTotal => 'Total';

  @override
  String get doseHistoryTaken => 'Preses';

  @override
  String get doseHistorySkipped => 'Omeses';

  @override
  String get doseHistoryClear => 'Netejar';

  @override
  String doseHistoryEditEntry(String name) {
    return 'Editar registre de $name';
  }

  @override
  String get doseHistoryScheduledTime => 'Hora programada:';

  @override
  String get doseHistoryActualTime => 'Hora real:';

  @override
  String get doseHistoryStatus => 'Estat:';

  @override
  String get doseHistoryMarkAsSkipped => 'Marcar com a omesa';

  @override
  String get doseHistoryMarkAsTaken => 'Marcar com a presa';

  @override
  String get doseHistoryConfirmDelete => 'Confirmar eliminació';

  @override
  String get doseHistoryConfirmDeleteMessage =>
      'Estàs segur que vols eliminar aquest registre?';

  @override
  String get doseHistoryRecordDeleted => 'Registre eliminat correctament';

  @override
  String doseHistoryDeleteError(String error) {
    return 'Error en eliminar: $error';
  }

  @override
  String get addMedicationTitle => 'Afegir medicament';

  @override
  String stepIndicator(int current, int total) {
    return 'Pas $current de $total';
  }

  @override
  String get medicationInfoTitle => 'Informació del medicament';

  @override
  String get medicationInfoSubtitle =>
      'Comença proporcionant el nom i tipus de medicament';

  @override
  String get medicationNameLabel => 'Nom del medicament';

  @override
  String get medicationNameHint => 'Ex: Paracetamol';

  @override
  String get medicationTypeLabel => 'Tipus de medicament';

  @override
  String get validationMedicationName =>
      'Si us plau, introdueix el nom del medicament';

  @override
  String get medicationDurationTitle => 'Tipus de tractament';

  @override
  String get medicationDurationSubtitle => 'Com prendràs aquest medicament?';

  @override
  String get durationContinuousTitle => 'Tractament continu';

  @override
  String get durationContinuousDesc => 'Tots els dies, amb patró regular';

  @override
  String get durationUntilEmptyTitle => 'Fins acabar medicació';

  @override
  String get durationUntilEmptyDesc => 'Acaba quan s\'acabi l\'estoc';

  @override
  String get durationSpecificDatesTitle => 'Dates específiques';

  @override
  String get durationSpecificDatesDesc => 'Només dies concrets seleccionats';

  @override
  String get durationAsNeededTitle => 'Medicament ocasional';

  @override
  String get durationAsNeededDesc =>
      'Només quan sigui necessari, sense horaris';

  @override
  String get selectDatesButton => 'Seleccionar dates';

  @override
  String get selectDatesTitle => 'Selecciona les dates';

  @override
  String get selectDatesSubtitle =>
      'Tria els dies exactes en què prendràs el medicament';

  @override
  String dateSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates seleccionades',
      one: '1 data seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectDates => 'Si us plau, selecciona almenys una data';

  @override
  String get medicationDatesTitle => 'Dates del tractament';

  @override
  String get medicationDatesSubtitle =>
      'Quan començaràs i acabaràs aquest tractament?';

  @override
  String get medicationDatesHelp =>
      'Ambdues dates són opcionals. Si no les estableixes, el tractament començarà avui i no tindrà data límit.';

  @override
  String get startDateLabel => 'Data d\'inici';

  @override
  String get startDateOptional => 'Opcional';

  @override
  String get startDateDefault => 'Comença avui';

  @override
  String get endDateLabel => 'Data de fi';

  @override
  String get endDateDefault => 'Sense data límit';

  @override
  String get startDatePickerTitle => 'Data d\'inici del tractament';

  @override
  String get endDatePickerTitle => 'Data de fi del tractament';

  @override
  String get startTodayButton => 'Començar avui';

  @override
  String get noEndDateButton => 'Sense data límit';

  @override
  String treatmentDuration(int days) {
    return 'Tractament de $days dies';
  }

  @override
  String get medicationFrequencyTitle => 'Freqüència de medicació';

  @override
  String get medicationFrequencySubtitle =>
      'Cada quants dies has de prendre aquest medicament';

  @override
  String get frequencyDailyTitle => 'Tots els dies';

  @override
  String get frequencyDailyDesc => 'Medicació diària contínua';

  @override
  String get frequencyAlternateTitle => 'Dies alternats';

  @override
  String get frequencyAlternateDesc =>
      'Cada 2 dies des de l\'inici del tractament';

  @override
  String get frequencyWeeklyTitle => 'Dies de la setmana específics';

  @override
  String get frequencyWeeklyDesc =>
      'Selecciona quins dies prendre el medicament';

  @override
  String get selectWeeklyDaysButton => 'Seleccionar dies';

  @override
  String get selectWeeklyDaysTitle => 'Dies de la setmana';

  @override
  String get selectWeeklyDaysSubtitle =>
      'Selecciona els dies específics en què prendràs el medicament';

  @override
  String daySelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dies seleccionats',
      one: '1 dia seleccionat',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectWeekdays =>
      'Si us plau, selecciona els dies de la setmana';

  @override
  String get medicationDosageTitle => 'Configuració de dosis';

  @override
  String get medicationDosageSubtitle =>
      'Com prefereixes configurar les dosis diàries?';

  @override
  String get dosageFixedTitle => 'Tots els dies igual';

  @override
  String get dosageFixedDesc =>
      'Especifica cada quantes hores prendre el medicament';

  @override
  String get dosageCustomTitle => 'Personalitzat';

  @override
  String get dosageCustomDesc => 'Defineix el nombre de preses per dia';

  @override
  String get dosageIntervalLabel => 'Interval entre preses';

  @override
  String get dosageIntervalHelp => 'L\'interval ha de dividir 24 exactament';

  @override
  String get dosageIntervalFieldLabel => 'Cada quantes hores';

  @override
  String get dosageIntervalHint => 'Ex: 8';

  @override
  String get dosageIntervalUnit => 'hores';

  @override
  String get dosageIntervalValidValues =>
      'Valors vàlids: 1, 2, 3, 4, 6, 8, 12, 24';

  @override
  String get dosageTimesLabel => 'Nombre de preses al dia';

  @override
  String get dosageTimesHelp =>
      'Defineix quantes vegades al dia prendràs el medicament';

  @override
  String get dosageTimesFieldLabel => 'Preses per dia';

  @override
  String get dosageTimesHint => 'Ex: 3';

  @override
  String get dosageTimesUnit => 'preses';

  @override
  String get dosageTimesDescription => 'Nombre total de preses diàries';

  @override
  String get dosesPerDay => 'Preses per dia';

  @override
  String doseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preses',
      one: '1 presa',
    );
    return '$_temp0';
  }

  @override
  String get validationInvalidInterval =>
      'Si us plau, introdueix un interval vàlid';

  @override
  String get validationIntervalTooLarge =>
      'L\'interval no pot ser major a 24 hores';

  @override
  String get validationIntervalNotDivisor =>
      'L\'interval ha de dividir 24 exactament (1, 2, 3, 4, 6, 8, 12, 24)';

  @override
  String get validationInvalidDoseCount =>
      'Si us plau, introdueix un nombre de preses vàlid';

  @override
  String get validationTooManyDoses => 'No pots prendre més de 24 dosis al dia';

  @override
  String get medicationTimesTitle => 'Horari de preses';

  @override
  String dosesPerDayLabel(int count) {
    return 'Preses al dia: $count';
  }

  @override
  String frequencyEveryHours(int hours) {
    return 'Freqüència: Cada $hours hores';
  }

  @override
  String get selectTimeAndAmount =>
      'Selecciona l\'hora i quantitat de cada presa';

  @override
  String doseNumber(int number) {
    return 'Presa $number';
  }

  @override
  String get selectTimeButton => 'Seleccionar hora';

  @override
  String get amountPerDose => 'Quantitat per presa';

  @override
  String get amountHint => 'Ex: 1, 0.5, 2';

  @override
  String get removeDoseButton => 'Eliminar presa';

  @override
  String get validationSelectAllTimes =>
      'Si us plau, selecciona totes les hores de les preses';

  @override
  String get validationEnterValidAmounts =>
      'Si us plau, introdueix quantitats vàlides (majors a 0)';

  @override
  String get validationDuplicateTimes =>
      'Les hores de les preses no poden repetir-se';

  @override
  String get validationAtLeastOneDose =>
      'Ha d\'haver-hi almenys una presa al dia';

  @override
  String get medicationFastingTitle => 'Configuració de dejuni';

  @override
  String get fastingLabel => 'Dejuni';

  @override
  String get fastingHelp =>
      'Alguns medicaments requereixen dejuni abans o després de la presa';

  @override
  String get requiresFastingQuestion => 'Aquest medicament requereix dejuni?';

  @override
  String get fastingNo => 'No';

  @override
  String get fastingYes => 'Sí';

  @override
  String get fastingWhenQuestion => 'Quan és el dejuni?';

  @override
  String get fastingBefore => 'Abans de la presa';

  @override
  String get fastingAfter => 'Després de la presa';

  @override
  String get fastingDurationQuestion => 'Quant temps de dejuni?';

  @override
  String get fastingHours => 'Hores';

  @override
  String get fastingMinutes => 'Minuts';

  @override
  String get fastingNotificationsQuestion =>
      'Vols rebre notificacions de dejuni?';

  @override
  String get fastingNotificationBeforeHelp =>
      'Et notificarem quan hagis de deixar de menjar abans de la presa';

  @override
  String get fastingNotificationAfterHelp =>
      'Et notificarem quan puguis tornar a menjar després de la presa';

  @override
  String get fastingNotificationsOn => 'Notificacions activades';

  @override
  String get fastingNotificationsOff => 'Notificacions desactivades';

  @override
  String get validationCompleteAllFields =>
      'Si us plau, completa tots els camps';

  @override
  String get validationSelectFastingWhen =>
      'Si us plau, selecciona quan és el dejuni';

  @override
  String get validationFastingDuration =>
      'La durada del dejuni ha de ser almenys 1 minut';

  @override
  String get medicationQuantityTitle => 'Quantitat de medicament';

  @override
  String get medicationQuantitySubtitle =>
      'Estableix la quantitat disponible i quan vols rebre alertes';

  @override
  String get availableQuantityLabel => 'Quantitat disponible';

  @override
  String get availableQuantityHint => 'Ex: 30';

  @override
  String availableQuantityHelp(String unit) {
    return 'Quantitat de $unit que tens actualment';
  }

  @override
  String get lowStockAlertLabel => 'Avisar quan en quedin';

  @override
  String get lowStockAlertHint => 'Ex: 3';

  @override
  String get lowStockAlertUnit => 'dies';

  @override
  String get lowStockAlertHelp =>
      'Dies d\'antelació per rebre l\'alerta d\'estoc baix';

  @override
  String get validationEnterQuantity =>
      'Si us plau, introdueix la quantitat disponible';

  @override
  String get validationQuantityNonNegative =>
      'La quantitat ha de ser major o igual a 0';

  @override
  String get validationEnterAlertDays =>
      'Si us plau, introdueix els dies d\'antelació';

  @override
  String get validationAlertMinDays => 'Ha de ser almenys 1 dia';

  @override
  String get validationAlertMaxDays => 'No pot ser major a 30 dies';

  @override
  String get summaryTitle => 'Resum';

  @override
  String get summaryMedication => 'Medicament';

  @override
  String get summaryType => 'Tipus';

  @override
  String get summaryDosesPerDay => 'Preses al dia';

  @override
  String get summarySchedules => 'Horaris';

  @override
  String get summaryFrequency => 'Freqüència';

  @override
  String get summaryFrequencyDaily => 'Tots els dies';

  @override
  String get summaryFrequencyUntilEmpty => 'Fins acabar medicació';

  @override
  String summaryFrequencySpecificDates(int count) {
    return '$count dates específiques';
  }

  @override
  String summaryFrequencyWeekdays(int count) {
    return '$count dies de la setmana';
  }

  @override
  String summaryFrequencyEveryNDays(int days) {
    return 'Cada $days dies';
  }

  @override
  String get summaryFrequencyAsNeeded => 'Segons necessitat';

  @override
  String msgMedicationAddedSuccess(String name) {
    return '$name afegit correctament';
  }

  @override
  String msgMedicationAddError(String error) {
    return 'Error en desar el medicament: $error';
  }

  @override
  String get saveMedicationButton => 'Desar medicament';

  @override
  String get savingButton => 'Desant...';

  @override
  String get doseActionTitle => 'Acció de presa';

  @override
  String get doseActionLoading => 'Carregant...';

  @override
  String get doseActionError => 'Error';

  @override
  String get doseActionMedicationNotFound => 'Medicament no trobat';

  @override
  String get doseActionBack => 'Tornar';

  @override
  String doseActionScheduledTime(String time) {
    return 'Hora programada: $time';
  }

  @override
  String get doseActionThisDoseQuantity => 'Quantitat d\'aquesta presa';

  @override
  String get doseActionWhatToDo => 'Què vols fer?';

  @override
  String get doseActionRegisterTaken => 'Registrar presa';

  @override
  String get doseActionWillDeductStock => 'Descomptarà de l\'estoc';

  @override
  String get doseActionMarkAsNotTaken => 'Marcar com a no presa';

  @override
  String get doseActionWillNotDeductStock => 'No descomptarà de l\'estoc';

  @override
  String get doseActionPostpone15Min => 'Posposar 15 minuts';

  @override
  String get doseActionQuickReminder => 'Recordatori ràpid';

  @override
  String get doseActionPostponeCustom => 'Posposar (triar hora)';

  @override
  String doseActionInsufficientStock(
    String needed,
    String unit,
    String available,
  ) {
    return 'Estoc insuficient per aquesta presa\nNecessites: $needed $unit\nDisponible: $available';
  }

  @override
  String doseActionTakenRegistered(String name, String time, String stock) {
    return 'Presa de $name registrada a les $time\nEstoc restant: $stock';
  }

  @override
  String doseActionSkippedRegistered(String name, String time, String stock) {
    return 'Presa de $name marcada com a no presa a les $time\nEstoc: $stock (sense canvis)';
  }

  @override
  String doseActionPostponed(String name, String time) {
    return 'Presa de $name posposada\nNova hora: $time';
  }

  @override
  String doseActionPostponed15(String name, String time) {
    return 'Presa de $name posposada 15 minuts\nNova hora: $time';
  }

  @override
  String get editMedicationMenuTitle => 'Editar medicament';

  @override
  String get editMedicationMenuWhatToEdit => 'Què vols editar?';

  @override
  String get editMedicationMenuSelectSection =>
      'Selecciona la secció que vols modificar';

  @override
  String get editMedicationMenuBasicInfo => 'Informació bàsica';

  @override
  String get editMedicationMenuBasicInfoDesc => 'Nom i tipus de medicament';

  @override
  String get editMedicationMenuDuration => 'Durada del tractament';

  @override
  String get editMedicationMenuFrequency => 'Freqüència';

  @override
  String get editMedicationMenuSchedules => 'Horaris i quantitats';

  @override
  String editMedicationMenuSchedulesDesc(int count) {
    return '$count preses al dia';
  }

  @override
  String get editMedicationMenuFasting => 'Configuració de dejuni';

  @override
  String get editMedicationMenuQuantity => 'Quantitat disponible';

  @override
  String editMedicationMenuQuantityDesc(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get editMedicationMenuFreqEveryday => 'Tots els dies';

  @override
  String get editMedicationMenuFreqUntilFinished => 'Fins acabar medicació';

  @override
  String editMedicationMenuFreqSpecificDates(int count) {
    return '$count dates específiques';
  }

  @override
  String editMedicationMenuFreqWeeklyDays(int count) {
    return '$count dies de la setmana';
  }

  @override
  String editMedicationMenuFreqInterval(int interval) {
    return 'Cada $interval dies';
  }

  @override
  String get editMedicationMenuFreqNotDefined => 'Freqüència no definida';

  @override
  String get editMedicationMenuFastingNone => 'Sense dejuni';

  @override
  String editMedicationMenuFastingDuration(String duration, String type) {
    return 'Dejuni $duration $type';
  }

  @override
  String get editMedicationMenuFastingBefore => 'abans';

  @override
  String get editMedicationMenuFastingAfter => 'després';

  @override
  String get editBasicInfoTitle => 'Editar informació bàsica';

  @override
  String get editBasicInfoUpdated => 'Informació actualitzada correctament';

  @override
  String get editBasicInfoSaving => 'Desant...';

  @override
  String get editBasicInfoSaveChanges => 'Desar canvis';

  @override
  String editBasicInfoError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String get editDurationTitle => 'Editar durada';

  @override
  String get editDurationTypeLabel => 'Tipus de durada';

  @override
  String editDurationCurrentType(String type) {
    return 'Tipus actual: $type';
  }

  @override
  String get editDurationChangeTypeInfo =>
      'Per canviar el tipus de durada, edita la secció de \"Freqüència\"';

  @override
  String get editDurationTreatmentDates => 'Dates del tractament';

  @override
  String get editDurationStartDate => 'Data d\'inici';

  @override
  String get editDurationEndDate => 'Data de fi';

  @override
  String get editDurationNotSelected => 'No seleccionada';

  @override
  String editDurationDays(int days) {
    return 'Durada: $days dies';
  }

  @override
  String get editDurationSelectDates =>
      'Si us plau, selecciona les dates d\'inici i fi';

  @override
  String get editDurationUpdated => 'Durada actualitzada correctament';

  @override
  String editDurationError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String get editFastingTitle => 'Editar configuració de dejuni';

  @override
  String get editFastingCompleteFields => 'Si us plau, completa tots els camps';

  @override
  String get editFastingSelectWhen =>
      'Si us plau, selecciona quan és el dejuni';

  @override
  String get editFastingMinDuration =>
      'La durada del dejuni ha de ser almenys 1 minut';

  @override
  String get editFastingUpdated =>
      'Configuració de dejuni actualitzada correctament';

  @override
  String editFastingError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String get editFrequencyTitle => 'Editar freqüència';

  @override
  String get editFrequencyPattern => 'Patró de freqüència';

  @override
  String get editFrequencyQuestion =>
      'Amb quina freqüència prendràs aquest medicament?';

  @override
  String get editFrequencyEveryday => 'Tots els dies';

  @override
  String get editFrequencyEverydayDesc => 'Prendre el medicament diàriament';

  @override
  String get editFrequencyUntilFinished => 'Fins acabar';

  @override
  String get editFrequencyUntilFinishedDesc =>
      'Fins que s\'acabi el medicament';

  @override
  String get editFrequencySpecificDates => 'Dates específiques';

  @override
  String get editFrequencySpecificDatesDesc => 'Seleccionar dates concretes';

  @override
  String get editFrequencyWeeklyDays => 'Dies de la setmana';

  @override
  String get editFrequencyWeeklyDaysDesc =>
      'Seleccionar dies específics cada setmana';

  @override
  String get editFrequencyAlternateDays => 'Dies alternats';

  @override
  String get editFrequencyAlternateDaysDesc =>
      'Cada 2 dies des de l\'inici del tractament';

  @override
  String get editFrequencyCustomInterval => 'Interval personalitzat';

  @override
  String get editFrequencyCustomIntervalDesc => 'Cada N dies des de l\'inici';

  @override
  String get editFrequencySelectedDates => 'Dates seleccionades';

  @override
  String editFrequencyDatesCount(int count) {
    return '$count dates seleccionades';
  }

  @override
  String get editFrequencyNoDatesSelected => 'Cap data seleccionada';

  @override
  String get editFrequencySelectDatesButton => 'Seleccionar dates';

  @override
  String get editFrequencyWeeklyDaysLabel => 'Dies de la setmana';

  @override
  String editFrequencyWeeklyDaysCount(int count) {
    return '$count dies seleccionats';
  }

  @override
  String get editFrequencyNoDaysSelected => 'Cap dia seleccionat';

  @override
  String get editFrequencySelectDaysButton => 'Seleccionar dies';

  @override
  String get editFrequencyIntervalLabel => 'Interval de dies';

  @override
  String get editFrequencyIntervalField => 'Cada quants dies';

  @override
  String get editFrequencyIntervalHint => 'Ex: 3';

  @override
  String get editFrequencyIntervalHelp => 'Ha de ser almenys 2 dies';

  @override
  String get editFrequencySelectAtLeastOneDate =>
      'Si us plau, selecciona almenys una data';

  @override
  String get editFrequencySelectAtLeastOneDay =>
      'Si us plau, selecciona almenys un dia de la setmana';

  @override
  String get editFrequencyIntervalMin => 'L\'interval ha de ser almenys 2 dies';

  @override
  String get editFrequencyUpdated => 'Freqüència actualitzada correctament';

  @override
  String editFrequencyError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String get editQuantityTitle => 'Editar quantitat';

  @override
  String get editQuantityMedicationLabel => 'Quantitat de medicament';

  @override
  String get editQuantityDescription =>
      'Estableix la quantitat disponible i quan vols rebre alertes';

  @override
  String get editQuantityAvailableLabel => 'Quantitat disponible';

  @override
  String editQuantityAvailableHelp(String unit) {
    return 'Quantitat de $unit que tens actualment';
  }

  @override
  String get editQuantityValidationRequired =>
      'Si us plau, introdueix la quantitat disponible';

  @override
  String get editQuantityValidationMin =>
      'La quantitat ha de ser major o igual a 0';

  @override
  String get editQuantityThresholdLabel => 'Avisar quan en quedin';

  @override
  String get editQuantityThresholdHelp =>
      'Dies d\'antelació per rebre l\'alerta d\'estoc baix';

  @override
  String get editQuantityThresholdValidationRequired =>
      'Si us plau, introdueix els dies d\'antelació';

  @override
  String get editQuantityThresholdValidationMin => 'Ha de ser almenys 1 dia';

  @override
  String get editQuantityThresholdValidationMax => 'No pot ser major a 30 dies';

  @override
  String get editQuantityUpdated => 'Quantitat actualitzada correctament';

  @override
  String editQuantityError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String get editScheduleTitle => 'Editar horaris';

  @override
  String get editScheduleAddDose => 'Afegir presa';

  @override
  String get editScheduleValidationQuantities =>
      'Si us plau, introdueix quantitats vàlides (majors a 0)';

  @override
  String get editScheduleValidationDuplicates =>
      'Les hores de les preses no poden repetir-se';

  @override
  String get editScheduleUpdated => 'Horaris actualitzats correctament';

  @override
  String editScheduleError(String error) {
    return 'Error en desar canvis: $error';
  }

  @override
  String editScheduleDosesPerDay(int count) {
    return 'Preses al dia: $count';
  }

  @override
  String get editScheduleAdjustTimeAndQuantity =>
      'Ajusta l\'hora i quantitat de cada presa';

  @override
  String get specificDatesSelectorTitle => 'Dates específiques';

  @override
  String get specificDatesSelectorSelectDates => 'Selecciona dates';

  @override
  String get specificDatesSelectorDescription =>
      'Tria les dates específiques en què prendràs aquest medicament';

  @override
  String get specificDatesSelectorAddDate => 'Afegir data';

  @override
  String specificDatesSelectorSelectedDates(int count) {
    return 'Dates seleccionades ($count)';
  }

  @override
  String get specificDatesSelectorToday => 'AVUI';

  @override
  String get specificDatesSelectorContinue => 'Continuar';

  @override
  String get specificDatesSelectorAlreadySelected =>
      'Aquesta data ja està seleccionada';

  @override
  String get specificDatesSelectorSelectAtLeastOne =>
      'Selecciona almenys una data';

  @override
  String get specificDatesSelectorPickerHelp => 'Selecciona una data';

  @override
  String get specificDatesSelectorPickerCancel => 'Cancel·lar';

  @override
  String get specificDatesSelectorPickerConfirm => 'Acceptar';

  @override
  String get weeklyDaysSelectorTitle => 'Dies de la setmana';

  @override
  String get weeklyDaysSelectorSelectDays => 'Selecciona els dies';

  @override
  String get weeklyDaysSelectorDescription =>
      'Tria quins dies de la setmana prendràs aquest medicament';

  @override
  String weeklyDaysSelectorSelectedCount(int count, String plural) {
    return '$count dia$plural seleccionat$plural';
  }

  @override
  String get weeklyDaysSelectorContinue => 'Continuar';

  @override
  String get weeklyDaysSelectorSelectAtLeastOne =>
      'Selecciona almenys un dia de la setmana';

  @override
  String get weeklyDayMonday => 'Dilluns';

  @override
  String get weeklyDayTuesday => 'Dimarts';

  @override
  String get weeklyDayWednesday => 'Dimecres';

  @override
  String get weeklyDayThursday => 'Dijous';

  @override
  String get weeklyDayFriday => 'Divendres';

  @override
  String get weeklyDaySaturday => 'Dissabte';

  @override
  String get weeklyDaySunday => 'Diumenge';

  @override
  String get dateFromLabel => 'Des de';

  @override
  String get dateToLabel => 'Fins a';

  @override
  String get statisticsTitle => 'Estadístiques';

  @override
  String get adherenceLabel => 'Adherència';

  @override
  String get emptyDosesWithFilters => 'No hi ha preses amb aquests filtres';

  @override
  String get emptyDoses => 'No hi ha preses registrades';

  @override
  String get permissionRequired => 'Permís necessari';

  @override
  String get notNowButton => 'Ara no';

  @override
  String get openSettingsButton => 'Obrir configuració';

  @override
  String medicationUpdatedMsg(String name) {
    return '$name actualitzat';
  }

  @override
  String get noScheduledTimes => 'Aquest medicament no té horaris configurats';

  @override
  String get allDosesTakenToday => 'Ja has pres totes les dosis d\'avui';

  @override
  String get extraDoseOption => 'Presa extra';

  @override
  String extraDoseConfirmationMessage(String name) {
    return 'Ja has registrat totes les preses programades d\'avui. Vols registrar una presa extra de $name?';
  }

  @override
  String get extraDoseConfirm => 'Registrar presa extra';

  @override
  String extraDoseRegistered(String name, String time, String stock) {
    return 'Presa extra de $name registrada a les $time ($stock disponible)';
  }

  @override
  String registerDoseOfMedication(String name) {
    return 'Registrar presa de $name';
  }

  @override
  String refillMedicationTitle(String name) {
    return 'Recarregar $name';
  }

  @override
  String doseRegisteredAt(String time) {
    return 'Registrada a les $time';
  }

  @override
  String statusUpdatedTo(String status) {
    return 'Estat actualitzat a: $status';
  }

  @override
  String get dateLabel => 'Data:';

  @override
  String get scheduledTimeLabel => 'Hora programada:';

  @override
  String get currentStatusLabel => 'Estat actual:';

  @override
  String get changeStatusToQuestion => 'Canviar estat a:';

  @override
  String get filterApplied => 'Filtre aplicat';

  @override
  String filterFrom(String date) {
    return 'Des de $date';
  }

  @override
  String filterTo(String date) {
    return 'Fins a $date';
  }

  @override
  String get insufficientStockForDose =>
      'No hi ha prou estoc per marcar com a presa';

  @override
  String get settingsTitle => 'Configuració';

  @override
  String get settingsDisplaySection => 'Visualització';

  @override
  String get settingsShowActualTimeTitle => 'Mostrar hora real de presa';

  @override
  String get settingsShowActualTimeSubtitle =>
      'Mostra l\'hora real en què es van prendre les dosis en lloc de l\'hora programada';

  @override
  String get settingsShowFastingCountdownTitle =>
      'Mostrar compte enrere de dejuni';

  @override
  String get settingsShowFastingCountdownSubtitle =>
      'Mostra el temps restant de dejuni a la pantalla principal';

  @override
  String get settingsShowFastingNotificationTitle =>
      'Notificació fixa de compte enrere';

  @override
  String get settingsShowFastingNotificationSubtitle =>
      'Mostra una notificació fixa amb el temps restant de dejuni (només Android)';

  @override
  String get fastingNotificationTitle => 'Dejuni en curs';

  @override
  String fastingNotificationBody(
    String medication,
    String timeRemaining,
    String endTime,
  ) {
    return '$medication • $timeRemaining restants (fins a $endTime)';
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
    return 'Dejuni: $time restants (fins a les $endTime)';
  }

  @override
  String fastingUpcoming(String time, String endTime) {
    return 'Proper dejuni: $time (fins a les $endTime)';
  }

  @override
  String get settingsBackupSection => 'Còpia de Seguretat';

  @override
  String get settingsExportTitle => 'Exportar Base de Dades';

  @override
  String get settingsExportSubtitle =>
      'Desa una còpia de tots els teus medicaments i historial';

  @override
  String get settingsImportTitle => 'Importar Base de Dades';

  @override
  String get settingsImportSubtitle =>
      'Restaura una còpia de seguretat prèviament exportada';

  @override
  String get settingsInfoTitle => 'Informació';

  @override
  String get settingsInfoContent =>
      '• En exportar, es crearà un arxiu de còpia de seguretat que podràs desar al teu dispositiu o compartir.\n\n• En importar, totes les dades actuals seran reemplaçades per les de l\'arxiu seleccionat.\n\n• Es recomana fer còpies de seguretat regularment.';

  @override
  String get settingsShareText => 'Còpia de seguretat de MedicApp';

  @override
  String get settingsExportSuccess => 'Base de dades exportada correctament';

  @override
  String get settingsImportSuccess => 'Base de dades importada correctament';

  @override
  String settingsExportError(String error) {
    return 'Error en exportar: $error';
  }

  @override
  String settingsImportError(String error) {
    return 'Error en importar: $error';
  }

  @override
  String get settingsFilePathError =>
      'No s\'ha pogut obtenir la ruta de l\'arxiu';

  @override
  String get settingsImportDialogTitle => 'Importar Base de Dades';

  @override
  String get settingsImportDialogMessage =>
      'Aquesta acció reemplaçarà totes les teves dades actuals amb les dades de l\'arxiu importat.\n\nEstàs segur de continuar?';

  @override
  String get settingsRestartDialogTitle => 'Importació Completada';

  @override
  String get settingsRestartDialogMessage =>
      'La base de dades s\'ha importat correctament.\n\nSi us plau, reinicia l\'aplicació per veure els canvis.';

  @override
  String get settingsRestartDialogButton => 'Entès';

  @override
  String get notificationsWillNotWork =>
      'Las notificaciones NO funcionarán sin este permiso.';

  @override
  String get debugMenuActivated => 'Menú de depuración activado';

  @override
  String get debugMenuDeactivated => 'Menú de depuración desactivado';

  @override
  String nextDoseAt(String time) {
    return 'Próxima toma: $time';
  }

  @override
  String pendingDose(String time) {
    return '⚠️ Dosis pendiente: $time';
  }

  @override
  String nextDoseTomorrow(String time) {
    return 'Próxima toma: mañana a las $time';
  }

  @override
  String nextDoseOnDay(String dayName, int day, int month, String time) {
    return 'Próxima toma: $dayName $day/$month a las $time';
  }

  @override
  String get dayNameMon => 'Lun';

  @override
  String get dayNameTue => 'Mar';

  @override
  String get dayNameWed => 'Mié';

  @override
  String get dayNameThu => 'Jue';

  @override
  String get dayNameFri => 'Vie';

  @override
  String get dayNameSat => 'Sáb';

  @override
  String get dayNameSun => 'Dom';

  @override
  String get whichDoseDidYouTake => '¿Qué toma has tomado?';

  @override
  String insufficientStockForThisDose(
    String needed,
    String unit,
    String available,
  ) {
    return 'Stock insuficiente para esta toma\nNecesitas: $needed $unit\nDisponible: $available';
  }

  @override
  String doseRegisteredAtTime(String name, String time, String stock) {
    return 'Toma de $name registrada a las $time\nStock restante: $stock';
  }

  @override
  String get allDosesCompletedToday => '✓ Todas las tomas de hoy completadas';

  @override
  String remainingDosesToday(int count) {
    return 'Tomas restantes hoy: $count';
  }

  @override
  String manualDoseRegistered(
    String name,
    String quantity,
    String unit,
    String stock,
  ) {
    return 'Toma manual de $name registrada\nCantidad: $quantity $unit\nStock restante: $stock';
  }

  @override
  String medicationSuspended(String name) {
    return '$name suspendido\nNo se programarán más notificaciones';
  }

  @override
  String medicationReactivated(String name) {
    return '$name reactivado\nNotificaciones reprogramadas';
  }

  @override
  String currentStock(String stock) {
    return 'Stock actual: $stock';
  }

  @override
  String get quantityToAdd => 'Cantidad a agregar';

  @override
  String example(String example) {
    return 'Ej: $example';
  }

  @override
  String lastRefill(String amount, String unit) {
    return 'Última recarga: $amount $unit';
  }

  @override
  String get refillButton => 'Recargar';

  @override
  String stockRefilled(
    String name,
    String amount,
    String unit,
    String newStock,
  ) {
    return 'Stock de $name recargado\nAgregado: $amount $unit\nNuevo stock: $newStock';
  }

  @override
  String availableStock(String stock) {
    return 'Stock disponible: $stock';
  }

  @override
  String get quantityTaken => 'Cantidad tomada';

  @override
  String get registerButton => 'Registrar';

  @override
  String get registerManualDose => 'Registrar toma manual';

  @override
  String get refillMedication => 'Recargar medicamento';

  @override
  String get resumeMedication => 'Reactivar medicamento';

  @override
  String get suspendMedication => 'Suspender medicamento';

  @override
  String get editMedicationButton => 'Editar medicamento';

  @override
  String get deleteMedicationButton => 'Eliminar medicamento';

  @override
  String medicationDeletedShort(String name) {
    return '$name eliminado';
  }

  @override
  String get noMedicationsRegistered => 'No hay medicamentos registrados';

  @override
  String get addMedicationHint => 'Pulsa el botón + para añadir uno';

  @override
  String get pullToRefresh => 'Arrastra hacia abajo para recargar';

  @override
  String get batteryOptimizationWarning =>
      'Para que las notificaciones funcionen, desactiva las restricciones de batería:';

  @override
  String get batteryOptimizationInstructions =>
      'Ajustes → Aplicaciones → MedicApp → Batería → \"Sin restricciones\"';

  @override
  String get openSettings => 'Abrir ajustes';

  @override
  String get todayDosesLabel => 'Tomas de hoy:';

  @override
  String doseOfMedicationAt(String name, String time) {
    return 'Toma de $name a las $time';
  }

  @override
  String currentStatus(String status) {
    return 'Estado actual: $status';
  }

  @override
  String get whatDoYouWantToDo => '¿Qué deseas hacer?';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String get markAsSkipped => 'Marcar Omitida';

  @override
  String get markAsTaken => 'Marcar Tomada';

  @override
  String doseDeletedAt(String time) {
    return 'Toma de las $time eliminada';
  }

  @override
  String errorDeleting(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String doseMarkedAs(String time, String status) {
    return 'Toma de las $time marcada como $status';
  }

  @override
  String errorChangingStatus(String error) {
    return 'Error al cambiar estado: $error';
  }

  @override
  String medicationUpdatedShort(String name) {
    return '$name actualizado';
  }

  @override
  String get activateAlarmsPermission => 'Activar \"Alarmas y recordatorios\"';

  @override
  String get alarmsPermissionDescription =>
      'Este permiso permite que las notificaciones salten exactamente a la hora configurada.';

  @override
  String get notificationDebugTitle => 'Debug de Notificaciones';

  @override
  String notificationPermissions(String enabled) {
    return '✓ Permisos de notificaciones: $enabled';
  }

  @override
  String exactAlarmsAndroid12(String enabled) {
    return '⏰ Alarmas exactas (Android 12+): $enabled';
  }

  @override
  String get importantWarning => '⚠️ IMPORTANTE';

  @override
  String get withoutPermissionNoNotifications =>
      'Sin este permiso las notificaciones NO saltarán.';

  @override
  String get alarmsSettings =>
      'Ajustes → Aplicaciones → MedicApp → Alarmas y recordatorios';

  @override
  String pendingNotificationsCount(int count) {
    return '📊 Notificaciones pendientes: $count';
  }

  @override
  String medicationsWithSchedules(int withSchedules, int total) {
    return '💊 Medicamentos con horarios: $withSchedules/$total';
  }

  @override
  String get scheduledNotifications => 'Notificaciones programadas:';

  @override
  String get noScheduledNotifications => '⚠️ No hay notificaciones programadas';

  @override
  String get noTitle => 'Sin título';

  @override
  String get medicationsAndSchedules => 'Medicamentos y horarios:';

  @override
  String get noSchedulesConfigured => '⚠️ Sin horarios configurados';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get testNotification => 'Probar notificación';

  @override
  String get testNotificationSent => 'Notificación de prueba enviada';

  @override
  String get testScheduledNotification => 'Probar programada (1 min)';

  @override
  String get scheduledNotificationInOneMin =>
      'Notificación programada para 1 minuto';

  @override
  String get rescheduleNotifications => 'Reprogramar notificaciones';

  @override
  String get notificationsInfo => 'Info de notificaciones';

  @override
  String notificationsRescheduled(int count) {
    return 'Notificaciones reprogramadas: $count';
  }

  @override
  String get yesText => 'Sí';

  @override
  String get noText => 'No';

  @override
  String get notificationTypeDynamicFasting => 'Ayuno dinámico';

  @override
  String get notificationTypeScheduledFasting => 'Ayuno programado';

  @override
  String get notificationTypeWeeklyPattern => 'Patrón semanal';

  @override
  String get notificationTypeSpecificDate => 'Fecha específica';

  @override
  String get notificationTypePostponed => 'Pospuesta';

  @override
  String get notificationTypeDailyRecurring => 'Diaria recurrente';

  @override
  String get beforeTaking => 'Antes de tomar';

  @override
  String get afterTaking => 'Después de tomar';

  @override
  String get basedOnActualDose => 'Basado en toma real';

  @override
  String get basedOnSchedule => 'Basado en horario';

  @override
  String today(int day, int month, int year) {
    return 'Hoy $day/$month/$year';
  }

  @override
  String tomorrow(int day, int month, int year) {
    return 'Mañana $day/$month/$year';
  }

  @override
  String get todayOrLater => 'Hoy o posterior';

  @override
  String get pastDueWarning => '⚠️ PASADA';

  @override
  String get batteryOptimizationMenu => '⚙️ Optimización de batería';

  @override
  String get alarmsAndReminders => '⚙️ Alarmas y recordatorios';

  @override
  String get notificationTypeScheduledFastingShort => 'Ayuno programado';

  @override
  String get basedOnActualDoseShort => 'Basado en toma real';

  @override
  String get basedOnScheduleShort => 'Basado en horario';

  @override
  String pendingNotifications(int count) {
    return '📊 Notificaciones pendientes: $count';
  }

  @override
  String medicationsWithSchedulesInfo(int withSchedules, int total) {
    return '💊 Medicamentos con horarios: $withSchedules/$total';
  }

  @override
  String get noSchedulesConfiguredWarning => '⚠️ Sin horarios configurados';

  @override
  String medicationInfo(String name) {
    return '💊 $name';
  }

  @override
  String notificationType(String type) {
    return '📋 Tipo: $type';
  }

  @override
  String scheduleDate(String date) {
    return '📅 Fecha: $date';
  }

  @override
  String scheduleTime(String time) {
    return '⏰ Hora: $time';
  }

  @override
  String notificationId(int id) {
    return 'ID: $id';
  }

  @override
  String get takenStatus => 'Tomada';

  @override
  String get skippedStatus => 'Omitida';

  @override
  String durationEstimate(String name, String stock, int days) {
    return '$name\nStock: $stock\nDuración estimada: $days días';
  }

  @override
  String errorChanging(String error) {
    return 'Error al cambiar estado: $error';
  }

  @override
  String get testScheduled1Min => 'Probar programada (1 min)';

  @override
  String get alarmsAndRemindersMenu => '⚙️ Alarmas y recordatorios';

  @override
  String medicationStockInfo(String name, String stock) {
    return '$name\nStock: $stock';
  }

  @override
  String takenTodaySingle(String quantity, String unit, String time) {
    return 'Pres avui: $quantity $unit a les $time';
  }

  @override
  String takenTodayMultiple(int count, String quantity, String unit) {
    return 'Pres avui: $count vegades ($quantity $unit)';
  }

  @override
  String get done => 'Fet';

  @override
  String get suspended => 'Suspès';
}
