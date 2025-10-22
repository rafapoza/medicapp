import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('en'),
    Locale('es'),
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
