// ignore_for_file: type=lint
import 'app_localizations.dart';

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
  String get validationDuplicateMedication => 'Este medicamento ya existe en tu lista';

  @override
  String get validationInvalidNumber => 'Introduce un número válido';

  @override
  String validationMinValue(num min) {
    return 'El valor debe ser mayor que $min';
  }

  // Pill Organizer Screen
  @override
  String get pillOrganizerTitle => 'Pastillero';
  @override
  String get pillOrganizerTotal => 'Total';
  @override
  String get pillOrganizerLowStock => 'Stock bajo';
  @override
  String get pillOrganizerNoStock => 'Sin stock';
  @override
  String get pillOrganizerAvailableStock => 'Stock disponible';
  @override
  String get pillOrganizerMedicationsTitle => 'Medicamentos';
  @override
  String get pillOrganizerEmptyTitle => 'No hay medicamentos registrados';
  @override
  String get pillOrganizerEmptySubtitle => 'Añade medicamentos para ver tu pastillero';
  @override
  String get pillOrganizerCurrentStock => 'Stock actual';
  @override
  String get pillOrganizerEstimatedDuration => 'Duración estimada';
  @override
  String get pillOrganizerDays => 'días';

  // Medicine Cabinet Screen
  @override
  String get medicineCabinetTitle => 'Botiquín';
  @override
  String get medicineCabinetSearchHint => 'Buscar medicamento...';
  @override
  String get medicineCabinetEmptyTitle => 'No hay medicamentos registrados';
  @override
  String get medicineCabinetEmptySubtitle => 'Añade medicamentos para ver tu botiquín';
  @override
  String get medicineCabinetPullToRefresh => 'Arrastra hacia abajo para recargar';
  @override
  String get medicineCabinetNoResults => 'No se encontraron medicamentos';
  @override
  String get medicineCabinetNoResultsHint => 'Prueba con otro término de búsqueda';
  @override
  String get medicineCabinetStock => 'Stock:';
  @override
  String get medicineCabinetSuspended => 'Suspendido';
  @override
  String get medicineCabinetTapToRegister => 'Toca para registrar';
  @override
  String get medicineCabinetResumeMedication => 'Reanudar medicación';
  @override
  String get medicineCabinetRegisterDose => 'Registrar toma';
  @override
  String get medicineCabinetRefillMedication => 'Recargar medicamento';
  @override
  String get medicineCabinetEditMedication => 'Editar medicamento';
  @override
  String get medicineCabinetDeleteMedication => 'Eliminar medicamento';
  @override
  String medicineCabinetRefillTitle(String name) => 'Recargar $name';
  @override
  String medicineCabinetRegisterDoseTitle(String name) => 'Registrar toma de $name';
  @override
  String get medicineCabinetCurrentStock => 'Stock actual:';
  @override
  String get medicineCabinetAddQuantity => 'Cantidad a añadir:';
  @override
  String get medicineCabinetAddQuantityLabel => 'Cantidad a agregar';
  @override
  String get medicineCabinetExample => 'Ej:';
  @override
  String get medicineCabinetLastRefill => 'Última recarga:';
  @override
  String get medicineCabinetRefillButton => 'Recargar';
  @override
  String get medicineCabinetAvailableStock => 'Stock disponible:';
  @override
  String get medicineCabinetDoseTaken => 'Cantidad tomada';
  @override
  String get medicineCabinetRegisterButton => 'Registrar';
  @override
  String get medicineCabinetNewStock => 'Nuevo stock:';
  @override
  String get medicineCabinetDeleteConfirmTitle => 'Eliminar medicamento';
  @override
  String medicineCabinetDeleteConfirmMessage(String name) => '¿Estás seguro de que deseas eliminar "$name"?\n\nEsta acción no se puede deshacer y se perderá todo el historial de este medicamento.';
  @override
  String get medicineCabinetNoStockAvailable => 'No hay stock disponible de este medicamento';
  @override
  String medicineCabinetInsufficientStock(String needed, String unit, String available) => 'Stock insuficiente para esta toma\nNecesitas: $needed $unit\nDisponible: $available';
  @override
  String medicineCabinetRefillSuccess(String name, String amount, String unit, String newStock) => 'Stock de $name recargado\nAgregado: $amount $unit\nNuevo stock: $newStock';
  @override
  String medicineCabinetDoseRegistered(String name, String amount, String unit, String remaining) => 'Toma de $name registrada\nCantidad: $amount $unit\nStock restante: $remaining';
  @override
  String medicineCabinetDeleteSuccess(String name) => '$name eliminado correctamente';
  @override
  String medicineCabinetResumeSuccess(String name) => '$name reanudado correctamente\nNotificaciones reprogramadas';

  // Dose History Screen
  @override
  String get doseHistoryTitle => 'Historial de Tomas';
  @override
  String get doseHistoryFilterTitle => 'Filtrar historial';
  @override
  String get doseHistoryMedicationLabel => 'Medicamento:';
  @override
  String get doseHistoryAllMedications => 'Todos los medicamentos';
  @override
  String get doseHistoryDateRangeLabel => 'Rango de fechas:';
  @override
  String get doseHistoryClearDates => 'Limpiar fechas';
  @override
  String get doseHistoryApply => 'Aplicar';
  @override
  String get doseHistoryTotal => 'Total';
  @override
  String get doseHistoryTaken => 'Tomadas';
  @override
  String get doseHistorySkipped => 'Omitidas';
  @override
  String get doseHistoryClear => 'Limpiar';
  @override
  String doseHistoryEditEntry(String name) => 'Editar registro de $name';
  @override
  String get doseHistoryScheduledTime => 'Hora programada:';
  @override
  String get doseHistoryActualTime => 'Hora real:';
  @override
  String get doseHistoryStatus => 'Estado:';
  @override
  String get doseHistoryMarkAsSkipped => 'Marcar como Omitida';
  @override
  String get doseHistoryMarkAsTaken => 'Marcar como Tomada';
  @override
  String get doseHistoryConfirmDelete => 'Confirmar eliminación';
  @override
  String get doseHistoryConfirmDeleteMessage => '¿Estás seguro de que quieres eliminar este registro?';
  @override
  String get doseHistoryRecordDeleted => 'Registro eliminado correctamente';
  @override
  String doseHistoryDeleteError(String error) => 'Error al eliminar: $error';
}
