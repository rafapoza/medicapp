import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../l10n/app_localizations.dart';
import 'settings/widgets/setting_option_card.dart';
import 'settings/widgets/info_card.dart';

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
    final l10n = AppLocalizations.of(context)!;

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
        text: l10n.settingsShareText,
      );

      if (!mounted) return;

      if (result.status == ShareResultStatus.success) {
        _showSnackBar(l10n.settingsExportSuccess, isError: false);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(l10n.settingsExportError(e.toString()), isError: true);
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
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog first
    final confirm = await _showConfirmDialog(
      l10n.settingsImportDialogTitle,
      l10n.settingsImportDialogMessage,
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
        throw Exception(l10n.settingsFilePathError);
      }

      // Import the database
      await DatabaseHelper.instance.importDatabase(filePath);

      if (!mounted) return;

      _showSnackBar(l10n.settingsImportSuccess, isError: false);

      // Show restart dialog
      _showRestartDialog();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(l10n.settingsImportError(e.toString()), isError: true);
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
    final l10n = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.btnContinue),
          ),
        ],
      ),
    );
  }

  /// Show restart dialog after import
  void _showRestartDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRestartDialogTitle),
        content: Text(l10n.settingsRestartDialogMessage),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to main screen
            },
            child: Text(l10n.settingsRestartDialogButton),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        children: [
          // Backup & Restore Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.settingsBackupSection,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Export Database Card
          SettingOptionCard(
            icon: Icons.upload_file,
            iconColor: theme.colorScheme.primary,
            title: l10n.settingsExportTitle,
            subtitle: l10n.settingsExportSubtitle,
            isLoading: _isExporting,
            enabled: !_isExporting && !_isImporting,
            onTap: _exportDatabase,
          ),

          // Import Database Card
          SettingOptionCard(
            icon: Icons.download_for_offline,
            iconColor: theme.colorScheme.secondary,
            title: l10n.settingsImportTitle,
            subtitle: l10n.settingsImportSubtitle,
            isLoading: _isImporting,
            enabled: !_isExporting && !_isImporting,
            onTap: _importDatabase,
          ),

          // Info Section
          const InfoCard(),
        ],
      ),
    );
  }
}
