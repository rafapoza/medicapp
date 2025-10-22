// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'MedicApp';

  @override
  String get navMedication => 'Medicación';

  @override
  String get navPillOrganizer => 'Pastillero';

  @override
  String get navMedicineCabinet => 'Botiquín';

  @override
  String get navHistory => 'Historial';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnBack => 'Atrás';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnClose => 'Cerrar';

  @override
  String get btnConfirm => 'Confirmar';

  @override
  String get btnAccept => 'Aceptar';

  @override
  String get medicationTypePill => 'Pastilla';

  @override
  String get medicationTypeCapsule => 'Cápsula';

  @override
  String get medicationTypeTablet => 'Comprimido';

  @override
  String get medicationTypeSyrup => 'Jarabe';

  @override
  String get medicationTypeDrops => 'Gotas';

  @override
  String get medicationTypeInjection => 'Inyección';

  @override
  String get medicationTypePatch => 'Parche';

  @override
  String get medicationTypeInhaler => 'Inhalador';

  @override
  String get medicationTypeCream => 'Crema';

  @override
  String get medicationTypeOther => 'Otro';

  @override
  String get doseStatusTaken => 'Tomada';

  @override
  String get doseStatusSkipped => 'Omitida';

  @override
  String get doseStatusPending => 'Pendiente';

  @override
  String get durationContinuous => 'Continuo';

  @override
  String get durationSpecificDates => 'Fechas específicas';

  @override
  String get durationAsNeeded => 'Según necesidad';

  @override
  String get mainScreenTitle => 'Mis Medicamentos';

  @override
  String get mainScreenEmptyTitle => 'No hay medicamentos registrados';

  @override
  String get mainScreenEmptySubtitle => 'Añade medicamentos usando el botón +';

  @override
  String get mainScreenTodayDoses => 'Tomas de hoy';

  @override
  String get mainScreenNoMedications => 'No tienes medicamentos activos';

  @override
  String get msgMedicationAdded => 'Medicamento añadido correctamente';

  @override
  String get msgMedicationUpdated => 'Medicamento actualizado correctamente';

  @override
  String msgMedicationDeleted(String name) {
    return '$name eliminado correctamente';
  }

  @override
  String get validationRequired => 'Este campo es obligatorio';

  @override
  String get validationDuplicateMedication =>
      'Este medicamento ya existe en tu lista';

  @override
  String get validationInvalidNumber => 'Introduce un número válido';

  @override
  String validationMinValue(num min) {
    return 'El valor debe ser mayor que $min';
  }
}
