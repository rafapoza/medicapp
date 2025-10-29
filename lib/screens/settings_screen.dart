import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';

/// Settings screen with backup/restore functionality
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  /// Export the database and share it
  Future<void> _exportDatabase() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Export database to a temporary file
      final exportPath = await DatabaseHelper.instance.exportDatabase();

      if (!mounted) return;

      // Share the file
      final result = await Share.shareXFiles(
        [XFile(exportPath)],
        text: 'MedicApp Database Backup',
      );

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        _showSnackBar('Base de datos exportada correctamente', isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al exportar: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Import a database from a file
  Future<void> _importDatabase() async {
    // Show confirmation dialog first
    final confirm = await _showConfirmDialog(
      'Importar Base de Datos',
      'Esta acción reemplazará todos tus datos actuales con los datos del archivo importado.\n\n¿Estás seguro de continuar?',
    );

    if (confirm != true) return;

    setState(() {
      _isImporting = true;
    });

    try {
      // Pick a file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isImporting = false;
        });
        return;
      }

      final filePath = result.files.first.path;
      if (filePath == null) {
        throw Exception('No se pudo obtener la ruta del archivo');
      }

      // Import the database
      await DatabaseHelper.instance.importDatabase(filePath);

      if (!mounted) return;

      _showSnackBar('Base de datos importada correctamente', isError: false);

      // Show restart dialog
      _showRestartDialog();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al importar: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  /// Show a confirmation dialog
  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  /// Show restart dialog after import
  void _showRestartDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Importación Completada'),
        content: const Text(
          'La base de datos se ha importado correctamente.\n\n'
          'Por favor, reinicia la aplicación para ver los cambios.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to main screen
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Show a snackbar message
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        children: [
          // Backup & Restore Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Copia de Seguridad',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Export Database Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.upload_file,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Exportar Base de Datos'),
              subtitle: const Text(
                'Guarda una copia de todos tus medicamentos e historial',
              ),
              trailing: _isExporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              enabled: !_isExporting && !_isImporting,
              onTap: _exportDatabase,
            ),
          ),

          // Import Database Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: Icon(
                Icons.download_for_offline,
                color: theme.colorScheme.secondary,
              ),
              title: const Text('Importar Base de Datos'),
              subtitle: const Text(
                'Restaura una copia de seguridad previamente exportada',
              ),
              trailing: _isImporting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              enabled: !_isExporting && !_isImporting,
              onTap: _importDatabase,
            ),
          ),

          // Info Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Información',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Al exportar, se creará un archivo de copia de seguridad que podrás guardar en tu dispositivo o compartir.\n\n'
                      '• Al importar, todos los datos actuales serán reemplazados por los del archivo seleccionado.\n\n'
                      '• Se recomienda hacer copias de seguridad regularmente.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
