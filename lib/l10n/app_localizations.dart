import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_eu.dart';
import 'app_localizations_gl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
    Locale('eu'),
    Locale('gl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'MedicApp'**
  String get appTitle;

  /// No description provided for @navMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get navMedication;

  /// No description provided for @navPillOrganizer.
  ///
  /// In es, this message translates to:
  /// **'Pastillero'**
  String get navPillOrganizer;

  /// No description provided for @navMedicineCabinet.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get navMedicineCabinet;

  /// No description provided for @navHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistory;

  /// No description provided for @navSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get navSettings;

  /// No description provided for @navInventory.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get navInventory;

  /// No description provided for @navMedicationShort.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navMedicationShort;

  /// No description provided for @navPillOrganizerShort.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get navPillOrganizerShort;

  /// No description provided for @navMedicineCabinetShort.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get navMedicineCabinetShort;

  /// No description provided for @navHistoryShort.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get navHistoryShort;

  /// No description provided for @navSettingsShort.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get navSettingsShort;

  /// No description provided for @navInventoryShort.
  ///
  /// In es, this message translates to:
  /// **'Medicinas'**
  String get navInventoryShort;

  /// No description provided for @btnContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get btnContinue;

  /// No description provided for @btnBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get btnBack;

  /// No description provided for @btnSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get btnSave;

  /// No description provided for @btnCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get btnCancel;

  /// No description provided for @btnDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get btnDelete;

  /// No description provided for @btnEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get btnEdit;

  /// No description provided for @btnClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get btnClose;

  /// No description provided for @btnConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get btnConfirm;

  /// No description provided for @btnAccept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get btnAccept;

  /// No description provided for @medicationTypePill.
  ///
  /// In es, this message translates to:
  /// **'Pastilla'**
  String get medicationTypePill;

  /// No description provided for @medicationTypeCapsule.
  ///
  /// In es, this message translates to:
  /// **'Cápsula'**
  String get medicationTypeCapsule;

  /// No description provided for @medicationTypeTablet.
  ///
  /// In es, this message translates to:
  /// **'Comprimido'**
  String get medicationTypeTablet;

  /// No description provided for @medicationTypeSyrup.
  ///
  /// In es, this message translates to:
  /// **'Jarabe'**
  String get medicationTypeSyrup;

  /// No description provided for @medicationTypeDrops.
  ///
  /// In es, this message translates to:
  /// **'Gotas'**
  String get medicationTypeDrops;

  /// No description provided for @medicationTypeInjection.
  ///
  /// In es, this message translates to:
  /// **'Inyección'**
  String get medicationTypeInjection;

  /// No description provided for @medicationTypePatch.
  ///
  /// In es, this message translates to:
  /// **'Parche'**
  String get medicationTypePatch;

  /// No description provided for @medicationTypeInhaler.
  ///
  /// In es, this message translates to:
  /// **'Inhalador'**
  String get medicationTypeInhaler;

  /// No description provided for @medicationTypeCream.
  ///
  /// In es, this message translates to:
  /// **'Crema'**
  String get medicationTypeCream;

  /// No description provided for @medicationTypeOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get medicationTypeOther;

  /// No description provided for @doseStatusTaken.
  ///
  /// In es, this message translates to:
  /// **'Tomada'**
  String get doseStatusTaken;

  /// No description provided for @doseStatusSkipped.
  ///
  /// In es, this message translates to:
  /// **'Omitida'**
  String get doseStatusSkipped;

  /// No description provided for @doseStatusPending.
  ///
  /// In es, this message translates to:
  /// **'Pendiente'**
  String get doseStatusPending;

  /// No description provided for @durationContinuous.
  ///
  /// In es, this message translates to:
  /// **'Continuo'**
  String get durationContinuous;

  /// No description provided for @durationSpecificDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas específicas'**
  String get durationSpecificDates;

  /// No description provided for @durationAsNeeded.
  ///
  /// In es, this message translates to:
  /// **'Según necesidad'**
  String get durationAsNeeded;

  /// No description provided for @mainScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Medicamentos'**
  String get mainScreenTitle;

  /// No description provided for @mainScreenEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay medicamentos registrados'**
  String get mainScreenEmptyTitle;

  /// No description provided for @mainScreenEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade medicamentos usando el botón +'**
  String get mainScreenEmptySubtitle;

  /// No description provided for @mainScreenTodayDoses.
  ///
  /// In es, this message translates to:
  /// **'Tomas de hoy'**
  String get mainScreenTodayDoses;

  /// No description provided for @mainScreenNoMedications.
  ///
  /// In es, this message translates to:
  /// **'No tienes medicamentos activos'**
  String get mainScreenNoMedications;

  /// No description provided for @msgMedicationAdded.
  ///
  /// In es, this message translates to:
  /// **'Medicamento añadido correctamente'**
  String get msgMedicationAdded;

  /// No description provided for @msgMedicationUpdated.
  ///
  /// In es, this message translates to:
  /// **'Medicamento actualizado correctamente'**
  String get msgMedicationUpdated;

  /// No description provided for @msgMedicationDeleted.
  ///
  /// In es, this message translates to:
  /// **'{name} eliminado correctamente'**
  String msgMedicationDeleted(String name);

  /// No description provided for @validationRequired.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get validationRequired;

  /// No description provided for @validationDuplicateMedication.
  ///
  /// In es, this message translates to:
  /// **'Este medicamento ya existe en tu lista'**
  String get validationDuplicateMedication;

  /// No description provided for @validationInvalidNumber.
  ///
  /// In es, this message translates to:
  /// **'Introduce un número válido'**
  String get validationInvalidNumber;

  /// No description provided for @validationMinValue.
  ///
  /// In es, this message translates to:
  /// **'El valor debe ser mayor que {min}'**
  String validationMinValue(num min);

  /// No description provided for @pillOrganizerTitle.
  ///
  /// In es, this message translates to:
  /// **'Pastillero'**
  String get pillOrganizerTitle;

  /// No description provided for @pillOrganizerTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get pillOrganizerTotal;

  /// No description provided for @pillOrganizerLowStock.
  ///
  /// In es, this message translates to:
  /// **'Stock bajo'**
  String get pillOrganizerLowStock;

  /// No description provided for @pillOrganizerNoStock.
  ///
  /// In es, this message translates to:
  /// **'Sin stock'**
  String get pillOrganizerNoStock;

  /// No description provided for @pillOrganizerAvailableStock.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible'**
  String get pillOrganizerAvailableStock;

  /// No description provided for @pillOrganizerMedicationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Medicamentos'**
  String get pillOrganizerMedicationsTitle;

  /// No description provided for @pillOrganizerEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay medicamentos registrados'**
  String get pillOrganizerEmptyTitle;

  /// No description provided for @pillOrganizerEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade medicamentos para ver tu pastillero'**
  String get pillOrganizerEmptySubtitle;

  /// No description provided for @pillOrganizerCurrentStock.
  ///
  /// In es, this message translates to:
  /// **'Stock actual'**
  String get pillOrganizerCurrentStock;

  /// No description provided for @pillOrganizerEstimatedDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración estimada'**
  String get pillOrganizerEstimatedDuration;

  /// No description provided for @pillOrganizerDays.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get pillOrganizerDays;

  /// No description provided for @medicineCabinetTitle.
  ///
  /// In es, this message translates to:
  /// **'Botiquín'**
  String get medicineCabinetTitle;

  /// No description provided for @medicineCabinetSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar medicamento...'**
  String get medicineCabinetSearchHint;

  /// No description provided for @medicineCabinetEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay medicamentos registrados'**
  String get medicineCabinetEmptyTitle;

  /// No description provided for @medicineCabinetEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Añade medicamentos para ver tu botiquín'**
  String get medicineCabinetEmptySubtitle;

  /// No description provided for @medicineCabinetPullToRefresh.
  ///
  /// In es, this message translates to:
  /// **'Arrastra hacia abajo para recargar'**
  String get medicineCabinetPullToRefresh;

  /// No description provided for @medicineCabinetNoResults.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron medicamentos'**
  String get medicineCabinetNoResults;

  /// No description provided for @medicineCabinetNoResultsHint.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro término de búsqueda'**
  String get medicineCabinetNoResultsHint;

  /// No description provided for @medicineCabinetStock.
  ///
  /// In es, this message translates to:
  /// **'Stock:'**
  String get medicineCabinetStock;

  /// No description provided for @medicineCabinetSuspended.
  ///
  /// In es, this message translates to:
  /// **'Suspendido'**
  String get medicineCabinetSuspended;

  /// No description provided for @medicineCabinetTapToRegister.
  ///
  /// In es, this message translates to:
  /// **'Toca para registrar'**
  String get medicineCabinetTapToRegister;

  /// No description provided for @medicineCabinetResumeMedication.
  ///
  /// In es, this message translates to:
  /// **'Reanudar medicación'**
  String get medicineCabinetResumeMedication;

  /// No description provided for @medicineCabinetRegisterDose.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma'**
  String get medicineCabinetRegisterDose;

  /// No description provided for @medicineCabinetRefillMedication.
  ///
  /// In es, this message translates to:
  /// **'Recargar medicamento'**
  String get medicineCabinetRefillMedication;

  /// No description provided for @medicineCabinetEditMedication.
  ///
  /// In es, this message translates to:
  /// **'Editar medicamento'**
  String get medicineCabinetEditMedication;

  /// No description provided for @medicineCabinetDeleteMedication.
  ///
  /// In es, this message translates to:
  /// **'Eliminar medicamento'**
  String get medicineCabinetDeleteMedication;

  /// No description provided for @medicineCabinetRefillTitle.
  ///
  /// In es, this message translates to:
  /// **'Recargar {name}'**
  String medicineCabinetRefillTitle(String name);

  /// No description provided for @medicineCabinetRegisterDoseTitle.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma de {name}'**
  String medicineCabinetRegisterDoseTitle(String name);

  /// No description provided for @medicineCabinetCurrentStock.
  ///
  /// In es, this message translates to:
  /// **'Stock actual:'**
  String get medicineCabinetCurrentStock;

  /// No description provided for @medicineCabinetAddQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad a añadir:'**
  String get medicineCabinetAddQuantity;

  /// No description provided for @medicineCabinetAddQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad a agregar'**
  String get medicineCabinetAddQuantityLabel;

  /// No description provided for @medicineCabinetExample.
  ///
  /// In es, this message translates to:
  /// **'Ej:'**
  String get medicineCabinetExample;

  /// No description provided for @medicineCabinetLastRefill.
  ///
  /// In es, this message translates to:
  /// **'Última recarga:'**
  String get medicineCabinetLastRefill;

  /// No description provided for @medicineCabinetRefillButton.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get medicineCabinetRefillButton;

  /// No description provided for @medicineCabinetAvailableStock.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible:'**
  String get medicineCabinetAvailableStock;

  /// No description provided for @medicineCabinetDoseTaken.
  ///
  /// In es, this message translates to:
  /// **'Cantidad tomada'**
  String get medicineCabinetDoseTaken;

  /// No description provided for @medicineCabinetRegisterButton.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get medicineCabinetRegisterButton;

  /// No description provided for @medicineCabinetNewStock.
  ///
  /// In es, this message translates to:
  /// **'Nuevo stock:'**
  String get medicineCabinetNewStock;

  /// No description provided for @medicineCabinetDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar medicamento'**
  String get medicineCabinetDeleteConfirmTitle;

  /// No description provided for @medicineCabinetDeleteConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar \"{name}\"?\n\nEsta acción no se puede deshacer y se perderá todo el historial de este medicamento.'**
  String medicineCabinetDeleteConfirmMessage(String name);

  /// No description provided for @medicineCabinetNoStockAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay stock disponible de este medicamento'**
  String get medicineCabinetNoStockAvailable;

  /// No description provided for @medicineCabinetInsufficientStock.
  ///
  /// In es, this message translates to:
  /// **'Stock insuficiente para esta toma\nNecesitas: {needed} {unit}\nDisponible: {available}'**
  String medicineCabinetInsufficientStock(
    String needed,
    String unit,
    String available,
  );

  /// No description provided for @medicineCabinetRefillSuccess.
  ///
  /// In es, this message translates to:
  /// **'Stock de {name} recargado\nAgregado: {amount} {unit}\nNuevo stock: {newStock}'**
  String medicineCabinetRefillSuccess(
    String name,
    String amount,
    String unit,
    String newStock,
  );

  /// No description provided for @medicineCabinetDoseRegistered.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} registrada\nCantidad: {amount} {unit}\nStock restante: {remaining}'**
  String medicineCabinetDoseRegistered(
    String name,
    String amount,
    String unit,
    String remaining,
  );

  /// No description provided for @medicineCabinetDeleteSuccess.
  ///
  /// In es, this message translates to:
  /// **'{name} eliminado correctamente'**
  String medicineCabinetDeleteSuccess(String name);

  /// No description provided for @medicineCabinetResumeSuccess.
  ///
  /// In es, this message translates to:
  /// **'{name} reanudado correctamente\nNotificaciones reprogramadas'**
  String medicineCabinetResumeSuccess(String name);

  /// No description provided for @doseHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de Tomas'**
  String get doseHistoryTitle;

  /// No description provided for @doseHistoryFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar historial'**
  String get doseHistoryFilterTitle;

  /// No description provided for @doseHistoryMedicationLabel.
  ///
  /// In es, this message translates to:
  /// **'Medicamento:'**
  String get doseHistoryMedicationLabel;

  /// No description provided for @doseHistoryAllMedications.
  ///
  /// In es, this message translates to:
  /// **'Todos los medicamentos'**
  String get doseHistoryAllMedications;

  /// No description provided for @doseHistoryDateRangeLabel.
  ///
  /// In es, this message translates to:
  /// **'Rango de fechas:'**
  String get doseHistoryDateRangeLabel;

  /// No description provided for @doseHistoryClearDates.
  ///
  /// In es, this message translates to:
  /// **'Limpiar fechas'**
  String get doseHistoryClearDates;

  /// No description provided for @doseHistoryApply.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get doseHistoryApply;

  /// No description provided for @doseHistoryTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get doseHistoryTotal;

  /// No description provided for @doseHistoryTaken.
  ///
  /// In es, this message translates to:
  /// **'Tomadas'**
  String get doseHistoryTaken;

  /// No description provided for @doseHistorySkipped.
  ///
  /// In es, this message translates to:
  /// **'Omitidas'**
  String get doseHistorySkipped;

  /// No description provided for @doseHistoryClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get doseHistoryClear;

  /// No description provided for @doseHistoryEditEntry.
  ///
  /// In es, this message translates to:
  /// **'Editar registro de {name}'**
  String doseHistoryEditEntry(String name);

  /// No description provided for @doseHistoryScheduledTime.
  ///
  /// In es, this message translates to:
  /// **'Hora programada:'**
  String get doseHistoryScheduledTime;

  /// No description provided for @doseHistoryActualTime.
  ///
  /// In es, this message translates to:
  /// **'Hora real:'**
  String get doseHistoryActualTime;

  /// No description provided for @doseHistoryStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado:'**
  String get doseHistoryStatus;

  /// No description provided for @doseHistoryMarkAsSkipped.
  ///
  /// In es, this message translates to:
  /// **'Marcar como Omitida'**
  String get doseHistoryMarkAsSkipped;

  /// No description provided for @doseHistoryMarkAsTaken.
  ///
  /// In es, this message translates to:
  /// **'Marcar como Tomada'**
  String get doseHistoryMarkAsTaken;

  /// No description provided for @doseHistoryConfirmDelete.
  ///
  /// In es, this message translates to:
  /// **'Confirmar eliminación'**
  String get doseHistoryConfirmDelete;

  /// No description provided for @doseHistoryConfirmDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres eliminar este registro?'**
  String get doseHistoryConfirmDeleteMessage;

  /// No description provided for @doseHistoryRecordDeleted.
  ///
  /// In es, this message translates to:
  /// **'Registro eliminado correctamente'**
  String get doseHistoryRecordDeleted;

  /// No description provided for @doseHistoryDeleteError.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String doseHistoryDeleteError(String error);

  /// No description provided for @addMedicationTitle.
  ///
  /// In es, this message translates to:
  /// **'Añadir Medicamento'**
  String get addMedicationTitle;

  /// No description provided for @stepIndicator.
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String stepIndicator(int current, int total);

  /// No description provided for @medicationInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información del medicamento'**
  String get medicationInfoTitle;

  /// No description provided for @medicationInfoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Comienza proporcionando el nombre y tipo de medicamento'**
  String get medicationInfoSubtitle;

  /// No description provided for @medicationNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del medicamento'**
  String get medicationNameLabel;

  /// No description provided for @medicationNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: Paracetamol'**
  String get medicationNameHint;

  /// No description provided for @medicationTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de medicamento'**
  String get medicationTypeLabel;

  /// No description provided for @validationMedicationName.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce el nombre del medicamento'**
  String get validationMedicationName;

  /// No description provided for @medicationDurationTitle.
  ///
  /// In es, this message translates to:
  /// **'Tipo de Tratamiento'**
  String get medicationDurationTitle;

  /// No description provided for @medicationDurationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo vas a tomar este medicamento?'**
  String get medicationDurationSubtitle;

  /// No description provided for @durationContinuousTitle.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento continuo'**
  String get durationContinuousTitle;

  /// No description provided for @durationContinuousDesc.
  ///
  /// In es, this message translates to:
  /// **'Todos los días, con patrón regular'**
  String get durationContinuousDesc;

  /// No description provided for @durationUntilEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Hasta acabar medicación'**
  String get durationUntilEmptyTitle;

  /// No description provided for @durationUntilEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Termina cuando se acabe el stock'**
  String get durationUntilEmptyDesc;

  /// No description provided for @durationSpecificDatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Fechas específicas'**
  String get durationSpecificDatesTitle;

  /// No description provided for @durationSpecificDatesDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo días concretos seleccionados'**
  String get durationSpecificDatesDesc;

  /// No description provided for @durationAsNeededTitle.
  ///
  /// In es, this message translates to:
  /// **'Medicamento ocasional'**
  String get durationAsNeededTitle;

  /// No description provided for @durationAsNeededDesc.
  ///
  /// In es, this message translates to:
  /// **'Solo cuando sea necesario, sin horarios'**
  String get durationAsNeededDesc;

  /// No description provided for @selectDatesButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fechas'**
  String get selectDatesButton;

  /// No description provided for @selectDatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona las fechas'**
  String get selectDatesTitle;

  /// No description provided for @selectDatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige los días exactos en los que tomarás el medicamento'**
  String get selectDatesSubtitle;

  /// No description provided for @dateSelected.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 fecha seleccionada} other{{count} fechas seleccionadas}}'**
  String dateSelected(int count);

  /// No description provided for @validationSelectDates.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona al menos una fecha'**
  String get validationSelectDates;

  /// No description provided for @medicationDatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Fechas del Tratamiento'**
  String get medicationDatesTitle;

  /// No description provided for @medicationDatesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo comenzarás y terminarás este tratamiento?'**
  String get medicationDatesSubtitle;

  /// No description provided for @medicationDatesHelp.
  ///
  /// In es, this message translates to:
  /// **'Ambas fechas son opcionales. Si no las estableces, el tratamiento comenzará hoy y no tendrá fecha límite.'**
  String get medicationDatesHelp;

  /// No description provided for @startDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get startDateLabel;

  /// No description provided for @startDateOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get startDateOptional;

  /// No description provided for @startDateDefault.
  ///
  /// In es, this message translates to:
  /// **'Empieza hoy'**
  String get startDateDefault;

  /// No description provided for @endDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get endDateLabel;

  /// No description provided for @endDateDefault.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get endDateDefault;

  /// No description provided for @startDatePickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio del tratamiento'**
  String get startDatePickerTitle;

  /// No description provided for @endDatePickerTitle.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin del tratamiento'**
  String get endDatePickerTitle;

  /// No description provided for @startTodayButton.
  ///
  /// In es, this message translates to:
  /// **'Empezar hoy'**
  String get startTodayButton;

  /// No description provided for @noEndDateButton.
  ///
  /// In es, this message translates to:
  /// **'Sin fecha límite'**
  String get noEndDateButton;

  /// No description provided for @treatmentDuration.
  ///
  /// In es, this message translates to:
  /// **'Tratamiento de {days} días'**
  String treatmentDuration(int days);

  /// No description provided for @medicationFrequencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia de Medicación'**
  String get medicationFrequencyTitle;

  /// No description provided for @medicationFrequencySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Cada cuántos días debes tomar este medicamento'**
  String get medicationFrequencySubtitle;

  /// No description provided for @frequencyDailyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get frequencyDailyTitle;

  /// No description provided for @frequencyDailyDesc.
  ///
  /// In es, this message translates to:
  /// **'Medicación diaria continua'**
  String get frequencyDailyDesc;

  /// No description provided for @frequencyAlternateTitle.
  ///
  /// In es, this message translates to:
  /// **'Días alternos'**
  String get frequencyAlternateTitle;

  /// No description provided for @frequencyAlternateDesc.
  ///
  /// In es, this message translates to:
  /// **'Cada 2 días desde el inicio del tratamiento'**
  String get frequencyAlternateDesc;

  /// No description provided for @frequencyWeeklyTitle.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana específicos'**
  String get frequencyWeeklyTitle;

  /// No description provided for @frequencyWeeklyDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona qué días tomar el medicamento'**
  String get frequencyWeeklyDesc;

  /// No description provided for @selectWeeklyDaysButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar días'**
  String get selectWeeklyDaysButton;

  /// No description provided for @selectWeeklyDaysTitle.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get selectWeeklyDaysTitle;

  /// No description provided for @selectWeeklyDaysSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Selecciona los días específicos en los que tomarás el medicamento'**
  String get selectWeeklyDaysSubtitle;

  /// No description provided for @daySelected.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 día seleccionado} other{{count} días seleccionados}}'**
  String daySelected(int count);

  /// No description provided for @validationSelectWeekdays.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona los días de la semana'**
  String get validationSelectWeekdays;

  /// No description provided for @medicationDosageTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Dosis'**
  String get medicationDosageTitle;

  /// No description provided for @medicationDosageSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo prefieres configurar las dosis diarias?'**
  String get medicationDosageSubtitle;

  /// No description provided for @dosageFixedTitle.
  ///
  /// In es, this message translates to:
  /// **'Todos los días igual'**
  String get dosageFixedTitle;

  /// No description provided for @dosageFixedDesc.
  ///
  /// In es, this message translates to:
  /// **'Especifica cada cuántas horas tomar el medicamento'**
  String get dosageFixedDesc;

  /// No description provided for @dosageCustomTitle.
  ///
  /// In es, this message translates to:
  /// **'Personalizado'**
  String get dosageCustomTitle;

  /// No description provided for @dosageCustomDesc.
  ///
  /// In es, this message translates to:
  /// **'Define el número de tomas por día'**
  String get dosageCustomDesc;

  /// No description provided for @dosageIntervalLabel.
  ///
  /// In es, this message translates to:
  /// **'Intervalo entre tomas'**
  String get dosageIntervalLabel;

  /// No description provided for @dosageIntervalHelp.
  ///
  /// In es, this message translates to:
  /// **'El intervalo debe dividir 24 exactamente'**
  String get dosageIntervalHelp;

  /// No description provided for @dosageIntervalFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Cada cuántas horas'**
  String get dosageIntervalFieldLabel;

  /// No description provided for @dosageIntervalHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 8'**
  String get dosageIntervalHint;

  /// No description provided for @dosageIntervalUnit.
  ///
  /// In es, this message translates to:
  /// **'horas'**
  String get dosageIntervalUnit;

  /// No description provided for @dosageIntervalValidValues.
  ///
  /// In es, this message translates to:
  /// **'Valores válidos: 1, 2, 3, 4, 6, 8, 12, 24'**
  String get dosageIntervalValidValues;

  /// No description provided for @dosageTimesLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de tomas al día'**
  String get dosageTimesLabel;

  /// No description provided for @dosageTimesHelp.
  ///
  /// In es, this message translates to:
  /// **'Define cuántas veces al día tomarás el medicamento'**
  String get dosageTimesHelp;

  /// No description provided for @dosageTimesFieldLabel.
  ///
  /// In es, this message translates to:
  /// **'Tomas por día'**
  String get dosageTimesFieldLabel;

  /// No description provided for @dosageTimesHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 3'**
  String get dosageTimesHint;

  /// No description provided for @dosageTimesUnit.
  ///
  /// In es, this message translates to:
  /// **'tomas'**
  String get dosageTimesUnit;

  /// No description provided for @dosageTimesDescription.
  ///
  /// In es, this message translates to:
  /// **'Número total de tomas diarias'**
  String get dosageTimesDescription;

  /// No description provided for @dosesPerDay.
  ///
  /// In es, this message translates to:
  /// **'Tomas por día'**
  String get dosesPerDay;

  /// No description provided for @doseCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 toma} other{{count} tomas}}'**
  String doseCount(int count);

  /// No description provided for @validationInvalidInterval.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un intervalo válido'**
  String get validationInvalidInterval;

  /// No description provided for @validationIntervalTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El intervalo no puede ser mayor a 24 horas'**
  String get validationIntervalTooLarge;

  /// No description provided for @validationIntervalNotDivisor.
  ///
  /// In es, this message translates to:
  /// **'El intervalo debe dividir 24 exactamente (1, 2, 3, 4, 6, 8, 12, 24)'**
  String get validationIntervalNotDivisor;

  /// No description provided for @validationInvalidDoseCount.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce un número de tomas válido'**
  String get validationInvalidDoseCount;

  /// No description provided for @validationTooManyDoses.
  ///
  /// In es, this message translates to:
  /// **'No puedes tomar más de 24 dosis al día'**
  String get validationTooManyDoses;

  /// No description provided for @medicationTimesTitle.
  ///
  /// In es, this message translates to:
  /// **'Horario de Tomas'**
  String get medicationTimesTitle;

  /// No description provided for @dosesPerDayLabel.
  ///
  /// In es, this message translates to:
  /// **'Tomas al día: {count}'**
  String dosesPerDayLabel(int count);

  /// No description provided for @frequencyEveryHours.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia: Cada {hours} horas'**
  String frequencyEveryHours(int hours);

  /// No description provided for @selectTimeAndAmount.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la hora y cantidad de cada toma'**
  String get selectTimeAndAmount;

  /// No description provided for @doseNumber.
  ///
  /// In es, this message translates to:
  /// **'Toma {number}'**
  String doseNumber(int number);

  /// No description provided for @selectTimeButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar hora'**
  String get selectTimeButton;

  /// No description provided for @amountPerDose.
  ///
  /// In es, this message translates to:
  /// **'Cantidad por toma'**
  String get amountPerDose;

  /// No description provided for @amountHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 1, 0.5, 2'**
  String get amountHint;

  /// No description provided for @removeDoseButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar toma'**
  String get removeDoseButton;

  /// No description provided for @validationSelectAllTimes.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona todas las horas de las tomas'**
  String get validationSelectAllTimes;

  /// No description provided for @validationEnterValidAmounts.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa cantidades válidas (mayores a 0)'**
  String get validationEnterValidAmounts;

  /// No description provided for @validationDuplicateTimes.
  ///
  /// In es, this message translates to:
  /// **'Las horas de las tomas no pueden repetirse'**
  String get validationDuplicateTimes;

  /// No description provided for @validationAtLeastOneDose.
  ///
  /// In es, this message translates to:
  /// **'Debe haber al menos una toma al día'**
  String get validationAtLeastOneDose;

  /// No description provided for @medicationFastingTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Ayuno'**
  String get medicationFastingTitle;

  /// No description provided for @fastingLabel.
  ///
  /// In es, this message translates to:
  /// **'Ayuno'**
  String get fastingLabel;

  /// No description provided for @fastingHelp.
  ///
  /// In es, this message translates to:
  /// **'Algunos medicamentos requieren ayuno antes o después de la toma'**
  String get fastingHelp;

  /// No description provided for @requiresFastingQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Este medicamento requiere ayuno?'**
  String get requiresFastingQuestion;

  /// No description provided for @fastingNo.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get fastingNo;

  /// No description provided for @fastingYes.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get fastingYes;

  /// No description provided for @fastingWhenQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuándo es el ayuno?'**
  String get fastingWhenQuestion;

  /// No description provided for @fastingBefore.
  ///
  /// In es, this message translates to:
  /// **'Antes de la toma'**
  String get fastingBefore;

  /// No description provided for @fastingAfter.
  ///
  /// In es, this message translates to:
  /// **'Después de la toma'**
  String get fastingAfter;

  /// No description provided for @fastingDurationQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto tiempo de ayuno?'**
  String get fastingDurationQuestion;

  /// No description provided for @fastingHours.
  ///
  /// In es, this message translates to:
  /// **'Horas'**
  String get fastingHours;

  /// No description provided for @fastingMinutes.
  ///
  /// In es, this message translates to:
  /// **'Minutos'**
  String get fastingMinutes;

  /// No description provided for @fastingNotificationsQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas recibir notificaciones de ayuno?'**
  String get fastingNotificationsQuestion;

  /// No description provided for @fastingNotificationBeforeHelp.
  ///
  /// In es, this message translates to:
  /// **'Te notificaremos cuándo debes dejar de comer antes de la toma'**
  String get fastingNotificationBeforeHelp;

  /// No description provided for @fastingNotificationAfterHelp.
  ///
  /// In es, this message translates to:
  /// **'Te notificaremos cuándo puedes volver a comer después de la toma'**
  String get fastingNotificationAfterHelp;

  /// No description provided for @fastingNotificationsOn.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones activadas'**
  String get fastingNotificationsOn;

  /// No description provided for @fastingNotificationsOff.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones desactivadas'**
  String get fastingNotificationsOff;

  /// No description provided for @validationCompleteAllFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos'**
  String get validationCompleteAllFields;

  /// No description provided for @validationSelectFastingWhen.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona cuándo es el ayuno'**
  String get validationSelectFastingWhen;

  /// No description provided for @validationFastingDuration.
  ///
  /// In es, this message translates to:
  /// **'La duración del ayuno debe ser al menos 1 minuto'**
  String get validationFastingDuration;

  /// No description provided for @medicationQuantityTitle.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de Medicamento'**
  String get medicationQuantityTitle;

  /// No description provided for @medicationQuantitySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Establece la cantidad disponible y cuándo deseas recibir alertas'**
  String get medicationQuantitySubtitle;

  /// No description provided for @availableQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad disponible'**
  String get availableQuantityLabel;

  /// No description provided for @availableQuantityHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 30'**
  String get availableQuantityHint;

  /// No description provided for @availableQuantityHelp.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de {unit} que tienes actualmente'**
  String availableQuantityHelp(String unit);

  /// No description provided for @lowStockAlertLabel.
  ///
  /// In es, this message translates to:
  /// **'Avisar cuando queden'**
  String get lowStockAlertLabel;

  /// No description provided for @lowStockAlertHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 3'**
  String get lowStockAlertHint;

  /// No description provided for @lowStockAlertUnit.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get lowStockAlertUnit;

  /// No description provided for @lowStockAlertHelp.
  ///
  /// In es, this message translates to:
  /// **'Días de antelación para recibir la alerta de bajo stock'**
  String get lowStockAlertHelp;

  /// No description provided for @validationEnterQuantity.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce la cantidad disponible'**
  String get validationEnterQuantity;

  /// No description provided for @validationQuantityNonNegative.
  ///
  /// In es, this message translates to:
  /// **'La cantidad debe ser mayor o igual a 0'**
  String get validationQuantityNonNegative;

  /// No description provided for @validationEnterAlertDays.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce los días de antelación'**
  String get validationEnterAlertDays;

  /// No description provided for @validationAlertMinDays.
  ///
  /// In es, this message translates to:
  /// **'Debe ser al menos 1 día'**
  String get validationAlertMinDays;

  /// No description provided for @validationAlertMaxDays.
  ///
  /// In es, this message translates to:
  /// **'No puede ser mayor a 30 días'**
  String get validationAlertMaxDays;

  /// No description provided for @summaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get summaryTitle;

  /// No description provided for @summaryMedication.
  ///
  /// In es, this message translates to:
  /// **'Medicamento'**
  String get summaryMedication;

  /// No description provided for @summaryType.
  ///
  /// In es, this message translates to:
  /// **'Tipo'**
  String get summaryType;

  /// No description provided for @summaryDosesPerDay.
  ///
  /// In es, this message translates to:
  /// **'Tomas al día'**
  String get summaryDosesPerDay;

  /// No description provided for @summarySchedules.
  ///
  /// In es, this message translates to:
  /// **'Horarios'**
  String get summarySchedules;

  /// No description provided for @summaryFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get summaryFrequency;

  /// No description provided for @summaryFrequencyDaily.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get summaryFrequencyDaily;

  /// No description provided for @summaryFrequencyUntilEmpty.
  ///
  /// In es, this message translates to:
  /// **'Hasta acabar medicación'**
  String get summaryFrequencyUntilEmpty;

  /// No description provided for @summaryFrequencySpecificDates.
  ///
  /// In es, this message translates to:
  /// **'{count} fechas específicas'**
  String summaryFrequencySpecificDates(int count);

  /// No description provided for @summaryFrequencyWeekdays.
  ///
  /// In es, this message translates to:
  /// **'{count} días de la semana'**
  String summaryFrequencyWeekdays(int count);

  /// No description provided for @summaryFrequencyEveryNDays.
  ///
  /// In es, this message translates to:
  /// **'Cada {days} días'**
  String summaryFrequencyEveryNDays(int days);

  /// No description provided for @summaryFrequencyAsNeeded.
  ///
  /// In es, this message translates to:
  /// **'Según necesidad'**
  String get summaryFrequencyAsNeeded;

  /// No description provided for @msgMedicationAddedSuccess.
  ///
  /// In es, this message translates to:
  /// **'{name} añadido correctamente'**
  String msgMedicationAddedSuccess(String name);

  /// No description provided for @msgMedicationAddError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar el medicamento: {error}'**
  String msgMedicationAddError(String error);

  /// No description provided for @saveMedicationButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar Medicamento'**
  String get saveMedicationButton;

  /// No description provided for @savingButton.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get savingButton;

  /// No description provided for @doseActionTitle.
  ///
  /// In es, this message translates to:
  /// **'Acción de Toma'**
  String get doseActionTitle;

  /// No description provided for @doseActionLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get doseActionLoading;

  /// No description provided for @doseActionError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get doseActionError;

  /// No description provided for @doseActionMedicationNotFound.
  ///
  /// In es, this message translates to:
  /// **'Medicamento no encontrado'**
  String get doseActionMedicationNotFound;

  /// No description provided for @doseActionBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get doseActionBack;

  /// No description provided for @doseActionScheduledTime.
  ///
  /// In es, this message translates to:
  /// **'Hora programada: {time}'**
  String doseActionScheduledTime(String time);

  /// No description provided for @doseActionThisDoseQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de esta toma'**
  String get doseActionThisDoseQuantity;

  /// No description provided for @doseActionWhatToDo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué deseas hacer?'**
  String get doseActionWhatToDo;

  /// No description provided for @doseActionRegisterTaken.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma'**
  String get doseActionRegisterTaken;

  /// No description provided for @doseActionWillDeductStock.
  ///
  /// In es, this message translates to:
  /// **'Descontará del stock'**
  String get doseActionWillDeductStock;

  /// No description provided for @doseActionMarkAsNotTaken.
  ///
  /// In es, this message translates to:
  /// **'Marcar como no tomada'**
  String get doseActionMarkAsNotTaken;

  /// No description provided for @doseActionWillNotDeductStock.
  ///
  /// In es, this message translates to:
  /// **'No descontará del stock'**
  String get doseActionWillNotDeductStock;

  /// No description provided for @doseActionPostpone15Min.
  ///
  /// In es, this message translates to:
  /// **'Posponer 15 minutos'**
  String get doseActionPostpone15Min;

  /// No description provided for @doseActionQuickReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorio rápido'**
  String get doseActionQuickReminder;

  /// No description provided for @doseActionPostponeCustom.
  ///
  /// In es, this message translates to:
  /// **'Posponer (elegir hora)'**
  String get doseActionPostponeCustom;

  /// No description provided for @doseActionInsufficientStock.
  ///
  /// In es, this message translates to:
  /// **'Stock insuficiente para esta toma\nNecesitas: {needed} {unit}\nDisponible: {available}'**
  String doseActionInsufficientStock(
    String needed,
    String unit,
    String available,
  );

  /// No description provided for @doseActionTakenRegistered.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} registrada a las {time}\nStock restante: {stock}'**
  String doseActionTakenRegistered(String name, String time, String stock);

  /// No description provided for @doseActionSkippedRegistered.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} marcada como no tomada a las {time}\nStock: {stock} (sin cambios)'**
  String doseActionSkippedRegistered(String name, String time, String stock);

  /// No description provided for @doseActionPostponed.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} pospuesta\nNueva hora: {time}'**
  String doseActionPostponed(String name, String time);

  /// No description provided for @doseActionPostponed15.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} pospuesta 15 minutos\nNueva hora: {time}'**
  String doseActionPostponed15(String name, String time);

  /// No description provided for @editMedicationMenuTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Medicamento'**
  String get editMedicationMenuTitle;

  /// No description provided for @editMedicationMenuWhatToEdit.
  ///
  /// In es, this message translates to:
  /// **'¿Qué deseas editar?'**
  String get editMedicationMenuWhatToEdit;

  /// No description provided for @editMedicationMenuSelectSection.
  ///
  /// In es, this message translates to:
  /// **'Selecciona la sección que deseas modificar'**
  String get editMedicationMenuSelectSection;

  /// No description provided for @editMedicationMenuBasicInfo.
  ///
  /// In es, this message translates to:
  /// **'Información Básica'**
  String get editMedicationMenuBasicInfo;

  /// No description provided for @editMedicationMenuBasicInfoDesc.
  ///
  /// In es, this message translates to:
  /// **'Nombre y tipo de medicamento'**
  String get editMedicationMenuBasicInfoDesc;

  /// No description provided for @editMedicationMenuDuration.
  ///
  /// In es, this message translates to:
  /// **'Duración del Tratamiento'**
  String get editMedicationMenuDuration;

  /// No description provided for @editMedicationMenuFrequency.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia'**
  String get editMedicationMenuFrequency;

  /// No description provided for @editMedicationMenuSchedules.
  ///
  /// In es, this message translates to:
  /// **'Horarios y Cantidades'**
  String get editMedicationMenuSchedules;

  /// No description provided for @editMedicationMenuSchedulesDesc.
  ///
  /// In es, this message translates to:
  /// **'{count} tomas al día'**
  String editMedicationMenuSchedulesDesc(int count);

  /// No description provided for @editMedicationMenuFasting.
  ///
  /// In es, this message translates to:
  /// **'Configuración de Ayuno'**
  String get editMedicationMenuFasting;

  /// No description provided for @editMedicationMenuQuantity.
  ///
  /// In es, this message translates to:
  /// **'Cantidad Disponible'**
  String get editMedicationMenuQuantity;

  /// No description provided for @editMedicationMenuQuantityDesc.
  ///
  /// In es, this message translates to:
  /// **'{quantity} {unit}'**
  String editMedicationMenuQuantityDesc(String quantity, String unit);

  /// No description provided for @editMedicationMenuFreqEveryday.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get editMedicationMenuFreqEveryday;

  /// No description provided for @editMedicationMenuFreqUntilFinished.
  ///
  /// In es, this message translates to:
  /// **'Hasta acabar medicación'**
  String get editMedicationMenuFreqUntilFinished;

  /// No description provided for @editMedicationMenuFreqSpecificDates.
  ///
  /// In es, this message translates to:
  /// **'{count} fechas específicas'**
  String editMedicationMenuFreqSpecificDates(int count);

  /// No description provided for @editMedicationMenuFreqWeeklyDays.
  ///
  /// In es, this message translates to:
  /// **'{count} días de la semana'**
  String editMedicationMenuFreqWeeklyDays(int count);

  /// No description provided for @editMedicationMenuFreqInterval.
  ///
  /// In es, this message translates to:
  /// **'Cada {interval} días'**
  String editMedicationMenuFreqInterval(int interval);

  /// No description provided for @editMedicationMenuFreqNotDefined.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia no definida'**
  String get editMedicationMenuFreqNotDefined;

  /// No description provided for @editMedicationMenuFastingNone.
  ///
  /// In es, this message translates to:
  /// **'Sin ayuno'**
  String get editMedicationMenuFastingNone;

  /// No description provided for @editMedicationMenuFastingDuration.
  ///
  /// In es, this message translates to:
  /// **'Ayuno {duration} {type}'**
  String editMedicationMenuFastingDuration(String duration, String type);

  /// No description provided for @editMedicationMenuFastingBefore.
  ///
  /// In es, this message translates to:
  /// **'antes'**
  String get editMedicationMenuFastingBefore;

  /// No description provided for @editMedicationMenuFastingAfter.
  ///
  /// In es, this message translates to:
  /// **'después'**
  String get editMedicationMenuFastingAfter;

  /// No description provided for @editBasicInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Información Básica'**
  String get editBasicInfoTitle;

  /// No description provided for @editBasicInfoUpdated.
  ///
  /// In es, this message translates to:
  /// **'Información actualizada correctamente'**
  String get editBasicInfoUpdated;

  /// No description provided for @editBasicInfoSaving.
  ///
  /// In es, this message translates to:
  /// **'Guardando...'**
  String get editBasicInfoSaving;

  /// No description provided for @editBasicInfoSaveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get editBasicInfoSaveChanges;

  /// No description provided for @editBasicInfoError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editBasicInfoError(String error);

  /// No description provided for @editDurationTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Duración'**
  String get editDurationTitle;

  /// No description provided for @editDurationTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de duración'**
  String get editDurationTypeLabel;

  /// No description provided for @editDurationCurrentType.
  ///
  /// In es, this message translates to:
  /// **'Tipo actual: {type}'**
  String editDurationCurrentType(String type);

  /// No description provided for @editDurationChangeTypeInfo.
  ///
  /// In es, this message translates to:
  /// **'Para cambiar el tipo de duración, edita la sección de \"Frecuencia\"'**
  String get editDurationChangeTypeInfo;

  /// No description provided for @editDurationTreatmentDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas del tratamiento'**
  String get editDurationTreatmentDates;

  /// No description provided for @editDurationStartDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de inicio'**
  String get editDurationStartDate;

  /// No description provided for @editDurationEndDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha de fin'**
  String get editDurationEndDate;

  /// No description provided for @editDurationNotSelected.
  ///
  /// In es, this message translates to:
  /// **'No seleccionada'**
  String get editDurationNotSelected;

  /// No description provided for @editDurationDays.
  ///
  /// In es, this message translates to:
  /// **'Duración: {days} días'**
  String editDurationDays(int days);

  /// No description provided for @editDurationSelectDates.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona las fechas de inicio y fin'**
  String get editDurationSelectDates;

  /// No description provided for @editDurationUpdated.
  ///
  /// In es, this message translates to:
  /// **'Duración actualizada correctamente'**
  String get editDurationUpdated;

  /// No description provided for @editDurationError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editDurationError(String error);

  /// No description provided for @editFastingTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Configuración de Ayuno'**
  String get editFastingTitle;

  /// No description provided for @editFastingCompleteFields.
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos'**
  String get editFastingCompleteFields;

  /// No description provided for @editFastingSelectWhen.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona cuándo es el ayuno'**
  String get editFastingSelectWhen;

  /// No description provided for @editFastingMinDuration.
  ///
  /// In es, this message translates to:
  /// **'La duración del ayuno debe ser al menos 1 minuto'**
  String get editFastingMinDuration;

  /// No description provided for @editFastingUpdated.
  ///
  /// In es, this message translates to:
  /// **'Configuración de ayuno actualizada correctamente'**
  String get editFastingUpdated;

  /// No description provided for @editFastingError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editFastingError(String error);

  /// No description provided for @editFrequencyTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Frecuencia'**
  String get editFrequencyTitle;

  /// No description provided for @editFrequencyPattern.
  ///
  /// In es, this message translates to:
  /// **'Patrón de frecuencia'**
  String get editFrequencyPattern;

  /// No description provided for @editFrequencyQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Con qué frecuencia tomarás este medicamento?'**
  String get editFrequencyQuestion;

  /// No description provided for @editFrequencyEveryday.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get editFrequencyEveryday;

  /// No description provided for @editFrequencyEverydayDesc.
  ///
  /// In es, this message translates to:
  /// **'Tomar el medicamento diariamente'**
  String get editFrequencyEverydayDesc;

  /// No description provided for @editFrequencyUntilFinished.
  ///
  /// In es, this message translates to:
  /// **'Hasta acabar'**
  String get editFrequencyUntilFinished;

  /// No description provided for @editFrequencyUntilFinishedDesc.
  ///
  /// In es, this message translates to:
  /// **'Hasta que se termine el medicamento'**
  String get editFrequencyUntilFinishedDesc;

  /// No description provided for @editFrequencySpecificDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas específicas'**
  String get editFrequencySpecificDates;

  /// No description provided for @editFrequencySpecificDatesDesc.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fechas concretas'**
  String get editFrequencySpecificDatesDesc;

  /// No description provided for @editFrequencyWeeklyDays.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get editFrequencyWeeklyDays;

  /// No description provided for @editFrequencyWeeklyDaysDesc.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar días específicos cada semana'**
  String get editFrequencyWeeklyDaysDesc;

  /// No description provided for @editFrequencyAlternateDays.
  ///
  /// In es, this message translates to:
  /// **'Días alternos'**
  String get editFrequencyAlternateDays;

  /// No description provided for @editFrequencyAlternateDaysDesc.
  ///
  /// In es, this message translates to:
  /// **'Cada 2 días desde el inicio del tratamiento'**
  String get editFrequencyAlternateDaysDesc;

  /// No description provided for @editFrequencyCustomInterval.
  ///
  /// In es, this message translates to:
  /// **'Intervalo personalizado'**
  String get editFrequencyCustomInterval;

  /// No description provided for @editFrequencyCustomIntervalDesc.
  ///
  /// In es, this message translates to:
  /// **'Cada N días desde el inicio'**
  String get editFrequencyCustomIntervalDesc;

  /// No description provided for @editFrequencySelectedDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas seleccionadas'**
  String get editFrequencySelectedDates;

  /// No description provided for @editFrequencyDatesCount.
  ///
  /// In es, this message translates to:
  /// **'{count} fechas seleccionadas'**
  String editFrequencyDatesCount(int count);

  /// No description provided for @editFrequencyNoDatesSelected.
  ///
  /// In es, this message translates to:
  /// **'Ninguna fecha seleccionada'**
  String get editFrequencyNoDatesSelected;

  /// No description provided for @editFrequencySelectDatesButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar fechas'**
  String get editFrequencySelectDatesButton;

  /// No description provided for @editFrequencyWeeklyDaysLabel.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get editFrequencyWeeklyDaysLabel;

  /// No description provided for @editFrequencyWeeklyDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{count} días seleccionados'**
  String editFrequencyWeeklyDaysCount(int count);

  /// No description provided for @editFrequencyNoDaysSelected.
  ///
  /// In es, this message translates to:
  /// **'Ningún día seleccionado'**
  String get editFrequencyNoDaysSelected;

  /// No description provided for @editFrequencySelectDaysButton.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar días'**
  String get editFrequencySelectDaysButton;

  /// No description provided for @editFrequencyIntervalLabel.
  ///
  /// In es, this message translates to:
  /// **'Intervalo de días'**
  String get editFrequencyIntervalLabel;

  /// No description provided for @editFrequencyIntervalField.
  ///
  /// In es, this message translates to:
  /// **'Cada cuántos días'**
  String get editFrequencyIntervalField;

  /// No description provided for @editFrequencyIntervalHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 3'**
  String get editFrequencyIntervalHint;

  /// No description provided for @editFrequencyIntervalHelp.
  ///
  /// In es, this message translates to:
  /// **'Debe ser al menos 2 días'**
  String get editFrequencyIntervalHelp;

  /// No description provided for @editFrequencySelectAtLeastOneDate.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona al menos una fecha'**
  String get editFrequencySelectAtLeastOneDate;

  /// No description provided for @editFrequencySelectAtLeastOneDay.
  ///
  /// In es, this message translates to:
  /// **'Por favor, selecciona al menos un día de la semana'**
  String get editFrequencySelectAtLeastOneDay;

  /// No description provided for @editFrequencyIntervalMin.
  ///
  /// In es, this message translates to:
  /// **'El intervalo debe ser al menos 2 días'**
  String get editFrequencyIntervalMin;

  /// No description provided for @editFrequencyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Frecuencia actualizada correctamente'**
  String get editFrequencyUpdated;

  /// No description provided for @editFrequencyError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editFrequencyError(String error);

  /// No description provided for @editQuantityTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Cantidad'**
  String get editQuantityTitle;

  /// No description provided for @editQuantityMedicationLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de medicamento'**
  String get editQuantityMedicationLabel;

  /// No description provided for @editQuantityDescription.
  ///
  /// In es, this message translates to:
  /// **'Establece la cantidad disponible y cuándo deseas recibir alertas'**
  String get editQuantityDescription;

  /// No description provided for @editQuantityAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad disponible'**
  String get editQuantityAvailableLabel;

  /// No description provided for @editQuantityAvailableHelp.
  ///
  /// In es, this message translates to:
  /// **'Cantidad de {unit} que tienes actualmente'**
  String editQuantityAvailableHelp(String unit);

  /// No description provided for @editQuantityValidationRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce la cantidad disponible'**
  String get editQuantityValidationRequired;

  /// No description provided for @editQuantityValidationMin.
  ///
  /// In es, this message translates to:
  /// **'La cantidad debe ser mayor o igual a 0'**
  String get editQuantityValidationMin;

  /// No description provided for @editQuantityThresholdLabel.
  ///
  /// In es, this message translates to:
  /// **'Avisar cuando queden'**
  String get editQuantityThresholdLabel;

  /// No description provided for @editQuantityThresholdHelp.
  ///
  /// In es, this message translates to:
  /// **'Días de antelación para recibir la alerta de bajo stock'**
  String get editQuantityThresholdHelp;

  /// No description provided for @editQuantityThresholdValidationRequired.
  ///
  /// In es, this message translates to:
  /// **'Por favor, introduce los días de antelación'**
  String get editQuantityThresholdValidationRequired;

  /// No description provided for @editQuantityThresholdValidationMin.
  ///
  /// In es, this message translates to:
  /// **'Debe ser al menos 1 día'**
  String get editQuantityThresholdValidationMin;

  /// No description provided for @editQuantityThresholdValidationMax.
  ///
  /// In es, this message translates to:
  /// **'No puede ser mayor a 30 días'**
  String get editQuantityThresholdValidationMax;

  /// No description provided for @editQuantityUpdated.
  ///
  /// In es, this message translates to:
  /// **'Cantidad actualizada correctamente'**
  String get editQuantityUpdated;

  /// No description provided for @editQuantityError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editQuantityError(String error);

  /// No description provided for @editScheduleTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar Horarios'**
  String get editScheduleTitle;

  /// No description provided for @editScheduleAddDose.
  ///
  /// In es, this message translates to:
  /// **'Añadir toma'**
  String get editScheduleAddDose;

  /// No description provided for @editScheduleValidationQuantities.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa cantidades válidas (mayores a 0)'**
  String get editScheduleValidationQuantities;

  /// No description provided for @editScheduleValidationDuplicates.
  ///
  /// In es, this message translates to:
  /// **'Las horas de las tomas no pueden repetirse'**
  String get editScheduleValidationDuplicates;

  /// No description provided for @editScheduleUpdated.
  ///
  /// In es, this message translates to:
  /// **'Horarios actualizados correctamente'**
  String get editScheduleUpdated;

  /// No description provided for @editScheduleError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios: {error}'**
  String editScheduleError(String error);

  /// No description provided for @editScheduleDosesPerDay.
  ///
  /// In es, this message translates to:
  /// **'Tomas al día: {count}'**
  String editScheduleDosesPerDay(int count);

  /// No description provided for @editScheduleAdjustTimeAndQuantity.
  ///
  /// In es, this message translates to:
  /// **'Ajusta la hora y cantidad de cada toma'**
  String get editScheduleAdjustTimeAndQuantity;

  /// No description provided for @specificDatesSelectorTitle.
  ///
  /// In es, this message translates to:
  /// **'Fechas específicas'**
  String get specificDatesSelectorTitle;

  /// No description provided for @specificDatesSelectorSelectDates.
  ///
  /// In es, this message translates to:
  /// **'Selecciona fechas'**
  String get specificDatesSelectorSelectDates;

  /// No description provided for @specificDatesSelectorDescription.
  ///
  /// In es, this message translates to:
  /// **'Elige las fechas específicas en las que tomarás este medicamento'**
  String get specificDatesSelectorDescription;

  /// No description provided for @specificDatesSelectorAddDate.
  ///
  /// In es, this message translates to:
  /// **'Añadir fecha'**
  String get specificDatesSelectorAddDate;

  /// No description provided for @specificDatesSelectorSelectedDates.
  ///
  /// In es, this message translates to:
  /// **'Fechas seleccionadas ({count})'**
  String specificDatesSelectorSelectedDates(int count);

  /// No description provided for @specificDatesSelectorToday.
  ///
  /// In es, this message translates to:
  /// **'HOY'**
  String get specificDatesSelectorToday;

  /// No description provided for @specificDatesSelectorContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get specificDatesSelectorContinue;

  /// No description provided for @specificDatesSelectorAlreadySelected.
  ///
  /// In es, this message translates to:
  /// **'Esta fecha ya está seleccionada'**
  String get specificDatesSelectorAlreadySelected;

  /// No description provided for @specificDatesSelectorSelectAtLeastOne.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos una fecha'**
  String get specificDatesSelectorSelectAtLeastOne;

  /// No description provided for @specificDatesSelectorPickerHelp.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una fecha'**
  String get specificDatesSelectorPickerHelp;

  /// No description provided for @specificDatesSelectorPickerCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get specificDatesSelectorPickerCancel;

  /// No description provided for @specificDatesSelectorPickerConfirm.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get specificDatesSelectorPickerConfirm;

  /// No description provided for @weeklyDaysSelectorTitle.
  ///
  /// In es, this message translates to:
  /// **'Días de la semana'**
  String get weeklyDaysSelectorTitle;

  /// No description provided for @weeklyDaysSelectorSelectDays.
  ///
  /// In es, this message translates to:
  /// **'Selecciona los días'**
  String get weeklyDaysSelectorSelectDays;

  /// No description provided for @weeklyDaysSelectorDescription.
  ///
  /// In es, this message translates to:
  /// **'Elige qué días de la semana tomarás este medicamento'**
  String get weeklyDaysSelectorDescription;

  /// No description provided for @weeklyDaysSelectorSelectedCount.
  ///
  /// In es, this message translates to:
  /// **'{count} día{plural} seleccionado{plural}'**
  String weeklyDaysSelectorSelectedCount(int count, String plural);

  /// No description provided for @weeklyDaysSelectorContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get weeklyDaysSelectorContinue;

  /// No description provided for @weeklyDaysSelectorSelectAtLeastOne.
  ///
  /// In es, this message translates to:
  /// **'Selecciona al menos un día de la semana'**
  String get weeklyDaysSelectorSelectAtLeastOne;

  /// No description provided for @weeklyDayMonday.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get weeklyDayMonday;

  /// No description provided for @weeklyDayTuesday.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get weeklyDayTuesday;

  /// No description provided for @weeklyDayWednesday.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get weeklyDayWednesday;

  /// No description provided for @weeklyDayThursday.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get weeklyDayThursday;

  /// No description provided for @weeklyDayFriday.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get weeklyDayFriday;

  /// No description provided for @weeklyDaySaturday.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get weeklyDaySaturday;

  /// No description provided for @weeklyDaySunday.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get weeklyDaySunday;

  /// No description provided for @dateFromLabel.
  ///
  /// In es, this message translates to:
  /// **'Desde'**
  String get dateFromLabel;

  /// No description provided for @dateToLabel.
  ///
  /// In es, this message translates to:
  /// **'Hasta'**
  String get dateToLabel;

  /// No description provided for @statisticsTitle.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statisticsTitle;

  /// No description provided for @adherenceLabel.
  ///
  /// In es, this message translates to:
  /// **'Adherencia'**
  String get adherenceLabel;

  /// No description provided for @emptyDosesWithFilters.
  ///
  /// In es, this message translates to:
  /// **'No hay tomas con estos filtros'**
  String get emptyDosesWithFilters;

  /// No description provided for @emptyDoses.
  ///
  /// In es, this message translates to:
  /// **'No hay tomas registradas'**
  String get emptyDoses;

  /// No description provided for @permissionRequired.
  ///
  /// In es, this message translates to:
  /// **'Permiso necesario'**
  String get permissionRequired;

  /// No description provided for @notNowButton.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get notNowButton;

  /// No description provided for @openSettingsButton.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get openSettingsButton;

  /// No description provided for @medicationUpdatedMsg.
  ///
  /// In es, this message translates to:
  /// **'{name} actualizado'**
  String medicationUpdatedMsg(String name);

  /// No description provided for @noScheduledTimes.
  ///
  /// In es, this message translates to:
  /// **'Este medicamento no tiene horarios configurados'**
  String get noScheduledTimes;

  /// No description provided for @allDosesTakenToday.
  ///
  /// In es, this message translates to:
  /// **'Ya has tomado todas las dosis de hoy'**
  String get allDosesTakenToday;

  /// No description provided for @extraDoseOption.
  ///
  /// In es, this message translates to:
  /// **'Toma extra'**
  String get extraDoseOption;

  /// No description provided for @extraDoseConfirmationMessage.
  ///
  /// In es, this message translates to:
  /// **'Ya has registrado todas las tomas programadas de hoy. ¿Quieres registrar una toma extra de {name}?'**
  String extraDoseConfirmationMessage(String name);

  /// No description provided for @extraDoseConfirm.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma extra'**
  String get extraDoseConfirm;

  /// No description provided for @extraDoseRegistered.
  ///
  /// In es, this message translates to:
  /// **'Toma extra de {name} registrada a las {time} ({stock} disponible)'**
  String extraDoseRegistered(String name, String time, String stock);

  /// No description provided for @registerDoseOfMedication.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma de {name}'**
  String registerDoseOfMedication(String name);

  /// No description provided for @refillMedicationTitle.
  ///
  /// In es, this message translates to:
  /// **'Recargar {name}'**
  String refillMedicationTitle(String name);

  /// No description provided for @doseRegisteredAt.
  ///
  /// In es, this message translates to:
  /// **'Registrada a las {time}'**
  String doseRegisteredAt(String time);

  /// No description provided for @statusUpdatedTo.
  ///
  /// In es, this message translates to:
  /// **'Estado actualizado a: {status}'**
  String statusUpdatedTo(String status);

  /// No description provided for @dateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha:'**
  String get dateLabel;

  /// No description provided for @scheduledTimeLabel.
  ///
  /// In es, this message translates to:
  /// **'Hora programada:'**
  String get scheduledTimeLabel;

  /// No description provided for @currentStatusLabel.
  ///
  /// In es, this message translates to:
  /// **'Estado actual:'**
  String get currentStatusLabel;

  /// No description provided for @changeStatusToQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cambiar estado a:'**
  String get changeStatusToQuestion;

  /// No description provided for @filterApplied.
  ///
  /// In es, this message translates to:
  /// **'Filtro aplicado'**
  String get filterApplied;

  /// No description provided for @filterFrom.
  ///
  /// In es, this message translates to:
  /// **'Desde {date}'**
  String filterFrom(String date);

  /// No description provided for @filterTo.
  ///
  /// In es, this message translates to:
  /// **'Hasta {date}'**
  String filterTo(String date);

  /// No description provided for @insufficientStockForDose.
  ///
  /// In es, this message translates to:
  /// **'No hay suficiente stock para marcar como tomada'**
  String get insufficientStockForDose;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @settingsDisplaySection.
  ///
  /// In es, this message translates to:
  /// **'Visualización'**
  String get settingsDisplaySection;

  /// No description provided for @settingsShowActualTimeTitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar hora real de toma'**
  String get settingsShowActualTimeTitle;

  /// No description provided for @settingsShowActualTimeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra la hora real en que se tomaron las dosis en lugar de la hora programada'**
  String get settingsShowActualTimeSubtitle;

  /// No description provided for @settingsShowFastingCountdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Mostrar cuenta atrás de ayuno'**
  String get settingsShowFastingCountdownTitle;

  /// No description provided for @settingsShowFastingCountdownSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra el tiempo restante de ayuno en la pantalla principal'**
  String get settingsShowFastingCountdownSubtitle;

  /// No description provided for @settingsShowFastingNotificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificación fija de cuenta atrás'**
  String get settingsShowFastingNotificationTitle;

  /// No description provided for @settingsShowFastingNotificationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Muestra una notificación fija con el tiempo restante de ayuno (solo Android)'**
  String get settingsShowFastingNotificationSubtitle;

  /// No description provided for @fastingNotificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ayuno en curso'**
  String get fastingNotificationTitle;

  /// No description provided for @fastingNotificationBody.
  ///
  /// In es, this message translates to:
  /// **'{medication} • {timeRemaining} restantes (hasta {endTime})'**
  String fastingNotificationBody(
    String medication,
    String timeRemaining,
    String endTime,
  );

  /// No description provided for @fastingRemainingMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String fastingRemainingMinutes(int minutes);

  /// No description provided for @fastingRemainingHours.
  ///
  /// In es, this message translates to:
  /// **'{hours}h'**
  String fastingRemainingHours(int hours);

  /// No description provided for @fastingRemainingHoursMinutes.
  ///
  /// In es, this message translates to:
  /// **'{hours}h {minutes}m'**
  String fastingRemainingHoursMinutes(int hours, int minutes);

  /// No description provided for @fastingActive.
  ///
  /// In es, this message translates to:
  /// **'Ayuno: {time} restantes (hasta las {endTime})'**
  String fastingActive(String time, String endTime);

  /// No description provided for @fastingUpcoming.
  ///
  /// In es, this message translates to:
  /// **'Próximo ayuno: {time} (hasta las {endTime})'**
  String fastingUpcoming(String time, String endTime);

  /// No description provided for @settingsBackupSection.
  ///
  /// In es, this message translates to:
  /// **'Copia de Seguridad'**
  String get settingsBackupSection;

  /// No description provided for @settingsExportTitle.
  ///
  /// In es, this message translates to:
  /// **'Exportar Base de Datos'**
  String get settingsExportTitle;

  /// No description provided for @settingsExportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Guarda una copia de todos tus medicamentos e historial'**
  String get settingsExportSubtitle;

  /// No description provided for @settingsImportTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar Base de Datos'**
  String get settingsImportTitle;

  /// No description provided for @settingsImportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Restaura una copia de seguridad previamente exportada'**
  String get settingsImportSubtitle;

  /// No description provided for @settingsInfoTitle.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get settingsInfoTitle;

  /// No description provided for @settingsInfoContent.
  ///
  /// In es, this message translates to:
  /// **'• Al exportar, se creará un archivo de copia de seguridad que podrás guardar en tu dispositivo o compartir.\n\n• Al importar, todos los datos actuales serán reemplazados por los del archivo seleccionado.\n\n• Se recomienda hacer copias de seguridad regularmente.'**
  String get settingsInfoContent;

  /// No description provided for @settingsShareText.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad de MedicApp'**
  String get settingsShareText;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Base de datos exportada correctamente'**
  String get settingsExportSuccess;

  /// No description provided for @settingsImportSuccess.
  ///
  /// In es, this message translates to:
  /// **'Base de datos importada correctamente'**
  String get settingsImportSuccess;

  /// No description provided for @settingsExportError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar: {error}'**
  String settingsExportError(String error);

  /// No description provided for @settingsImportError.
  ///
  /// In es, this message translates to:
  /// **'Error al importar: {error}'**
  String settingsImportError(String error);

  /// No description provided for @settingsFilePathError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener la ruta del archivo'**
  String get settingsFilePathError;

  /// No description provided for @settingsImportDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Importar Base de Datos'**
  String get settingsImportDialogTitle;

  /// No description provided for @settingsImportDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción reemplazará todos tus datos actuales con los datos del archivo importado.\n\n¿Estás seguro de continuar?'**
  String get settingsImportDialogMessage;

  /// No description provided for @settingsRestartDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Importación Completada'**
  String get settingsRestartDialogTitle;

  /// No description provided for @settingsRestartDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'La base de datos se ha importado correctamente.\n\nPor favor, reinicia la aplicación para ver los cambios.'**
  String get settingsRestartDialogMessage;

  /// No description provided for @settingsRestartDialogButton.
  ///
  /// In es, this message translates to:
  /// **'Entendido'**
  String get settingsRestartDialogButton;

  /// No description provided for @notificationsWillNotWork.
  ///
  /// In es, this message translates to:
  /// **'Las notificaciones NO funcionarán sin este permiso.'**
  String get notificationsWillNotWork;

  /// No description provided for @debugMenuActivated.
  ///
  /// In es, this message translates to:
  /// **'Menú de depuración activado'**
  String get debugMenuActivated;

  /// No description provided for @debugMenuDeactivated.
  ///
  /// In es, this message translates to:
  /// **'Menú de depuración desactivado'**
  String get debugMenuDeactivated;

  /// No description provided for @nextDoseAt.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma: {time}'**
  String nextDoseAt(String time);

  /// No description provided for @pendingDose.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Dosis pendiente: {time}'**
  String pendingDose(String time);

  /// No description provided for @nextDoseTomorrow.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma: mañana a las {time}'**
  String nextDoseTomorrow(String time);

  /// No description provided for @nextDoseOnDay.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma: {dayName} {day}/{month} a las {time}'**
  String nextDoseOnDay(String dayName, int day, int month, String time);

  /// No description provided for @dayNameMon.
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get dayNameMon;

  /// No description provided for @dayNameTue.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get dayNameTue;

  /// No description provided for @dayNameWed.
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get dayNameWed;

  /// No description provided for @dayNameThu.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get dayNameThu;

  /// No description provided for @dayNameFri.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get dayNameFri;

  /// No description provided for @dayNameSat.
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get dayNameSat;

  /// No description provided for @dayNameSun.
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get dayNameSun;

  /// No description provided for @whichDoseDidYouTake.
  ///
  /// In es, this message translates to:
  /// **'¿Qué toma has tomado?'**
  String get whichDoseDidYouTake;

  /// No description provided for @insufficientStockForThisDose.
  ///
  /// In es, this message translates to:
  /// **'Stock insuficiente para esta toma\nNecesitas: {needed} {unit}\nDisponible: {available}'**
  String insufficientStockForThisDose(
    String needed,
    String unit,
    String available,
  );

  /// No description provided for @doseRegisteredAtTime.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} registrada a las {time}\nStock restante: {stock}'**
  String doseRegisteredAtTime(String name, String time, String stock);

  /// No description provided for @allDosesCompletedToday.
  ///
  /// In es, this message translates to:
  /// **'✓ Todas las tomas de hoy completadas'**
  String get allDosesCompletedToday;

  /// No description provided for @remainingDosesToday.
  ///
  /// In es, this message translates to:
  /// **'Tomas restantes hoy: {count}'**
  String remainingDosesToday(int count);

  /// No description provided for @manualDoseRegistered.
  ///
  /// In es, this message translates to:
  /// **'Toma manual de {name} registrada\nCantidad: {quantity} {unit}\nStock restante: {stock}'**
  String manualDoseRegistered(
    String name,
    String quantity,
    String unit,
    String stock,
  );

  /// No description provided for @medicationSuspended.
  ///
  /// In es, this message translates to:
  /// **'{name} suspendido\nNo se programarán más notificaciones'**
  String medicationSuspended(String name);

  /// No description provided for @medicationReactivated.
  ///
  /// In es, this message translates to:
  /// **'{name} reactivado\nNotificaciones reprogramadas'**
  String medicationReactivated(String name);

  /// No description provided for @currentStock.
  ///
  /// In es, this message translates to:
  /// **'Stock actual: {stock}'**
  String currentStock(String stock);

  /// No description provided for @quantityToAdd.
  ///
  /// In es, this message translates to:
  /// **'Cantidad a agregar'**
  String get quantityToAdd;

  /// No description provided for @example.
  ///
  /// In es, this message translates to:
  /// **'Ej: {example}'**
  String example(String example);

  /// No description provided for @lastRefill.
  ///
  /// In es, this message translates to:
  /// **'Última recarga: {amount} {unit}'**
  String lastRefill(String amount, String unit);

  /// No description provided for @refillButton.
  ///
  /// In es, this message translates to:
  /// **'Recargar'**
  String get refillButton;

  /// No description provided for @stockRefilled.
  ///
  /// In es, this message translates to:
  /// **'Stock de {name} recargado\nAgregado: {amount} {unit}\nNuevo stock: {newStock}'**
  String stockRefilled(
    String name,
    String amount,
    String unit,
    String newStock,
  );

  /// No description provided for @availableStock.
  ///
  /// In es, this message translates to:
  /// **'Stock disponible: {stock}'**
  String availableStock(String stock);

  /// No description provided for @quantityTaken.
  ///
  /// In es, this message translates to:
  /// **'Cantidad tomada'**
  String get quantityTaken;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrar'**
  String get registerButton;

  /// No description provided for @registerManualDose.
  ///
  /// In es, this message translates to:
  /// **'Registrar toma manual'**
  String get registerManualDose;

  /// No description provided for @refillMedication.
  ///
  /// In es, this message translates to:
  /// **'Recargar medicamento'**
  String get refillMedication;

  /// No description provided for @resumeMedication.
  ///
  /// In es, this message translates to:
  /// **'Reactivar medicamento'**
  String get resumeMedication;

  /// No description provided for @suspendMedication.
  ///
  /// In es, this message translates to:
  /// **'Suspender medicamento'**
  String get suspendMedication;

  /// No description provided for @editMedicationButton.
  ///
  /// In es, this message translates to:
  /// **'Editar medicamento'**
  String get editMedicationButton;

  /// No description provided for @deleteMedicationButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar medicamento'**
  String get deleteMedicationButton;

  /// No description provided for @medicationDeletedShort.
  ///
  /// In es, this message translates to:
  /// **'{name} eliminado'**
  String medicationDeletedShort(String name);

  /// No description provided for @noMedicationsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay medicamentos registrados'**
  String get noMedicationsRegistered;

  /// No description provided for @addMedicationHint.
  ///
  /// In es, this message translates to:
  /// **'Pulsa el botón + para añadir uno'**
  String get addMedicationHint;

  /// No description provided for @pullToRefresh.
  ///
  /// In es, this message translates to:
  /// **'Arrastra hacia abajo para recargar'**
  String get pullToRefresh;

  /// No description provided for @batteryOptimizationWarning.
  ///
  /// In es, this message translates to:
  /// **'Para que las notificaciones funcionen, desactiva las restricciones de batería:'**
  String get batteryOptimizationWarning;

  /// No description provided for @batteryOptimizationInstructions.
  ///
  /// In es, this message translates to:
  /// **'Ajustes → Aplicaciones → MedicApp → Batería → \"Sin restricciones\"'**
  String get batteryOptimizationInstructions;

  /// No description provided for @openSettings.
  ///
  /// In es, this message translates to:
  /// **'Abrir ajustes'**
  String get openSettings;

  /// No description provided for @todayDosesLabel.
  ///
  /// In es, this message translates to:
  /// **'Tomas de hoy:'**
  String get todayDosesLabel;

  /// No description provided for @doseOfMedicationAt.
  ///
  /// In es, this message translates to:
  /// **'Toma de {name} a las {time}'**
  String doseOfMedicationAt(String name, String time);

  /// No description provided for @currentStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado actual: {status}'**
  String currentStatus(String status);

  /// No description provided for @whatDoYouWantToDo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué deseas hacer?'**
  String get whatDoYouWantToDo;

  /// No description provided for @deleteButton.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteButton;

  /// No description provided for @markAsSkipped.
  ///
  /// In es, this message translates to:
  /// **'Marcar Omitida'**
  String get markAsSkipped;

  /// No description provided for @markAsTaken.
  ///
  /// In es, this message translates to:
  /// **'Marcar Tomada'**
  String get markAsTaken;

  /// No description provided for @doseDeletedAt.
  ///
  /// In es, this message translates to:
  /// **'Toma de las {time} eliminada'**
  String doseDeletedAt(String time);

  /// No description provided for @errorDeleting.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar: {error}'**
  String errorDeleting(String error);

  /// No description provided for @doseMarkedAs.
  ///
  /// In es, this message translates to:
  /// **'Toma de las {time} marcada como {status}'**
  String doseMarkedAs(String time, String status);

  /// No description provided for @errorChangingStatus.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar estado: {error}'**
  String errorChangingStatus(String error);

  /// No description provided for @medicationUpdatedShort.
  ///
  /// In es, this message translates to:
  /// **'{name} actualizado'**
  String medicationUpdatedShort(String name);

  /// No description provided for @activateAlarmsPermission.
  ///
  /// In es, this message translates to:
  /// **'Activar \"Alarmas y recordatorios\"'**
  String get activateAlarmsPermission;

  /// No description provided for @alarmsPermissionDescription.
  ///
  /// In es, this message translates to:
  /// **'Este permiso permite que las notificaciones salten exactamente a la hora configurada.'**
  String get alarmsPermissionDescription;

  /// No description provided for @notificationDebugTitle.
  ///
  /// In es, this message translates to:
  /// **'Debug de Notificaciones'**
  String get notificationDebugTitle;

  /// No description provided for @notificationPermissions.
  ///
  /// In es, this message translates to:
  /// **'✓ Permisos de notificaciones: {enabled}'**
  String notificationPermissions(String enabled);

  /// No description provided for @exactAlarmsAndroid12.
  ///
  /// In es, this message translates to:
  /// **'⏰ Alarmas exactas (Android 12+): {enabled}'**
  String exactAlarmsAndroid12(String enabled);

  /// No description provided for @importantWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠️ IMPORTANTE'**
  String get importantWarning;

  /// No description provided for @withoutPermissionNoNotifications.
  ///
  /// In es, this message translates to:
  /// **'Sin este permiso las notificaciones NO saltarán.'**
  String get withoutPermissionNoNotifications;

  /// No description provided for @alarmsSettings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes → Aplicaciones → MedicApp → Alarmas y recordatorios'**
  String get alarmsSettings;

  /// No description provided for @pendingNotificationsCount.
  ///
  /// In es, this message translates to:
  /// **'📊 Notificaciones pendientes: {count}'**
  String pendingNotificationsCount(int count);

  /// No description provided for @medicationsWithSchedules.
  ///
  /// In es, this message translates to:
  /// **'💊 Medicamentos con horarios: {withSchedules}/{total}'**
  String medicationsWithSchedules(int withSchedules, int total);

  /// No description provided for @scheduledNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones programadas:'**
  String get scheduledNotifications;

  /// No description provided for @noScheduledNotifications.
  ///
  /// In es, this message translates to:
  /// **'⚠️ No hay notificaciones programadas'**
  String get noScheduledNotifications;

  /// No description provided for @noTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin título'**
  String get noTitle;

  /// No description provided for @medicationsAndSchedules.
  ///
  /// In es, this message translates to:
  /// **'Medicamentos y horarios:'**
  String get medicationsAndSchedules;

  /// No description provided for @noSchedulesConfigured.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Sin horarios configurados'**
  String get noSchedulesConfigured;

  /// No description provided for @closeButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeButton;

  /// No description provided for @testNotification.
  ///
  /// In es, this message translates to:
  /// **'Probar notificación'**
  String get testNotification;

  /// No description provided for @testNotificationSent.
  ///
  /// In es, this message translates to:
  /// **'Notificación de prueba enviada'**
  String get testNotificationSent;

  /// No description provided for @testScheduledNotification.
  ///
  /// In es, this message translates to:
  /// **'Probar programada (1 min)'**
  String get testScheduledNotification;

  /// No description provided for @scheduledNotificationInOneMin.
  ///
  /// In es, this message translates to:
  /// **'Notificación programada para 1 minuto'**
  String get scheduledNotificationInOneMin;

  /// No description provided for @rescheduleNotifications.
  ///
  /// In es, this message translates to:
  /// **'Reprogramar notificaciones'**
  String get rescheduleNotifications;

  /// No description provided for @notificationsInfo.
  ///
  /// In es, this message translates to:
  /// **'Info de notificaciones'**
  String get notificationsInfo;

  /// No description provided for @notificationsRescheduled.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones reprogramadas: {count}'**
  String notificationsRescheduled(int count);

  /// No description provided for @yesText.
  ///
  /// In es, this message translates to:
  /// **'Sí'**
  String get yesText;

  /// No description provided for @noText.
  ///
  /// In es, this message translates to:
  /// **'No'**
  String get noText;

  /// No description provided for @notificationTypeDynamicFasting.
  ///
  /// In es, this message translates to:
  /// **'Ayuno dinámico'**
  String get notificationTypeDynamicFasting;

  /// No description provided for @notificationTypeScheduledFasting.
  ///
  /// In es, this message translates to:
  /// **'Ayuno programado'**
  String get notificationTypeScheduledFasting;

  /// No description provided for @notificationTypeWeeklyPattern.
  ///
  /// In es, this message translates to:
  /// **'Patrón semanal'**
  String get notificationTypeWeeklyPattern;

  /// No description provided for @notificationTypeSpecificDate.
  ///
  /// In es, this message translates to:
  /// **'Fecha específica'**
  String get notificationTypeSpecificDate;

  /// No description provided for @notificationTypePostponed.
  ///
  /// In es, this message translates to:
  /// **'Pospuesta'**
  String get notificationTypePostponed;

  /// No description provided for @notificationTypeDailyRecurring.
  ///
  /// In es, this message translates to:
  /// **'Diaria recurrente'**
  String get notificationTypeDailyRecurring;

  /// No description provided for @beforeTaking.
  ///
  /// In es, this message translates to:
  /// **'Antes de tomar'**
  String get beforeTaking;

  /// No description provided for @afterTaking.
  ///
  /// In es, this message translates to:
  /// **'Después de tomar'**
  String get afterTaking;

  /// No description provided for @basedOnActualDose.
  ///
  /// In es, this message translates to:
  /// **'Basado en toma real'**
  String get basedOnActualDose;

  /// No description provided for @basedOnSchedule.
  ///
  /// In es, this message translates to:
  /// **'Basado en horario'**
  String get basedOnSchedule;

  /// No description provided for @today.
  ///
  /// In es, this message translates to:
  /// **'Hoy {day}/{month}/{year}'**
  String today(int day, int month, int year);

  /// No description provided for @tomorrow.
  ///
  /// In es, this message translates to:
  /// **'Mañana {day}/{month}/{year}'**
  String tomorrow(int day, int month, int year);

  /// No description provided for @todayOrLater.
  ///
  /// In es, this message translates to:
  /// **'Hoy o posterior'**
  String get todayOrLater;

  /// No description provided for @pastDueWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠️ PASADA'**
  String get pastDueWarning;

  /// No description provided for @batteryOptimizationMenu.
  ///
  /// In es, this message translates to:
  /// **'⚙️ Optimización de batería'**
  String get batteryOptimizationMenu;

  /// No description provided for @alarmsAndReminders.
  ///
  /// In es, this message translates to:
  /// **'⚙️ Alarmas y recordatorios'**
  String get alarmsAndReminders;

  /// No description provided for @notificationTypeScheduledFastingShort.
  ///
  /// In es, this message translates to:
  /// **'Ayuno programado'**
  String get notificationTypeScheduledFastingShort;

  /// No description provided for @basedOnActualDoseShort.
  ///
  /// In es, this message translates to:
  /// **'Basado en toma real'**
  String get basedOnActualDoseShort;

  /// No description provided for @basedOnScheduleShort.
  ///
  /// In es, this message translates to:
  /// **'Basado en horario'**
  String get basedOnScheduleShort;

  /// No description provided for @pendingNotifications.
  ///
  /// In es, this message translates to:
  /// **'📊 Notificaciones pendientes: {count}'**
  String pendingNotifications(int count);

  /// No description provided for @medicationsWithSchedulesInfo.
  ///
  /// In es, this message translates to:
  /// **'💊 Medicamentos con horarios: {withSchedules}/{total}'**
  String medicationsWithSchedulesInfo(int withSchedules, int total);

  /// No description provided for @noSchedulesConfiguredWarning.
  ///
  /// In es, this message translates to:
  /// **'⚠️ Sin horarios configurados'**
  String get noSchedulesConfiguredWarning;

  /// No description provided for @medicationInfo.
  ///
  /// In es, this message translates to:
  /// **'💊 {name}'**
  String medicationInfo(String name);

  /// No description provided for @notificationType.
  ///
  /// In es, this message translates to:
  /// **'📋 Tipo: {type}'**
  String notificationType(String type);

  /// No description provided for @scheduleDate.
  ///
  /// In es, this message translates to:
  /// **'📅 Fecha: {date}'**
  String scheduleDate(String date);

  /// No description provided for @scheduleTime.
  ///
  /// In es, this message translates to:
  /// **'⏰ Hora: {time}'**
  String scheduleTime(String time);

  /// No description provided for @notificationId.
  ///
  /// In es, this message translates to:
  /// **'ID: {id}'**
  String notificationId(int id);

  /// No description provided for @takenStatus.
  ///
  /// In es, this message translates to:
  /// **'Tomada'**
  String get takenStatus;

  /// No description provided for @skippedStatus.
  ///
  /// In es, this message translates to:
  /// **'Omitida'**
  String get skippedStatus;

  /// No description provided for @durationEstimate.
  ///
  /// In es, this message translates to:
  /// **'{name}\nStock: {stock}\nDuración estimada: {days} días'**
  String durationEstimate(String name, String stock, int days);

  /// No description provided for @errorChanging.
  ///
  /// In es, this message translates to:
  /// **'Error al cambiar estado: {error}'**
  String errorChanging(String error);

  /// No description provided for @testScheduled1Min.
  ///
  /// In es, this message translates to:
  /// **'Probar programada (1 min)'**
  String get testScheduled1Min;

  /// No description provided for @alarmsAndRemindersMenu.
  ///
  /// In es, this message translates to:
  /// **'⚙️ Alarmas y recordatorios'**
  String get alarmsAndRemindersMenu;

  /// No description provided for @medicationStockInfo.
  ///
  /// In es, this message translates to:
  /// **'{name}\nStock: {stock}'**
  String medicationStockInfo(String name, String stock);

  /// No description provided for @takenTodaySingle.
  ///
  /// In es, this message translates to:
  /// **'Tomado hoy: {quantity} {unit} a las {time}'**
  String takenTodaySingle(String quantity, String unit, String time);

  /// No description provided for @takenTodayMultiple.
  ///
  /// In es, this message translates to:
  /// **'Tomado hoy: {count} veces ({quantity} {unit})'**
  String takenTodayMultiple(int count, String quantity, String unit);

  /// No description provided for @done.
  ///
  /// In es, this message translates to:
  /// **'Hecho'**
  String get done;

  /// No description provided for @suspended.
  ///
  /// In es, this message translates to:
  /// **'Suspendido'**
  String get suspended;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es', 'eu', 'gl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'eu':
      return AppLocalizationsEu();
    case 'gl':
      return AppLocalizationsGl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
