import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/utils/security_service.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';
import '../../blocs/projects/metrados/metrados_bloc.dart';
import '../../blocs/projects/metrados/result/result_bloc.dart';
import '../../blocs/projects/projects_bloc.dart';
import '../../providers/home/estructuras/structural_element_providers.dart';
import '../../providers/providers.dart';
import '../../providers/losas/losas_aligeradas_providers.dart';
import '../../providers/tarrajeo/tarrajeo_providers.dart';

class SaveResultScreen extends ConsumerStatefulWidget {
  const SaveResultScreen({super.key});

  @override
  ConsumerState<SaveResultScreen> createState() => _SaveResultScreenState();
}

class _SaveResultScreenState extends ConsumerState<SaveResultScreen> {
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? selectedProjectId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(ladrilloResultProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardar Metrado'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ResultBloc, ResultState>(
            listener: _handleResultState,
          ),
          BlocListener<MetradosBloc, MetradosState>(
            listener: _handleMetradoState,
          ),
        ],
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            _buildProjectSelector(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 24),
            _buildResultSummary(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Información',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona un proyecto existente o crea uno nuevo para guardar tus cálculos.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSelector() {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Cargando proyectos...'),
                ],
              ),
            ),
          );
        } else if (state is ProjectSuccess) {
          return _buildProjectDropdown(state.projects);
        } else if (state is ProjectFailure) {
          return _buildErrorCard(state.message);
        } else {
          return _buildErrorCard('Error al cargar proyectos');
        }
      },
    );
  }

  Widget _buildProjectDropdown(List<Project> projects) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Proyecto',
        prefixIcon: const Icon(Icons.folder_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      value: selectedProjectId,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona un proyecto';
        }
        return null;
      },
      items: _getProjectDropdownItems(projects),
      onChanged: (value) {
        if (value == 'add_project') {
          _navigateToAddProject();
        } else {
          setState(() {
            selectedProjectId = value;
          });
        }
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Descripción del metrado',
        hintText: 'Ej: Muro perimetral principal',
        prefixIcon: const Icon(Icons.description_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        counterText: '${_descriptionController.text.length}/100',
      ),
      maxLength: 100,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor ingresa una descripción';
        }

        // Validación de seguridad
        final securityResult = SecurityService.validateTextSecurity(value);
        if (!securityResult.isValid) {
          return securityResult.errorMessage;
        }

        return null;
      },
      onChanged: (value) {
        setState(() {}); // Para actualizar el contador
      },
    );
  }

  Widget _buildResultSummary() {
    final allResults = _getAllResults();

    if (allResults.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.warning_amber_outlined,
                  color: Colors.orange.shade700, size: 32),
              const SizedBox(height: 8),
              Text(
                'No hay resultados para guardar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Realiza algunos cálculos antes de guardar un metrado.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize_outlined, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Resumen de Resultados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._buildResultsSummary(allResults),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildResultsSummary(List<dynamic> results) {
    final summary = <String, int>{};

    for (var result in results) {
      final type = _getResultType(result);
      summary[type] = (summary[type] ?? 0) + 1;
    }

    return summary.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Icon(_getResultIcon(entry.key), size: 16, color: Colors.green.shade600),
            const SizedBox(width: 8),
            Text('${entry.key}: ${entry.value} elemento${entry.value != 1 ? 's' : ''}'),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSaveButton() {
    final hasResults = _getAllResults().isNotEmpty;

    return ElevatedButton.icon(
      onPressed: _isLoading || !hasResults ? null : _saveResult,
      icon: _isLoading
          ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2)
      )
          : const Icon(Icons.save_outlined),
      label: Text(_isLoading ? 'Guardando...' : 'Guardar Metrado'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 32),
            const SizedBox(height: 8),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                context.read<ProjectsBloc>().add(LoadProjectsEvent());
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getProjectDropdownItems(List<Project> projects) {
    final items = projects
        .map((project) => DropdownMenuItem<String>(
      value: project.id.toString(),
      child: Text(
        project.name,
        overflow: TextOverflow.ellipsis,
      ),
    ))
        .toList();

    // Añadir opción para crear nuevo proyecto
    items.add(
      DropdownMenuItem<String>(
        value: 'add_project',
        child: Row(
          children: [
            Icon(Icons.add_circle_outline,
                color: Theme.of(context).primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Crear nuevo proyecto',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    return items;
  }

  void _navigateToAddProject() async {
    // Determinar la ruta correcta según el tipo de resultado
    final allResults = _getAllResults();
    if (allResults.isEmpty) {
      _showError('No hay resultados para guardar');
      return;
    }

    final routeName = _getNewProjectRoute(allResults.first);

    try {
      await context.pushNamed(routeName);
      // Recargar proyectos después de crear uno nuevo
      if (mounted) {
        context.read<ProjectsBloc>().add(LoadProjectsEvent());
      }
    } catch (e) {
      _showError('Error al navegar: $e');
    }
  }

  String _getNewProjectRoute(dynamic result) {
    if (result is Ladrillo) return 'new-project-ladrillo';
    if (result is Piso) return 'new-project-piso';
    if (result is Tarrajeo) return 'new-project-tarrajeo';
    if (result is LosaAligerada) return 'new-project-losas';
    if (result is Columna || result is Viga) return 'new-project-structural';
    return 'new-project'; // Fallback
  }

  void _saveResult() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedProjectId == null) {
      _showError('Por favor selecciona un proyecto');
      return;
    }

    final allResults = _getAllResults();
    if (allResults.isEmpty) {
      _showError('No hay resultados para guardar');
      return;
    }

    // Validar seguridad de los datos
    final securityResult = SecurityService.validateListSize(allResults, 'Resultados');
    if (!securityResult.isValid) {
      _showError(securityResult.errorMessage);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Sanitizar descripción
    final sanitizedDescription = SecurityService.sanitizeText(_descriptionController.text.trim());

    context.read<MetradosBloc>().add(
      CreateMetradoEvent(
        name: sanitizedDescription,
        projectId: int.parse(selectedProjectId!),
      ),
    );
  }

  List<dynamic> _getAllResults() {
    final allResults = <dynamic>[];

    // Obtener todos los tipos de resultados
    final ladrillos = ref.read(ladrilloResultProvider);
    final pisos = ref.read(pisosResultProvider);
    final tarrajeos = ref.read(tarrajeoResultProvider);
    final losas = ref.read(losaAligeradaResultProvider);
    final columnas = ref.read(columnaResultProvider);
    final vigas = ref.read(vigaResultProvider);

    allResults.addAll(ladrillos);
    allResults.addAll(pisos);
    allResults.addAll(tarrajeos);
    allResults.addAll(losas);
    allResults.addAll(columnas);
    allResults.addAll(vigas);

    return allResults;
  }

  String _getResultType(dynamic result) {
    if (result is Ladrillo) return 'Ladrillos';
    if (result is Piso) return 'Pisos';
    if (result is Tarrajeo) return 'Tarrajeos';
    if (result is LosaAligerada) return 'Losas Aligeradas';
    if (result is Columna) return 'Columnas';
    if (result is Viga) return 'Vigas';
    return 'Desconocido';
  }

  IconData _getResultIcon(String type) {
    switch (type) {
      case 'Ladrillos': return Icons.grid_view;
      case 'Pisos': return Icons.grid_on;
      case 'Tarrajeos': return Icons.brush;
      case 'Losas Aligeradas': return Icons.layers;
      case 'Columnas': return Icons.view_column;
      case 'Vigas': return Icons.horizontal_rule;
      default: return Icons.construction;
    }
  }

  void _handleResultState(BuildContext context, ResultState state) {
    if (state is ResultSuccess) {
      _showSuccess('Resultado guardado con éxito');
      _clearResults();
      Navigator.pop(context);
    } else if (state is ResultFailure) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al guardar: ${state.message}');
    }
  }

  void _handleMetradoState(BuildContext context, MetradosState state) {
    if (state is MetradoAdded) {
      context.read<ResultBloc>().add(
        SaveResultEvent(
          results: _getAllResults(),
          metradoId: state.metradoId.toString(),
        ),
      );
    } else if (state is MetradoFailure) {
      setState(() {
        _isLoading = false;
      });
      _showError('Error al crear metrado: ${state.message}');
    } else if (state is MetradoNameAlreadyExists) {
      setState(() {
        _isLoading = false;
      });
      _showError(state.message);
    }
  }

  void _clearResults() {
    // Limpiar todos los providers de resultados
    ref.read(ladrilloResultProvider.notifier).clearList();
    ref.read(pisosResultProvider.notifier).clearList();
    ref.read(tarrajeoResultProvider.notifier).clearList();
    ref.read(losaAligeradaResultProvider.notifier).clearList();
    ref.read(columnaResultProvider.notifier).clearList();
    ref.read(vigaResultProvider.notifier).clearList();
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}