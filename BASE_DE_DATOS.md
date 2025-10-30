# Base de datos

La aplicación utiliza SQLite para almacenar localmente todos los medicamentos. Los datos persisten entre sesiones de la aplicación.

### Características de la base de datos:

- **Patrón Singleton**: Una única instancia de `DatabaseHelper` gestiona todas las operaciones
- **CRUD completo**: Create, Read, Update, Delete
- **Tabla medications** (versión 16):
  - `id` (TEXT PRIMARY KEY)
  - `name` (TEXT NOT NULL)
  - `type` (TEXT NOT NULL)
  - `dosageIntervalHours` (INTEGER NOT NULL)
  - `durationType` (TEXT NOT NULL)
  - `customDays` (INTEGER NULLABLE) - OBSOLETO: Mantenido solo para compatibilidad con versiones anteriores
  - `selectedDates` (TEXT NULLABLE) - Fechas específicas para el tratamiento
  - `weeklyDays` (TEXT NULLABLE) - Días de la semana para tratamiento semanal
  - `dayInterval` (INTEGER NULLABLE) - Intervalo en días para tratamientos como "cada N días"
  - `doseTimes` (TEXT NOT NULL) - Horarios de tomas en formato "HH:mm" separados por comas (generado automáticamente desde doseSchedule para compatibilidad)
  - `doseSchedule` (TEXT NOT NULL) - Horarios y cantidades en formato JSON: {"HH:mm": cantidad, ...}
  - `stockQuantity` (REAL NOT NULL DEFAULT 0) - Cantidad de medicamento disponible
  - `takenDosesToday` (TEXT NOT NULL DEFAULT '') - Horarios de tomas tomadas hoy (descuentan stock)
  - `skippedDosesToday` (TEXT NOT NULL DEFAULT '') - Horarios de tomas no tomadas hoy (no descuentan stock)
  - `extraDosesToday` (TEXT NOT NULL DEFAULT '') - Horarios de tomas extra/excepcionales registradas hoy fuera del horario programado
  - `takenDosesDate` (TEXT NULLABLE) - Fecha de las tomas registradas en formato "yyyy-MM-dd"
  - `lastRefillAmount` (REAL NULLABLE) - Última cantidad de recarga (usada como sugerencia en futuras recargas)
  - `lowStockThresholdDays` (INTEGER NOT NULL DEFAULT 3) - Días de anticipación para aviso de stock bajo configurables por medicamento
  - `startDate` (TEXT NULLABLE) - Fecha de inicio del tratamiento
  - `endDate` (TEXT NULLABLE) - Fecha de fin del tratamiento
  - `requiresFasting` (INTEGER NOT NULL DEFAULT 0) - Si el medicamento requiere ayuno (0=no, 1=sí)
  - `fastingType` (TEXT NULLABLE) - Tipo de ayuno: 'before' (antes de tomar) o 'after' (después de tomar)
  - `fastingDurationMinutes` (INTEGER NULLABLE) - Duración del período de ayuno en minutos
  - `notifyFasting` (INTEGER NOT NULL DEFAULT 0) - Si se deben enviar notificaciones de ayuno (0=no, 1=sí)
- **Tabla dose_history** (desde versión 11): Historial completo de todas las dosis
  - `id` (TEXT PRIMARY KEY)
  - `medicationId` (TEXT NOT NULL)
  - `medicationName` (TEXT NOT NULL)
  - `medicationType` (TEXT NOT NULL)
  - `scheduledDateTime` (TEXT NOT NULL) - Hora programada de la toma
  - `registeredDateTime` (TEXT NOT NULL) - Hora real de registro
  - `status` (TEXT NOT NULL) - Estado: 'taken' o 'skipped'
  - `quantity` (REAL NOT NULL) - Cantidad tomada
  - `notes` (TEXT NULLABLE) - Notas opcionales
  - `isExtraDose` (INTEGER NOT NULL DEFAULT 0) - Indica si es una toma extra/excepcional (0=no, 1=sí)
  - Índices en `medicationId` y `scheduledDateTime` para consultas rápidas
- **Migraciones**: Sistema de versionado para actualizar el esquema sin perder datos
  - Versión 1 → 2: Añadidos campos de duración de tratamiento y horarios
  - Versión 2 → 11: Múltiples mejoras incluyendo sistema de historial de dosis
  - Versión 11 → 12: Añadido campo `dayInterval` para soportar tratamientos con intervalo de días (ej: cada 2 días, cada 3 días)
  - Versión 12 → 13: Añadidos campos de ayuno (`requiresFasting`, `fastingType`, `fastingDurationMinutes`, `notifyFasting`)
  - Versión 13 → 14: Añadido campo `isSuspended` para suspensión de medicamentos
  - Versión 14 → 15: Añadido campo `lastDailyConsumption` para medicamentos ocasionales
  - Versión 15 → 16: Añadidos campos `extraDosesToday` (medications) e `isExtraDose` (dose_history) para tomas excepcionales
