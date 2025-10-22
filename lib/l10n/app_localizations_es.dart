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

  // Add Medication Flow
  @override
  String get addMedicationTitle => 'Añadir Medicamento';
  @override
  String stepIndicator(int current, int total) => 'Paso $current de $total';

  // Medication Info Screen
  @override
  String get medicationInfoTitle => 'Información del medicamento';
  @override
  String get medicationInfoSubtitle => 'Comienza proporcionando el nombre y tipo de medicamento';
  @override
  String get medicationNameLabel => 'Nombre del medicamento';
  @override
  String get medicationNameHint => 'Ej: Paracetamol';
  @override
  String get medicationTypeLabel => 'Tipo de medicamento';
  @override
  String get validationMedicationName => 'Por favor, introduce el nombre del medicamento';

  // Medication Duration Screen
  @override
  String get medicationDurationTitle => 'Tipo de Tratamiento';
  @override
  String get medicationDurationSubtitle => '¿Cómo vas a tomar este medicamento?';
  @override
  String get durationContinuousTitle => 'Tratamiento continuo';
  @override
  String get durationContinuousDesc => 'Todos los días, con patrón regular';
  @override
  String get durationUntilEmptyTitle => 'Hasta acabar medicación';
  @override
  String get durationUntilEmptyDesc => 'Termina cuando se acabe el stock';
  @override
  String get durationSpecificDatesTitle => 'Fechas específicas';
  @override
  String get durationSpecificDatesDesc => 'Solo días concretos seleccionados';
  @override
  String get durationAsNeededTitle => 'Medicamento ocasional';
  @override
  String get durationAsNeededDesc => 'Solo cuando sea necesario, sin horarios';
  @override
  String get selectDatesButton => 'Seleccionar fechas';
  @override
  String get selectDatesTitle => 'Selecciona las fechas';
  @override
  String get selectDatesSubtitle => 'Elige los días exactos en los que tomarás el medicamento';
  @override
  String dateSelected(int count) => count == 1 ? '1 fecha seleccionada' : '$count fechas seleccionadas';
  @override
  String get validationSelectDates => 'Por favor, selecciona al menos una fecha';

  // Medication Dates Screen
  @override
  String get medicationDatesTitle => 'Fechas del Tratamiento';
  @override
  String get medicationDatesSubtitle => '¿Cuándo comenzarás y terminarás este tratamiento?';
  @override
  String get medicationDatesHelp => 'Ambas fechas son opcionales. Si no las estableces, el tratamiento comenzará hoy y no tendrá fecha límite.';
  @override
  String get startDateLabel => 'Fecha de inicio';
  @override
  String get startDateOptional => 'Opcional';
  @override
  String get startDateDefault => 'Empieza hoy';
  @override
  String get endDateLabel => 'Fecha de fin';
  @override
  String get endDateDefault => 'Sin fecha límite';
  @override
  String get startDatePickerTitle => 'Fecha de inicio del tratamiento';
  @override
  String get endDatePickerTitle => 'Fecha de fin del tratamiento';
  @override
  String get startTodayButton => 'Empezar hoy';
  @override
  String get noEndDateButton => 'Sin fecha límite';
  @override
  String treatmentDuration(int days) => 'Tratamiento de $days días';

  // Medication Frequency Screen
  @override
  String get medicationFrequencyTitle => 'Frecuencia de Medicación';
  @override
  String get medicationFrequencySubtitle => 'Cada cuántos días debes tomar este medicamento';
  @override
  String get frequencyDailyTitle => 'Todos los días';
  @override
  String get frequencyDailyDesc => 'Medicación diaria continua';
  @override
  String get frequencyAlternateTitle => 'Días alternos';
  @override
  String get frequencyAlternateDesc => 'Cada 2 días desde el inicio del tratamiento';
  @override
  String get frequencyWeeklyTitle => 'Días de la semana específicos';
  @override
  String get frequencyWeeklyDesc => 'Selecciona qué días tomar el medicamento';
  @override
  String get selectWeeklyDaysButton => 'Seleccionar días';
  @override
  String get selectWeeklyDaysTitle => 'Días de la semana';
  @override
  String get selectWeeklyDaysSubtitle => 'Selecciona los días específicos en los que tomarás el medicamento';
  @override
  String daySelected(int count) => count == 1 ? '1 día seleccionado' : '$count días seleccionados';
  @override
  String get validationSelectWeekdays => 'Por favor, selecciona los días de la semana';

  // Medication Dosage Screen
  @override
  String get medicationDosageTitle => 'Configuración de Dosis';
  @override
  String get medicationDosageSubtitle => '¿Cómo prefieres configurar las dosis diarias?';
  @override
  String get dosageFixedTitle => 'Todos los días igual';
  @override
  String get dosageFixedDesc => 'Especifica cada cuántas horas tomar el medicamento';
  @override
  String get dosageCustomTitle => 'Personalizado';
  @override
  String get dosageCustomDesc => 'Define el número de tomas por día';
  @override
  String get dosageIntervalLabel => 'Intervalo entre tomas';
  @override
  String get dosageIntervalHelp => 'El intervalo debe dividir 24 exactamente';
  @override
  String get dosageIntervalFieldLabel => 'Cada cuántas horas';
  @override
  String get dosageIntervalHint => 'Ej: 8';
  @override
  String get dosageIntervalUnit => 'horas';
  @override
  String get dosageIntervalValidValues => 'Valores válidos: 1, 2, 3, 4, 6, 8, 12, 24';
  @override
  String get dosageTimesLabel => 'Número de tomas al día';
  @override
  String get dosageTimesHelp => 'Define cuántas veces al día tomarás el medicamento';
  @override
  String get dosageTimesFieldLabel => 'Tomas por día';
  @override
  String get dosageTimesHint => 'Ej: 3';
  @override
  String get dosageTimesUnit => 'tomas';
  @override
  String get dosageTimesDescription => 'Número total de tomas diarias';
  @override
  String get dosesPerDay => 'Tomas por día';
  @override
  String doseCount(int count) => count == 1 ? '1 toma' : '$count tomas';
  @override
  String get validationInvalidInterval => 'Por favor, introduce un intervalo válido';
  @override
  String get validationIntervalTooLarge => 'El intervalo no puede ser mayor a 24 horas';
  @override
  String get validationIntervalNotDivisor => 'El intervalo debe dividir 24 exactamente (1, 2, 3, 4, 6, 8, 12, 24)';
  @override
  String get validationInvalidDoseCount => 'Por favor, introduce un número de tomas válido';
  @override
  String get validationTooManyDoses => 'No puedes tomar más de 24 dosis al día';

  // Medication Times Screen
  @override
  String get medicationTimesTitle => 'Horario de Tomas';
  @override
  String dosesPerDayLabel(int count) => 'Tomas al día: $count';
  @override
  String frequencyEveryHours(int hours) => 'Frecuencia: Cada $hours horas';
  @override
  String get selectTimeAndAmount => 'Selecciona la hora y cantidad de cada toma';
  @override
  String doseNumber(int number) => 'Toma $number';
  @override
  String get selectTimeButton => 'Seleccionar hora';
  @override
  String get amountPerDose => 'Cantidad por toma';
  @override
  String get amountHint => 'Ej: 1, 0.5, 2';
  @override
  String get removeDoseButton => 'Eliminar toma';
  @override
  String get validationSelectAllTimes => 'Por favor, selecciona todas las horas de las tomas';
  @override
  String get validationEnterValidAmounts => 'Por favor, ingresa cantidades válidas (mayores a 0)';
  @override
  String get validationDuplicateTimes => 'Las horas de las tomas no pueden repetirse';
  @override
  String get validationAtLeastOneDose => 'Debe haber al menos una toma al día';

  // Medication Fasting Screen
  @override
  String get medicationFastingTitle => 'Configuración de Ayuno';
  @override
  String get fastingLabel => 'Ayuno';
  @override
  String get fastingHelp => 'Algunos medicamentos requieren ayuno antes o después de la toma';
  @override
  String get requiresFastingQuestion => '¿Este medicamento requiere ayuno?';
  @override
  String get fastingNo => 'No';
  @override
  String get fastingYes => 'Sí';
  @override
  String get fastingWhenQuestion => '¿Cuándo es el ayuno?';
  @override
  String get fastingBefore => 'Antes de la toma';
  @override
  String get fastingAfter => 'Después de la toma';
  @override
  String get fastingDurationQuestion => '¿Cuánto tiempo de ayuno?';
  @override
  String get fastingHours => 'Horas';
  @override
  String get fastingMinutes => 'Minutos';
  @override
  String get fastingNotificationsQuestion => '¿Deseas recibir notificaciones de ayuno?';
  @override
  String get fastingNotificationBeforeHelp => 'Te notificaremos cuándo debes dejar de comer antes de la toma';
  @override
  String get fastingNotificationAfterHelp => 'Te notificaremos cuándo puedes volver a comer después de la toma';
  @override
  String get fastingNotificationsOn => 'Notificaciones activadas';
  @override
  String get fastingNotificationsOff => 'Notificaciones desactivadas';
  @override
  String get validationCompleteAllFields => 'Por favor, completa todos los campos';
  @override
  String get validationSelectFastingWhen => 'Por favor, selecciona cuándo es el ayuno';
  @override
  String get validationFastingDuration => 'La duración del ayuno debe ser al menos 1 minuto';

  // Medication Quantity Screen
  @override
  String get medicationQuantityTitle => 'Cantidad de Medicamento';
  @override
  String get medicationQuantitySubtitle => 'Establece la cantidad disponible y cuándo deseas recibir alertas';
  @override
  String get availableQuantityLabel => 'Cantidad disponible';
  @override
  String get availableQuantityHint => 'Ej: 30';
  @override
  String availableQuantityHelp(String unit) => 'Cantidad de $unit que tienes actualmente';
  @override
  String get lowStockAlertLabel => 'Avisar cuando queden';
  @override
  String get lowStockAlertHint => 'Ej: 3';
  @override
  String get lowStockAlertUnit => 'días';
  @override
  String get lowStockAlertHelp => 'Días de antelación para recibir la alerta de bajo stock';
  @override
  String get validationEnterQuantity => 'Por favor, introduce la cantidad disponible';
  @override
  String get validationQuantityNonNegative => 'La cantidad debe ser mayor o igual a 0';
  @override
  String get validationEnterAlertDays => 'Por favor, introduce los días de antelación';
  @override
  String get validationAlertMinDays => 'Debe ser al menos 1 día';
  @override
  String get validationAlertMaxDays => 'No puede ser mayor a 30 días';
  @override
  String get summaryTitle => 'Resumen';
  @override
  String get summaryMedication => 'Medicamento';
  @override
  String get summaryType => 'Tipo';
  @override
  String get summaryDosesPerDay => 'Tomas al día';
  @override
  String get summarySchedules => 'Horarios';
  @override
  String get summaryFrequency => 'Frecuencia';
  @override
  String get summaryFrequencyDaily => 'Todos los días';
  @override
  String get summaryFrequencyUntilEmpty => 'Hasta acabar medicación';
  @override
  String summaryFrequencySpecificDates(int count) => '$count fechas específicas';
  @override
  String summaryFrequencyWeekdays(int count) => '$count días de la semana';
  @override
  String summaryFrequencyEveryNDays(int days) => 'Cada $days días';
  @override
  String get summaryFrequencyAsNeeded => 'Según necesidad';
  @override
  String msgMedicationAddedSuccess(String name) => '$name añadido correctamente';
  @override
  String msgMedicationAddError(String error) => 'Error al guardar el medicamento: $error';
  @override
  String get saveMedicationButton => 'Guardar Medicamento';
  @override
  String get savingButton => 'Guardando...';
}
