import 'package:flutter/material.dart';
import '../../models/medication.dart';
import '../../models/person.dart';
import '../../database/database_helper.dart';

/// Pantalla para gestionar la asignación de personas a un medicamento.
/// Permite ver qué personas están asignadas y agregar/remover asignaciones.
class MedicationPersonAssignmentScreen extends StatefulWidget {
  final Medication medication;

  const MedicationPersonAssignmentScreen({
    super.key,
    required this.medication,
  });

  @override
  State<MedicationPersonAssignmentScreen> createState() =>
      _MedicationPersonAssignmentScreenState();
}

class _MedicationPersonAssignmentScreenState
    extends State<MedicationPersonAssignmentScreen> {
  List<Person> _allPersons = [];
  List<Person> _assignedPersons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final allPersons = await DatabaseHelper.instance.getAllPersons();
      final assignedPersons = await DatabaseHelper.instance
          .getPersonsForMedication(widget.medication.id);

      setState(() {
        _allPersons = allPersons;
        _assignedPersons = assignedPersons;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignPerson(Person person) async {
    try {
      await DatabaseHelper.instance.assignMedicationToPerson(
        personId: person.id,
        medicationId: widget.medication.id,
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${person.name} asignado a ${widget.medication.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unassignPerson(Person person) async {
    // Mostrar confirmación
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar desasignación'),
          content: Text(
            '¿Desasignar a ${person.name} de ${widget.medication.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Desasignar'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await DatabaseHelper.instance.unassignMedicationFromPerson(
        personId: person.id,
        medicationId: widget.medication.id,
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${person.name} desasignado de ${widget.medication.name}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desasignar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Personas'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información del medicamento
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: widget.medication.type
                                .getColor(context)
                                .withOpacity(0.2),
                            child: Icon(
                              widget.medication.type.icon,
                              color: widget.medication.type.getColor(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.medication.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.medication.type.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: widget.medication.type
                                            .getColor(context),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Personas asignadas
                  Text(
                    'Personas asignadas (${_assignedPersons.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  if (_assignedPersons.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No hay personas asignadas a este medicamento',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._assignedPersons.map((person) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(person.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: Colors.orange,
                            onPressed: () => _unassignPerson(person),
                            tooltip: 'Desasignar',
                          ),
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 24),

                  // Personas disponibles para asignar
                  Text(
                    'Agregar personas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  ..._allPersons
                      .where((person) => !_assignedPersons
                          .any((assigned) => assigned.id == person.id))
                      .map((person) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: Icon(
                            Icons.person_outline,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        title: Text(person.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          color: Colors.green,
                          onPressed: () => _assignPerson(person),
                          tooltip: 'Asignar',
                        ),
                      ),
                    );
                  }).toList(),

                  if (_allPersons.length == _assignedPersons.length)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Colors.green.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Todas las personas están asignadas',
                                style: TextStyle(
                                  color: Colors.green.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
