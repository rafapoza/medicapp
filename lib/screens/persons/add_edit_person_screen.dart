import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../database/database_helper.dart';
import '../../models/person.dart';
import '../../l10n/app_localizations.dart';

/// Screen for adding or editing a person
class AddEditPersonScreen extends StatefulWidget {
  final Person? person;

  const AddEditPersonScreen({
    super.key,
    this.person,
  });

  @override
  State<AddEditPersonScreen> createState() => _AddEditPersonScreenState();
}

class _AddEditPersonScreenState extends State<AddEditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  bool get _isEditing => widget.person != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.person!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Save the person
  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = _nameController.text.trim();

      if (_isEditing) {
        // Update existing person
        final updatedPerson = widget.person!.copyWith(name: name);
        await DatabaseHelper.instance.updatePerson(updatedPerson);
        if (mounted) {
          _showSnackBar('Persona actualizada correctamente', isError: false);
        }
      } else {
        // Create new person
        final newPerson = Person(
          id: const Uuid().v4(),
          name: name,
          isDefault: false,
        );
        await DatabaseHelper.instance.insertPerson(newPerson);
        if (mounted) {
          _showSnackBar('Persona añadida correctamente', isError: false);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error al guardar persona: $e', isError: true);
      }
    }
  }

  /// Show a snackbar message
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Persona' : 'Añadir Persona'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Name field
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Introduce el nombre',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        if (value.trim().length < 2) {
                          return 'El nombre debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                      enabled: !_isLoading,
                      autofocus: !_isEditing,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _isLoading ? null : _savePerson,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEditing ? 'Guardar Cambios' : 'Añadir Persona'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
