// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Galician (`gl`).
class AppLocalizationsGl extends AppLocalizations {
  AppLocalizationsGl([String locale = 'gl']) : super(locale);

  @override
  String get appTitle => 'MedicApp';

  @override
  String get navMedication => 'Medicación';

  @override
  String get navPillOrganizer => 'Pastilleiro';

  @override
  String get navMedicineCabinet => 'Botiquín';

  @override
  String get navHistory => 'Historial';

  @override
  String get navSettings => 'Configuración';

  @override
  String get navInventory => 'Inventario';

  @override
  String get navMedicationShort => 'Inicio';

  @override
  String get navPillOrganizerShort => 'Stock';

  @override
  String get navMedicineCabinetShort => 'Botiquín';

  @override
  String get navHistoryShort => 'Historial';

  @override
  String get navSettingsShort => 'Axustes';

  @override
  String get navInventoryShort => 'Medicinas';

  @override
  String get btnContinue => 'Continuar';

  @override
  String get btnBack => 'Atrás';

  @override
  String get btnSave => 'Gardar';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String get btnEdit => 'Editar';

  @override
  String get btnClose => 'Pechar';

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
  String get durationSpecificDates => 'Datas específicas';

  @override
  String get durationAsNeeded => 'Segundo necesidade';

  @override
  String get mainScreenTitle => 'Os meus medicamentos';

  @override
  String get mainScreenEmptyTitle => 'Non hai medicamentos rexistrados';

  @override
  String get mainScreenEmptySubtitle => 'Añade medicamentos usando el botón +';

  @override
  String get mainScreenTodayDoses => 'Tomas de hoxe';

  @override
  String get mainScreenNoMedications => 'Non tes medicamentos activos';

  @override
  String get msgMedicationAdded => 'Medicamento añadido correctamente';

  @override
  String get msgMedicationUpdated => 'Medicamento actualizado correctamente';

  @override
  String msgMedicationDeleted(String name) {
    return '$name eliminado correctamente';
  }

  @override
  String get validationRequired => 'Este campo é obrigatorio';

  @override
  String get validationDuplicateMedication => 'Este medicamento ya existe en tu lista';

  @override
  String get validationInvalidNumber => 'Introduce un número válido';

  @override
  String validationMinValue(num min) {
    return 'El valor debe ser mayor que $min';
  }

  @override
  String get pillOrganizerTitle => 'Pastilleiro';

  @override
  String get pillOrganizerTotal => 'Total';

  @override
  String get pillOrganizerLowStock => 'Stock baixo';

  @override
  String get pillOrganizerNoStock => 'Sen stock';

  @override
  String get pillOrganizerAvailableStock => 'Stock disponible';

  @override
  String get pillOrganizerMedicationsTitle => 'Medicamentos';

  @override
  String get pillOrganizerEmptyTitle => 'Non hai medicamentos rexistrados';

  @override
  String get pillOrganizerEmptySubtitle => 'Añade medicamentos para ver tu pastillero';

  @override
  String get pillOrganizerCurrentStock => 'Stock actual';

  @override
  String get pillOrganizerEstimatedDuration => 'Duración estimada';

  @override
  String get pillOrganizerDays => 'días';

  @override
  String get medicineCabinetTitle => 'Botiquín';

  @override
  String get medicineCabinetSearchHint => 'Buscar medicamento...';

  @override
  String get medicineCabinetEmptyTitle => 'Non hai medicamentos rexistrados';

  @override
  String get medicineCabinetEmptySubtitle => 'Añade medicamentos para ver tu botiquín';

  @override
  String get medicineCabinetPullToRefresh => 'Arrastra hacia abajo para recargar';

  @override
  String get medicineCabinetNoResults => 'Non se atoparon medicamentos';

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
  String get medicineCabinetRegisterDose => 'Rexistrar toma';

  @override
  String get medicineCabinetRefillMedication => 'Recargar medicamento';

  @override
  String get medicineCabinetEditMedication => 'Editar medicamento';

  @override
  String get medicineCabinetDeleteMedication => 'Eliminar medicamento';

  @override
  String medicineCabinetRefillTitle(String name) {
    return 'Recargar $name';
  }

  @override
  String medicineCabinetRegisterDoseTitle(String name) {
    return 'Registrar toma de $name';
  }

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
  String medicineCabinetDeleteConfirmMessage(String name) {
    return '¿Estás seguro de que deseas eliminar \"$name\"?\n\nEsta acción no se puede deshacer y se perderá todo el historial de este medicamento.';
  }

  @override
  String get medicineCabinetNoStockAvailable => 'No hay stock disponible de este medicamento';

  @override
  String medicineCabinetInsufficientStock(String needed, String unit, String available) {
    return 'Stock insuficiente para esta toma\nNecesitas: $needed $unit\nDisponible: $available';
  }

  @override
  String medicineCabinetRefillSuccess(String name, String amount, String unit, String newStock) {
    return 'Stock de $name recargado\nAgregado: $amount $unit\nNuevo stock: $newStock';
  }

  @override
  String medicineCabinetDoseRegistered(String name, String amount, String unit, String remaining) {
    return 'Toma de $name registrada\nCantidad: $amount $unit\nStock restante: $remaining';
  }

  @override
  String medicineCabinetDeleteSuccess(String name) {
    return '$name eliminado correctamente';
  }

  @override
  String medicineCabinetResumeSuccess(String name) {
    return '$name reanudado correctamente\nNotificaciones reprogramadas';
  }

  @override
  String get doseHistoryTitle => 'Historial de tomas';

  @override
  String get doseHistoryFilterTitle => 'Filtrar historial';

  @override
  String get doseHistoryMedicationLabel => 'Medicamento:';

  @override
  String get doseHistoryAllMedications => 'Todos os medicamentos';

  @override
  String get doseHistoryDateRangeLabel => 'Rango de fechas:';

  @override
  String get doseHistoryClearDates => 'Limpar datas';

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
  String doseHistoryEditEntry(String name) {
    return 'Editar registro de $name';
  }

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
  String doseHistoryDeleteError(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get addMedicationTitle => 'Añadir Medicamento';

  @override
  String stepIndicator(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get medicationInfoTitle => 'Información do medicamento';

  @override
  String get medicationInfoSubtitle => 'Comienza proporcionando el nombre y tipo de medicamento';

  @override
  String get medicationNameLabel => 'Nome do medicamento';

  @override
  String get medicationNameHint => 'Ej: Paracetamol';

  @override
  String get medicationTypeLabel => 'Tipo de medicamento';

  @override
  String get validationMedicationName => 'Por favor, introduce el nombre del medicamento';

  @override
  String get medicationDurationTitle => 'Tipo de Tratamiento';

  @override
  String get medicationDurationSubtitle => '¿Cómo vas a tomar este medicamento?';

  @override
  String get durationContinuousTitle => 'Tratamento continuo';

  @override
  String get durationContinuousDesc => 'Todos los días, con patrón regular';

  @override
  String get durationUntilEmptyTitle => 'Ata acabar medicación';

  @override
  String get durationUntilEmptyDesc => 'Termina cuando se acabe el stock';

  @override
  String get durationSpecificDatesTitle => 'Datas específicas';

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
  String dateSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fechas seleccionadas',
      one: '1 fecha seleccionada',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectDates => 'Por favor, selecciona al menos una fecha';

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
  String treatmentDuration(int days) {
    return 'Tratamiento de $days días';
  }

  @override
  String get medicationFrequencyTitle => 'Frecuencia de medicación';

  @override
  String get medicationFrequencySubtitle => 'Cada cuántos días debes tomar este medicamento';

  @override
  String get frequencyDailyTitle => 'Todos os días';

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
  String get selectWeeklyDaysTitle => 'Días da semana';

  @override
  String get selectWeeklyDaysSubtitle => 'Selecciona los días específicos en los que tomarás el medicamento';

  @override
  String daySelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días seleccionados',
      one: '1 día seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get validationSelectWeekdays => 'Por favor, selecciona los días de la semana';

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
  String doseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tomas',
      one: '1 toma',
    );
    return '$_temp0';
  }

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

  @override
  String get medicationTimesTitle => 'Horario de tomas';

  @override
  String dosesPerDayLabel(int count) {
    return 'Tomas al día: $count';
  }

  @override
  String frequencyEveryHours(int hours) {
    return 'Frecuencia: Cada $hours horas';
  }

  @override
  String get selectTimeAndAmount => 'Selecciona la hora y cantidad de cada toma';

  @override
  String doseNumber(int number) {
    return 'Toma $number';
  }

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

  @override
  String get medicationFastingTitle => 'Configuración de xaxún';

  @override
  String get fastingLabel => 'Xaxún';

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

  @override
  String get medicationQuantityTitle => 'Cantidad de Medicamento';

  @override
  String get medicationQuantitySubtitle => 'Establece la cantidad disponible y cuándo deseas recibir alertas';

  @override
  String get availableQuantityLabel => 'Cantidade dispoñible';

  @override
  String get availableQuantityHint => 'Ej: 30';

  @override
  String availableQuantityHelp(String unit) {
    return 'Cantidad de $unit que tienes actualmente';
  }

  @override
  String get lowStockAlertLabel => 'Avisar cando queden';

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
  String get summaryFrequencyDaily => 'Todos os días';

  @override
  String get summaryFrequencyUntilEmpty => 'Ata acabar medicación';

  @override
  String summaryFrequencySpecificDates(int count) {
    return '$count fechas específicas';
  }

  @override
  String summaryFrequencyWeekdays(int count) {
    return '$count días de la semana';
  }

  @override
  String summaryFrequencyEveryNDays(int days) {
    return 'Cada $days días';
  }

  @override
  String get summaryFrequencyAsNeeded => 'Segundo necesidade';

  @override
  String msgMedicationAddedSuccess(String name) {
    return '$name añadido correctamente';
  }

  @override
  String msgMedicationAddError(String error) {
    return 'Error al guardar el medicamento: $error';
  }

  @override
  String get saveMedicationButton => 'Guardar Medicamento';

  @override
  String get savingButton => 'Guardando...';

  @override
  String get doseActionTitle => 'Acción de toma';

  @override
  String get doseActionLoading => 'Cargando...';

  @override
  String get doseActionError => 'Error';

  @override
  String get doseActionMedicationNotFound => 'Medicamento no encontrado';

  @override
  String get doseActionBack => 'Volver';

  @override
  String doseActionScheduledTime(String time) {
    return 'Hora programada: $time';
  }

  @override
  String get doseActionThisDoseQuantity => 'Cantidad de esta toma';

  @override
  String get doseActionWhatToDo => '¿Qué deseas hacer?';

  @override
  String get doseActionRegisterTaken => 'Rexistrar toma';

  @override
  String get doseActionWillDeductStock => 'Descontará del stock';

  @override
  String get doseActionMarkAsNotTaken => 'Marcar como no tomada';

  @override
  String get doseActionWillNotDeductStock => 'No descontará del stock';

  @override
  String get doseActionPostpone15Min => 'Posponer 15 minutos';

  @override
  String get doseActionQuickReminder => 'Recordatorio rápido';

  @override
  String get doseActionPostponeCustom => 'Posponer (elegir hora)';

  @override
  String doseActionInsufficientStock(String needed, String unit, String available) {
    return 'Stock insuficiente para esta toma\nNecesitas: $needed $unit\nDisponible: $available';
  }

  @override
  String doseActionTakenRegistered(String name, String time, String stock) {
    return 'Toma de $name registrada a las $time\nStock restante: $stock';
  }

  @override
  String doseActionSkippedRegistered(String name, String time, String stock) {
    return 'Toma de $name marcada como no tomada a las $time\nStock: $stock (sin cambios)';
  }

  @override
  String doseActionPostponed(String name, String time) {
    return 'Toma de $name pospuesta\nNueva hora: $time';
  }

  @override
  String doseActionPostponed15(String name, String time) {
    return 'Toma de $name pospuesta 15 minutos\nNueva hora: $time';
  }

  @override
  String get editMedicationMenuTitle => 'Editar Medicamento';

  @override
  String get editMedicationMenuWhatToEdit => '¿Qué deseas editar?';

  @override
  String get editMedicationMenuSelectSection => 'Selecciona la sección que deseas modificar';

  @override
  String get editMedicationMenuBasicInfo => 'Información básica';

  @override
  String get editMedicationMenuBasicInfoDesc => 'Nombre y tipo de medicamento';

  @override
  String get editMedicationMenuDuration => 'Duración do tratamento';

  @override
  String get editMedicationMenuFrequency => 'Frecuencia';

  @override
  String get editMedicationMenuSchedules => 'Horarios e cantidades';

  @override
  String editMedicationMenuSchedulesDesc(int count) {
    return '$count tomas al día';
  }

  @override
  String get editMedicationMenuFasting => 'Configuración de xaxún';

  @override
  String get editMedicationMenuQuantity => 'Cantidad Disponible';

  @override
  String editMedicationMenuQuantityDesc(String quantity, String unit) {
    return '$quantity $unit';
  }

  @override
  String get editMedicationMenuFreqEveryday => 'Todos os días';

  @override
  String get editMedicationMenuFreqUntilFinished => 'Ata acabar medicación';

  @override
  String editMedicationMenuFreqSpecificDates(int count) {
    return '$count fechas específicas';
  }

  @override
  String editMedicationMenuFreqWeeklyDays(int count) {
    return '$count días de la semana';
  }

  @override
  String editMedicationMenuFreqInterval(int interval) {
    return 'Cada $interval días';
  }

  @override
  String get editMedicationMenuFreqNotDefined => 'Frecuencia no definida';

  @override
  String get editMedicationMenuFastingNone => 'Sin ayuno';

  @override
  String editMedicationMenuFastingDuration(String duration, String type) {
    return 'Ayuno $duration $type';
  }

  @override
  String get editMedicationMenuFastingBefore => 'antes';

  @override
  String get editMedicationMenuFastingAfter => 'después';

  @override
  String get editBasicInfoTitle => 'Editar Información Básica';

  @override
  String get editBasicInfoUpdated => 'Información actualizada correctamente';

  @override
  String get editBasicInfoSaving => 'Guardando...';

  @override
  String get editBasicInfoSaveChanges => 'Gardar cambios';

  @override
  String editBasicInfoError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String get editDurationTitle => 'Editar Duración';

  @override
  String get editDurationTypeLabel => 'Tipo de duración';

  @override
  String editDurationCurrentType(String type) {
    return 'Tipo actual: $type';
  }

  @override
  String get editDurationChangeTypeInfo => 'Para cambiar el tipo de duración, edita la sección de \"Frecuencia\"';

  @override
  String get editDurationTreatmentDates => 'Fechas del tratamiento';

  @override
  String get editDurationStartDate => 'Fecha de inicio';

  @override
  String get editDurationEndDate => 'Fecha de fin';

  @override
  String get editDurationNotSelected => 'No seleccionada';

  @override
  String editDurationDays(int days) {
    return 'Duración: $days días';
  }

  @override
  String get editDurationSelectDates => 'Por favor, selecciona las fechas de inicio y fin';

  @override
  String get editDurationUpdated => 'Duración actualizada correctamente';

  @override
  String editDurationError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String get editFastingTitle => 'Editar Configuración de Ayuno';

  @override
  String get editFastingCompleteFields => 'Por favor, completa todos los campos';

  @override
  String get editFastingSelectWhen => 'Por favor, selecciona cuándo es el ayuno';

  @override
  String get editFastingMinDuration => 'La duración del ayuno debe ser al menos 1 minuto';

  @override
  String get editFastingUpdated => 'Configuración de ayuno actualizada correctamente';

  @override
  String editFastingError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String get editFrequencyTitle => 'Editar Frecuencia';

  @override
  String get editFrequencyPattern => 'Patrón de frecuencia';

  @override
  String get editFrequencyQuestion => '¿Con qué frecuencia tomarás este medicamento?';

  @override
  String get editFrequencyEveryday => 'Todos os días';

  @override
  String get editFrequencyEverydayDesc => 'Tomar el medicamento diariamente';

  @override
  String get editFrequencyUntilFinished => 'Hasta acabar';

  @override
  String get editFrequencyUntilFinishedDesc => 'Hasta que se termine el medicamento';

  @override
  String get editFrequencySpecificDates => 'Datas específicas';

  @override
  String get editFrequencySpecificDatesDesc => 'Seleccionar fechas concretas';

  @override
  String get editFrequencyWeeklyDays => 'Días da semana';

  @override
  String get editFrequencyWeeklyDaysDesc => 'Seleccionar días específicos cada semana';

  @override
  String get editFrequencyAlternateDays => 'Días alternos';

  @override
  String get editFrequencyAlternateDaysDesc => 'Cada 2 días desde el inicio del tratamiento';

  @override
  String get editFrequencyCustomInterval => 'Intervalo personalizado';

  @override
  String get editFrequencyCustomIntervalDesc => 'Cada N días desde el inicio';

  @override
  String get editFrequencySelectedDates => 'Fechas seleccionadas';

  @override
  String editFrequencyDatesCount(int count) {
    return '$count fechas seleccionadas';
  }

  @override
  String get editFrequencyNoDatesSelected => 'Ninguna fecha seleccionada';

  @override
  String get editFrequencySelectDatesButton => 'Seleccionar fechas';

  @override
  String get editFrequencyWeeklyDaysLabel => 'Días da semana';

  @override
  String editFrequencyWeeklyDaysCount(int count) {
    return '$count días seleccionados';
  }

  @override
  String get editFrequencyNoDaysSelected => 'Ningún día seleccionado';

  @override
  String get editFrequencySelectDaysButton => 'Seleccionar días';

  @override
  String get editFrequencyIntervalLabel => 'Intervalo de días';

  @override
  String get editFrequencyIntervalField => 'Cada cuántos días';

  @override
  String get editFrequencyIntervalHint => 'Ej: 3';

  @override
  String get editFrequencyIntervalHelp => 'Debe ser al menos 2 días';

  @override
  String get editFrequencySelectAtLeastOneDate => 'Por favor, selecciona al menos una fecha';

  @override
  String get editFrequencySelectAtLeastOneDay => 'Por favor, selecciona al menos un día de la semana';

  @override
  String get editFrequencyIntervalMin => 'El intervalo debe ser al menos 2 días';

  @override
  String get editFrequencyUpdated => 'Frecuencia actualizada correctamente';

  @override
  String editFrequencyError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String get editQuantityTitle => 'Editar Cantidad';

  @override
  String get editQuantityMedicationLabel => 'Cantidad de medicamento';

  @override
  String get editQuantityDescription => 'Establece la cantidad disponible y cuándo deseas recibir alertas';

  @override
  String get editQuantityAvailableLabel => 'Cantidade dispoñible';

  @override
  String editQuantityAvailableHelp(String unit) {
    return 'Cantidad de $unit que tienes actualmente';
  }

  @override
  String get editQuantityValidationRequired => 'Por favor, introduce la cantidad disponible';

  @override
  String get editQuantityValidationMin => 'La cantidad debe ser mayor o igual a 0';

  @override
  String get editQuantityThresholdLabel => 'Avisar cando queden';

  @override
  String get editQuantityThresholdHelp => 'Días de antelación para recibir la alerta de bajo stock';

  @override
  String get editQuantityThresholdValidationRequired => 'Por favor, introduce los días de antelación';

  @override
  String get editQuantityThresholdValidationMin => 'Debe ser al menos 1 día';

  @override
  String get editQuantityThresholdValidationMax => 'No puede ser mayor a 30 días';

  @override
  String get editQuantityUpdated => 'Cantidad actualizada correctamente';

  @override
  String editQuantityError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String get editScheduleTitle => 'Editar Horarios';

  @override
  String get editScheduleAddDose => 'Añadir toma';

  @override
  String get editScheduleValidationQuantities => 'Por favor, ingresa cantidades válidas (mayores a 0)';

  @override
  String get editScheduleValidationDuplicates => 'Las horas de las tomas no pueden repetirse';

  @override
  String get editScheduleUpdated => 'Horarios actualizados correctamente';

  @override
  String editScheduleError(String error) {
    return 'Error al guardar cambios: $error';
  }

  @override
  String editScheduleDosesPerDay(int count) {
    return 'Tomas al día: $count';
  }

  @override
  String get editScheduleAdjustTimeAndQuantity => 'Ajusta la hora y cantidad de cada toma';

  @override
  String get specificDatesSelectorTitle => 'Datas específicas';

  @override
  String get specificDatesSelectorSelectDates => 'Selecciona fechas';

  @override
  String get specificDatesSelectorDescription => 'Elige las fechas específicas en las que tomarás este medicamento';

  @override
  String get specificDatesSelectorAddDate => 'Añadir fecha';

  @override
  String specificDatesSelectorSelectedDates(int count) {
    return 'Fechas seleccionadas ($count)';
  }

  @override
  String get specificDatesSelectorToday => 'HOY';

  @override
  String get specificDatesSelectorContinue => 'Continuar';

  @override
  String get specificDatesSelectorAlreadySelected => 'Esta fecha ya está seleccionada';

  @override
  String get specificDatesSelectorSelectAtLeastOne => 'Selecciona al menos una fecha';

  @override
  String get specificDatesSelectorPickerHelp => 'Selecciona una fecha';

  @override
  String get specificDatesSelectorPickerCancel => 'Cancelar';

  @override
  String get specificDatesSelectorPickerConfirm => 'Aceptar';

  @override
  String get weeklyDaysSelectorTitle => 'Días da semana';

  @override
  String get weeklyDaysSelectorSelectDays => 'Selecciona los días';

  @override
  String get weeklyDaysSelectorDescription => 'Elige qué días de la semana tomarás este medicamento';

  @override
  String weeklyDaysSelectorSelectedCount(int count, String plural) {
    return '$count día$plural seleccionado$plural';
  }

  @override
  String get weeklyDaysSelectorContinue => 'Continuar';

  @override
  String get weeklyDaysSelectorSelectAtLeastOne => 'Selecciona al menos un día de la semana';

  @override
  String get weeklyDayMonday => 'Luns';

  @override
  String get weeklyDayTuesday => 'Martes';

  @override
  String get weeklyDayWednesday => 'Mércores';

  @override
  String get weeklyDayThursday => 'Xoves';

  @override
  String get weeklyDayFriday => 'Venres';

  @override
  String get weeklyDaySaturday => 'Sábado';

  @override
  String get weeklyDaySunday => 'Domingo';

  @override
  String get dateFromLabel => 'Desde';

  @override
  String get dateToLabel => 'Ata';

  @override
  String get statisticsTitle => 'Estadísticas';

  @override
  String get adherenceLabel => 'Adherencia';

  @override
  String get emptyDosesWithFilters => 'No hay tomas con estos filtros';

  @override
  String get emptyDoses => 'No hay tomas registradas';

  @override
  String get permissionRequired => 'Permiso necesario';

  @override
  String get notNowButton => 'Agora non';

  @override
  String get openSettingsButton => 'Abrir axustes';

  @override
  String medicationUpdatedMsg(String name) {
    return '$name actualizado';
  }

  @override
  String get noScheduledTimes => 'Este medicamento no tiene horarios configurados';

  @override
  String get allDosesTakenToday => 'Ya has tomado todas las dosis de hoy';

  @override
  String get extraDoseOption => 'Toma extra';

  @override
  String extraDoseConfirmationMessage(String name) {
    return 'Xa rexistraches todas as tomas programadas de hoxe. Queres rexistrar unha toma extra de $name?';
  }

  @override
  String get extraDoseConfirm => 'Rexistrar toma extra';

  @override
  String extraDoseRegistered(String name, String time, String stock) {
    return 'Toma extra de $name rexistrada ás $time ($stock dispoñible)';
  }

  @override
  String registerDoseOfMedication(String name) {
    return 'Registrar toma de $name';
  }

  @override
  String refillMedicationTitle(String name) {
    return 'Recargar $name';
  }

  @override
  String doseRegisteredAt(String time) {
    return 'Registrada a las $time';
  }

  @override
  String statusUpdatedTo(String status) {
    return 'Estado actualizado a: $status';
  }

  @override
  String get dateLabel => 'Fecha:';

  @override
  String get scheduledTimeLabel => 'Hora programada:';

  @override
  String get currentStatusLabel => 'Estado actual:';

  @override
  String get changeStatusToQuestion => '¿Cambiar estado a:';

  @override
  String get filterApplied => 'Filtro aplicado';

  @override
  String filterFrom(String date) {
    return 'Desde $date';
  }

  @override
  String filterTo(String date) {
    return 'Hasta $date';
  }

  @override
  String get insufficientStockForDose => 'No hay suficiente stock para marcar como tomada';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get settingsDisplaySection => 'Visualización';

  @override
  String get settingsShowActualTimeTitle => 'Mostrar hora real de toma';

  @override
  String get settingsShowActualTimeSubtitle => 'Mostra a hora real na que se tomaron as doses en lugar da hora programada';

  @override
  String get settingsShowFastingCountdownTitle => 'Mostrar conta atrás de xaxún';

  @override
  String get settingsShowFastingCountdownSubtitle => 'Mostra o tempo restante de xaxún na pantalla principal';

  @override
  String get settingsShowFastingNotificationTitle => 'Notificación fixa de conta atrás';

  @override
  String get settingsShowFastingNotificationSubtitle => 'Mostra unha notificación fixa co tempo restante de xaxún (só Android)';

  @override
  String get fastingNotificationTitle => 'Xaxún en curso';

  @override
  String fastingNotificationBody(String medication, String timeRemaining, String endTime) {
    return '$medication • $timeRemaining restantes (ata $endTime)';
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
    return 'Xaxún: $time restantes (ata as $endTime)';
  }

  @override
  String fastingUpcoming(String time, String endTime) {
    return 'Próximo xaxún: $time (ata as $endTime)';
  }

  @override
  String get settingsBackupSection => 'Copia de Seguridade';

  @override
  String get settingsExportTitle => 'Exportar Base de Datos';

  @override
  String get settingsExportSubtitle => 'Garda unha copia de todos os teus medicamentos e historial';

  @override
  String get settingsImportTitle => 'Importar Base de Datos';

  @override
  String get settingsImportSubtitle => 'Restaura unha copia de seguridade previamente exportada';

  @override
  String get settingsInfoTitle => 'Información';

  @override
  String get settingsInfoContent => '• Ao exportar, crearase un arquivo de copia de seguridade que poderás gardar no teu dispositivo ou compartir.\n\n• Ao importar, todos os datos actuais serán substituídos polos do arquivo seleccionado.\n\n• Recoméndase facer copias de seguridade regularmente.';

  @override
  String get settingsShareText => 'Copia de seguridade de MedicApp';

  @override
  String get settingsExportSuccess => 'Base de datos exportada correctamente';

  @override
  String get settingsImportSuccess => 'Base de datos importada correctamente';

  @override
  String settingsExportError(String error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String settingsImportError(String error) {
    return 'Erro ao importar: $error';
  }

  @override
  String get settingsFilePathError => 'Non se puido obter a ruta do arquivo';

  @override
  String get settingsImportDialogTitle => 'Importar Base de Datos';

  @override
  String get settingsImportDialogMessage => 'Esta acción substituirá todos os teus datos actuais cos datos do arquivo importado.\n\nEstás seguro de continuar?';

  @override
  String get settingsRestartDialogTitle => 'Importación Completada';

  @override
  String get settingsRestartDialogMessage => 'A base de datos foi importada correctamente.\n\nPor favor, reinicia a aplicación para ver os cambios.';

  @override
  String get settingsRestartDialogButton => 'Entendido';

  @override
  String get notificationsWillNotWork => 'Las notificaciones NO funcionarán sin este permiso.';

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
  String insufficientStockForThisDose(String needed, String unit, String available) {
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
  String manualDoseRegistered(String name, String quantity, String unit, String stock) {
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
  String stockRefilled(String name, String amount, String unit, String newStock) {
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
  String get batteryOptimizationWarning => 'Para que las notificaciones funcionen, desactiva las restricciones de batería:';

  @override
  String get batteryOptimizationInstructions => 'Ajustes → Aplicaciones → MedicApp → Batería → \"Sin restricciones\"';

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
  String get alarmsPermissionDescription => 'Este permiso permite que las notificaciones salten exactamente a la hora configurada.';

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
  String get withoutPermissionNoNotifications => 'Sin este permiso las notificaciones NO saltarán.';

  @override
  String get alarmsSettings => 'Ajustes → Aplicaciones → MedicApp → Alarmas y recordatorios';

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
  String get scheduledNotificationInOneMin => 'Notificación programada para 1 minuto';

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
    return 'Tomado hoxe: $quantity $unit ás $time';
  }

  @override
  String takenTodayMultiple(int count, String quantity, String unit) {
    return 'Tomado hoxe: $count veces ($quantity $unit)';
  }

  @override
  String get done => 'Feito';

  @override
  String get suspended => 'Suspendido';
}
