import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../models/person.dart';
import '../../l10n/app_localizations.dart';
import 'add_edit_person_screen.dart';

/// Screen for managing persons (users of the app)
class PersonsManagementScreen extends StatefulWidget {
  const PersonsManagementScreen({super.key});

  @override
  State<PersonsManagementScreen> createState() => _PersonsManagementScreenState();
}

class _PersonsManagementScreenState extends State<PersonsManagementScreen> {
  List<Person> _persons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  /// Load all persons from database
  Future<void> _loadPersons() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final persons = await DatabaseHelper.instance.getAllPersons();
      if (mounted) {
        setState(() {
          _persons = persons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showSnackBar('Error al cargar personas: $e', isError: true);
      }
    }
  }

  /// Navigate to add person screen
  Future<void> _addPerson() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditPersonScreen(),
      ),
    );

    if (result == true) {
      _loadPersons();
    }
  }

  /// Navigate to edit person screen
  Future<void> _editPerson(Person person) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPersonScreen(person: person),
      ),
    );

    if (result == true) {
      _loadPersons();
    }
  }

  /// Delete a person
  Future<void> _deletePerson(Person person) async {
    final l10n = AppLocalizations.of(context)!;

    // Don't allow deleting the default person
    if (person.isDefault) {
      _showSnackBar('No puedes eliminar la persona por defecto', isError: true);
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${person.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.btnCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DatabaseHelper.instance.deletePerson(person.id);
      _showSnackBar('Persona eliminada correctamente', isError: false);
      _loadPersons();
    } catch (e) {
      _showSnackBar('Error al eliminar persona: $e', isError: true);
    }
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
        title: const Text('Gestión de Personas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _persons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay personas registradas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Añade una persona para empezar',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _persons.length,
                  itemBuilder: (context, index) {
                    final person = _persons[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(child: Text(person.name)),
                            if (person.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  'Por defecto',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editPerson(person),
                              tooltip: 'Editar',
                            ),
                            if (!person.isDefault)
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () => _deletePerson(person),
                                tooltip: 'Eliminar',
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPerson,
        icon: const Icon(Icons.person_add),
        label: const Text('Añadir Persona'),
      ),
    );
  }
}
