// lib/presentation/screens/save/save_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/screens/projects/new_project/new_project_screen.dart';

import '../../../config/utils/security_service.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';
import '../../blocs/projects/metrados/metrados_bloc.dart';
import '../../blocs/projects/metrados/result/result_bloc.dart';
import '../../blocs/projects/projects_bloc.dart';
import '../../providers/providers.dart';

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
  List<Project> _projects = [];
  String? _pendingProjectName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
    context.read<ResultBloc>().add(ResetResultStateEvent());
    context.read<MetradosBloc>().add(ResetMetradoStateEvent());
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          BlocListener<ProjectsBloc, ProjectsState>(
            listener: _handleProjectsState,
          ),
        ],
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildInfoSection(),
            const SizedBox(height: 20),
            _buildProjectSection(),
            const SizedBox(height: 16),
            _buildNameSection(),
            const SizedBox(height: 24),
            _buildResultsSection(),
            const SizedBox(height: 32),
            _buildSaveSection(),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.blue.shade600,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Selecciona un proyecto existente o crea uno nuevo para guardar tus cálculos. '
                    'Puedes usar el mismo nombre en proyectos diferentes.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Proyecto *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  return _buildProjectDropdownContent(state);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDropdownContent(ProjectsState state) {
    if (state is ProjectLoading) {
      return Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
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
      );
    }

    if (state is ProjectFailure) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Error al cargar proyectos',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.read<ProjectsBloc>().add(LoadProjectsEvent()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state is ProjectSuccess) {
      _projects = state.projects;
      return _buildProjectDropdown();
    }

    return Container(
      height: 56,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('No hay proyectos disponibles'),
    );
  }

  Widget _buildProjectDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedProjectId,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        hintText: 'Selecciona un proyecto',
        prefixIcon: const Icon(Icons.folder_outlined),
      ),
      validator: (value) {
        if (value == null || value.isEmpty || value == 'add_project') {
          return 'Por favor selecciona un proyecto válido';
        }
        return null;
      },
      items: [
        ..._projects.map((project) {
          return DropdownMenuItem<String>(
            value: project.id.toString(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.folder, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    project.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
        DropdownMenuItem<String>(
          value: 'add_project',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.green.shade600),
              const SizedBox(width: 8),
              const Text('Crear nuevo proyecto'),
            ],
          ),
        ),
      ],
      onChanged: (String? newValue) {
        if (newValue == 'add_project') {
          _navigateToNewProject();
        } else {
          setState(() {
            selectedProjectId = newValue;
          });
        }
      },
    );
  }

  Widget _buildNameSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nombre del metrado *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLength: 100,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Ej: Metrado de muros - Primer piso',
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un nombre para el metrado';
                  }
                  if (value.trim().length < 3) {
                    return 'El nombre debe tener al menos 3 caracteres';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    final results = _getCalculatedResults();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (results.isEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.warning_outlined, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Sin resultados para guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ve a los módulos de cálculo para generar resultados primero.',
                  style: TextStyle(fontSize: 14),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Resultados a guardar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._buildResultsList(results),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResultsList(List<dynamic> results) {
    final summary = <String, int>{};

    for (var result in results) {
      final type = _getResultType(result);
      summary[type] = (summary[type] ?? 0) + 1;
    }

    return summary.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              _getResultIcon(entry.key),
              size: 16,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '${entry.key}: ${entry.value} elemento${entry.value > 1 ? 's' : ''}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSaveSection() {
    final hasResults = _getCalculatedResults().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isLoading || !hasResults ? null : _handleSave,
        icon: _isLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Icon(Icons.save_outlined),
        label: Text(_isLoading ? 'Guardando...' : 'Guardar Metrado'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Métodos de lógica

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final results = _getCalculatedResults();
    if (results.isEmpty) {
      _showMessage('No hay resultados para guardar', isError: true);
      return;
    }

    final securityResult = SecurityService.validateListSize(results, 'Resultados');
    if (!securityResult.isValid) {
      _showMessage(securityResult.errorMessage, isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final sanitizedName = SecurityService.sanitizeText(_descriptionController.text.trim());

    context.read<MetradosBloc>().add(
      CreateMetradoEvent(
        name: sanitizedName,
        projectId: int.parse(selectedProjectId!),
      ),
    );
  }

  List<dynamic> _getCalculatedResults() {
    final allResults = <dynamic>[];

    try {
      allResults.addAll(ref.read(ladrilloResultProvider));
      allResults.addAll(ref.read(falsoPisoResultProvider));
      allResults.addAll(ref.read(contrapisoResultProvider));
      allResults.addAll(ref.read(tarrajeoResultProvider));
      allResults.addAll(ref.read(losaAligeradaResultProvider));
      allResults.addAll(ref.read(columnaResultProvider));
      allResults.addAll(ref.read(vigaResultProvider));
    } catch (e) {
      debugPrint('Error obteniendo resultados: $e');
    }

    return allResults;
  }

  String _getResultType(dynamic result) {
    if (result is Ladrillo) return 'Ladrillos';
    if (result is Piso) return 'Pisos';
    if (result is Tarrajeo) return 'Tarrajeos';
    if (result is LosaAligerada) return 'Losas Aligeradas';
    if (result is Columna) return 'Columnas';
    if (result is Viga) return 'Vigas';
    return 'Elementos';
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

  void _navigateToNewProject() {
    final results = _getCalculatedResults();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewProjectScreen(),
      ),
    );
  }

  String _getNewProjectRoute(dynamic result) {
    if (result is Ladrillo) return 'new-project-ladrillo';
    if (result is Piso) return 'new-project-piso';
    if (result is Tarrajeo) return 'new-project-tarrajeo';
    if (result is LosaAligerada) return 'new-project-losas';
    if (result is Columna || result is Viga) return 'new-project-structural';
    return 'new-project';
  }

  // Manejadores de estado

  void _handleResultState(BuildContext context, ResultState state) {
    if (state is ResultSuccess) {
      _showMessage('Metrado guardado exitosamente');
      _clearForm();
      Navigator.pop(context);
    } else if (state is ResultFailure) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error al guardar: ${state.message}', isError: true);
      _resetBlocs();
    }
  }

  void _handleMetradoState(BuildContext context, MetradosState state) {
    if (state is MetradoAdded) {
      final results = _getCalculatedResults();
      context.read<ResultBloc>().add(
        SaveResultEvent(
          results: results,
          metradoId: state.metradoId.toString(),
        ),
      );
    } else if (state is MetradoFailure) {
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error al crear metrado: ${state.message}', isError: true);
      _resetBlocs();
    } else if (state is MetradoNameAlreadyExists) {
      setState(() {
        _isLoading = false;
      });
      _showMessage(
        '${state.message}\nPuedes usar el mismo nombre en proyectos diferentes.',
        isError: true,
      );
      _resetBlocs();
      _selectAllText();
    }
  }

  void _handleProjectsState(BuildContext context, ProjectsState state) {
    if (state is ProjectSuccess && _pendingProjectName != null) {
      try {
        final newProject = state.projects.firstWhere(
              (project) => project.name == _pendingProjectName,
        );
        setState(() {
          selectedProjectId = newProject.id.toString();
          _pendingProjectName = null;
        });
      } catch (e) {
        if (state.projects.isNotEmpty) {
          setState(() {
            selectedProjectId = state.projects.first.id.toString();
            _pendingProjectName = null;
          });
        }
      }
    }
  }

  // Métodos auxiliares

  void _clearForm() {
    _descriptionController.clear();
    setState(() {
      selectedProjectId = null;
      _isLoading = false;
    });
  }

  void _selectAllText() {
    _descriptionController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _descriptionController.text.length,
    );
  }

  void _resetBlocs() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ResultBloc>().add(ResetResultStateEvent());
        context.read<MetradosBloc>().add(ResetMetradoStateEvent());
      }
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        duration: Duration(seconds: isError ? 4 : 3),
        action: isError
            ? SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        )
            : null,
      ),
    );
  }
}