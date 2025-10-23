import 'package:medicapp/models/medication.dart';
import 'package:medicapp/models/medication_type.dart';
import 'package:medicapp/models/treatment_duration_type.dart';

/// Builder para crear medicamentos de prueba de forma simplificada y legible.
///
/// Ejemplo de uso:
/// ```dart
/// final medication = MedicationBuilder()
///   .withId('test_1')
///   .withName('Aspirina')
///   .withFasting(type: 'after', duration: 120)
///   .build();
/// ```
class MedicationBuilder {
  String _id = 'test_medication';
  String _name = 'Test Medication';
  MedicationType _type = MedicationType.pill;
  int _dosageIntervalHours = 8;
  TreatmentDurationType _durationType = TreatmentDurationType.everyday;
  Map<String, double> _doseSchedule = {'08:00': 1.0};
  double _stockQuantity = 10.0;
  List<String> _takenDosesToday = [];
  List<String> _skippedDosesToday = [];
  String? _takenDosesDate;
  double? _lastRefillAmount;
  int _lowStockThresholdDays = 3;
  bool _requiresFasting = false;
  String? _fastingType;
  int? _fastingDurationMinutes;
  bool _notifyFasting = false;
  bool _isSuspended = false;
  DateTime? _startDate;
  DateTime? _endDate;
  List<int>? _weeklyDays;
  List<String>? _selectedDates;
  int? _dayInterval;
  double? _lastDailyConsumption;

  /// Constructor por defecto
  MedicationBuilder();

  MedicationBuilder withId(String id) {
    _id = id;
    return this;
  }

  MedicationBuilder withName(String name) {
    _name = name;
    return this;
  }

  MedicationBuilder withType(MedicationType type) {
    _type = type;
    return this;
  }

  MedicationBuilder withDosageInterval(int hours) {
    _dosageIntervalHours = hours;
    return this;
  }

  MedicationBuilder withDurationType(TreatmentDurationType type) {
    _durationType = type;
    return this;
  }

  MedicationBuilder withDoseSchedule(Map<String, double> schedule) {
    _doseSchedule = schedule;
    return this;
  }

  MedicationBuilder withSingleDose(String time, double quantity) {
    _doseSchedule = {time: quantity};
    return this;
  }

  MedicationBuilder withMultipleDoses(List<String> times, double quantityEach) {
    _doseSchedule = {for (var time in times) time: quantityEach};
    return this;
  }

  MedicationBuilder withStock(double quantity) {
    _stockQuantity = quantity;
    return this;
  }

  MedicationBuilder withTakenDoses(List<String> doses, [String? date]) {
    _takenDosesToday = doses;
    _takenDosesDate = date ?? _getTodayString();
    return this;
  }

  MedicationBuilder withSkippedDoses(List<String> doses, [String? date]) {
    _skippedDosesToday = doses;
    _takenDosesDate = date ?? _getTodayString();
    return this;
  }

  MedicationBuilder withLastRefill(double amount) {
    _lastRefillAmount = amount;
    return this;
  }

  MedicationBuilder withLowStockThreshold(int days) {
    _lowStockThresholdDays = days;
    return this;
  }

  MedicationBuilder withLastDailyConsumption(double consumption) {
    _lastDailyConsumption = consumption;
    return this;
  }

  /// Configura el medicamento como "as needed" (a demanda)
  MedicationBuilder withAsNeeded() {
    _durationType = TreatmentDurationType.asNeeded;
    _dosageIntervalHours = 0;
    _doseSchedule = {};
    return this;
  }

  MedicationBuilder withFasting({
    required String type,
    required int duration,
    bool notify = true,
  }) {
    _requiresFasting = true;
    _fastingType = type;
    _fastingDurationMinutes = duration;
    _notifyFasting = notify;
    return this;
  }

  MedicationBuilder withFastingDisabled() {
    _requiresFasting = false;
    _fastingType = null;
    _fastingDurationMinutes = null;
    _notifyFasting = false;
    return this;
  }

  MedicationBuilder suspended([bool suspended = true]) {
    _isSuspended = suspended;
    return this;
  }

  MedicationBuilder withStartDate(DateTime date) {
    _startDate = date;
    return this;
  }

  MedicationBuilder withEndDate(DateTime date) {
    _endDate = date;
    return this;
  }

  MedicationBuilder withDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    return this;
  }

  MedicationBuilder withWeeklyPattern(List<int> weekdays) {
    _durationType = TreatmentDurationType.weeklyPattern;
    _weeklyDays = weekdays;
    return this;
  }

  MedicationBuilder withSpecificDates(List<String> dates) {
    _durationType = TreatmentDurationType.specificDates;
    _selectedDates = dates;
    return this;
  }

  MedicationBuilder withIntervalDays(int days) {
    _durationType = TreatmentDurationType.intervalDays;
    _dayInterval = days;
    return this;
  }

  /// Crea una copia del builder a partir de un medicamento existente
  MedicationBuilder.from(Medication medication) {
    _id = medication.id;
    _name = medication.name;
    _type = medication.type;
    _dosageIntervalHours = medication.dosageIntervalHours;
    _durationType = medication.durationType;
    _doseSchedule = medication.doseSchedule;
    _stockQuantity = medication.stockQuantity;
    _takenDosesToday = medication.takenDosesToday;
    _skippedDosesToday = medication.skippedDosesToday;
    _takenDosesDate = medication.takenDosesDate;
    _lastRefillAmount = medication.lastRefillAmount;
    _lowStockThresholdDays = medication.lowStockThresholdDays;
    _requiresFasting = medication.requiresFasting;
    _fastingType = medication.fastingType;
    _fastingDurationMinutes = medication.fastingDurationMinutes;
    _notifyFasting = medication.notifyFasting;
    _isSuspended = medication.isSuspended;
    _startDate = medication.startDate;
    _endDate = medication.endDate;
    _weeklyDays = medication.weeklyDays;
    _selectedDates = medication.selectedDates;
    _dayInterval = medication.dayInterval;
    _lastDailyConsumption = medication.lastDailyConsumption;
  }

  Medication build() {
    return Medication(
      id: _id,
      name: _name,
      type: _type,
      dosageIntervalHours: _dosageIntervalHours,
      durationType: _durationType,
      doseSchedule: _doseSchedule,
      stockQuantity: _stockQuantity,
      takenDosesToday: _takenDosesToday,
      skippedDosesToday: _skippedDosesToday,
      takenDosesDate: _takenDosesDate,
      lastRefillAmount: _lastRefillAmount,
      lowStockThresholdDays: _lowStockThresholdDays,
      requiresFasting: _requiresFasting,
      fastingType: _fastingType,
      fastingDurationMinutes: _fastingDurationMinutes,
      notifyFasting: _notifyFasting,
      isSuspended: _isSuspended,
      startDate: _startDate,
      endDate: _endDate,
      weeklyDays: _weeklyDays,
      selectedDates: _selectedDates,
      dayInterval: _dayInterval,
      lastDailyConsumption: _lastDailyConsumption,
    );
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
