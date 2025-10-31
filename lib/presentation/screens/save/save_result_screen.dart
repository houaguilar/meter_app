import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_derrame_providers.dart';
import 'package:meter_app/presentation/screens/projects/new_project/new_project_screen.dart';

import '../../../config/utils/security_service.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/entities/home/acero/columna/steel_column.dart';
import '../../../domain/entities/home/acero/losa_maciza/steel_slab.dart';
import '../../../domain/entities/home/acero/viga/steel_beam.dart';
import '../../../domain/entities/home/acero/zapata/steel_footing.dart';
import '../../../domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import '../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import '../../../domain/entities/home/estructuras/solado/solado.dart';
import '../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../domain/entities/home/losas/losas.dart';
import '../../blocs/projects/metrados/metrados_bloc.dart';
import '../../blocs/projects/metrados/result/result_bloc.dart';
import '../../blocs/projects/projects_bloc.dart';
import '../../providers/home/acero/columna/steel_column_providers.dart';
import '../../providers/home/acero/losa_maciza/steel_slab_providers.dart';
import '../../providers/home/acero/viga/steel_beam_providers.dart';
import '../../providers/home/acero/zapata/steel_footing_providers.dart';
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

    // 🔧 FIX: Inicialización más robusta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    try {
      // 🔧 FIX: Reset completo al inicializar
      context.read<ResultBloc>().add(ResetResultStateEvent());
      context.read<MetradosBloc>().add(ResetMetradoStateEvent());

      // Cargar proyectos después del reset
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          context.read<ProjectsBloc>().add(LoadProjectsEvent());
        }
      });

      print('🚀 Pantalla inicializada correctamente'); // Debug
    } catch (e) {
      print('❌ Error inicializando pantalla: $e'); // Debug
    }
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

  void _handleSave() async {
    print('🚀 Iniciando proceso de guardado...');

    if (!_formKey.currentState!.validate()) {
      print('❌ Formulario no válido');
      return;
    }

    final results = _getCalculatedResults();
    print('📊 Resultados obtenidos: ${results.length}');

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

    try {
      // ✅ PASO 1: Reset completo y agresivo
      print('🔄 Reseteando BLoCs...');
      context.read<ResultBloc>().add(ResetResultStateEvent());
      context.read<MetradosBloc>().add(ResetMetradoStateEvent());

      // ✅ PASO 2: Esperar que el reset termine completamente
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // ✅ PASO 3: Verificar estados iniciales
      final resultState = context.read<ResultBloc>().state;
      final metradoState = context.read<MetradosBloc>().state;

      print('📊 Estado ResultBloc: ${resultState.runtimeType}');
      print('📊 Estado MetradosBloc: ${metradoState.runtimeType}');

      if (resultState is! ResultInitial || metradoState is! MetradoInitial) {
        print('⚠️ Estados no se resetearon correctamente, forzando...');

        // Forzar reset adicional
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
      }

      // ✅ PASO 4: Crear metrado
      final sanitizedName = SecurityService.sanitizeText(_descriptionController.text.trim());
      print('📝 Creando metrado: "$sanitizedName" en proyecto $selectedProjectId');

      context.read<MetradosBloc>().add(
        CreateMetradoEvent(
          name: sanitizedName,
          projectId: int.parse(selectedProjectId!),
        ),
      );

    } catch (e) {
      print('❌ Error en proceso de guardado: $e');
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error interno: $e', isError: true);
      _resetBlocs();
    }
  }

  List<dynamic> _getCalculatedResults() {
    final allResults = <dynamic>[];

    try {
      // 🔧 FIX: Validar cada provider antes de leerlo
      final providers = [
            () => ref.read(ladrilloResultProvider),
            () => ref.read(falsoPisoResultProvider),
            () => ref.read(contrapisoResultProvider),
            () => ref.read(tarrajeoResultProvider),
            () => ref.read(tarrajeoDerrameResultProvider),
            () => ref.read(losaAligeradaResultProvider),
            () => ref.read(columnaResultProvider),
            () => ref.read(vigaResultProvider),
            () => ref.read(sobrecimientoResultProvider),
            () => ref.read(cimientoCorridoResultProvider),
            () => ref.read(soladoResultProvider),

            () => ref.read(steelColumnResultProvider),
            () => ref.read(steelBeamResultProvider),
            () => ref.read(steelSlabResultProvider),
            () => ref.read(steelFootingResultProvider),
      ];

      for (final providerReader in providers) {
        try {
          final results = providerReader();
          if (results.isNotEmpty) {
            allResults.addAll(results);
            print('📊 Agregados ${results.length} resultados de tipo ${results.first.runtimeType}');
          }
        } catch (e) {
          print('⚠️ Error leyendo provider: $e');
        }
      }

      print('📈 Total de resultados obtenidos: ${allResults.length}');
    } catch (e) {
      print('❌ Error obteniendo resultados: $e');
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
    if (result is Sobrecimiento) return 'Sobrecimientos';
    if (result is CimientoCorrido) return 'Cimientos Corridos';
    if (result is Solado) return 'Solados';

    if (result is SteelColumn) return 'Columnas de Acero';
    if (result is SteelBeam) return 'Vigas de Acero';
    if (result is SteelSlab) return 'Losas Macizas de Acero';
    if (result is SteelFooting) return 'Zapatas de Acero';

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
      case 'Sobrecimientos': return Icons.foundation;
      case 'Cimientos Corridos': return Icons.landscape;
      case 'Solados': return Icons.layers_outlined;
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

  // Manejadores de estado

  void _handleResultState(BuildContext context, ResultState state) {
    print('🔍 ResultState: ${state.runtimeType}'); // Debug

    if (state is ResultSuccess) {
      print('✅ Resultados guardados exitosamente'); // Debug
      setState(() {
        _isLoading = false;
      });
      _showMessage('Metrado guardado exitosamente');
      _clearForm();

      // Navegar después de un pequeño delay para mostrar el mensaje
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });

    } else if (state is ResultFailure) {
      print('❌ Error al guardar resultados: ${state.message}'); // Debug
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error al guardar resultados: ${state.message}', isError: true);
      _resetBlocs();
    }
  }

  void _handleMetradoState(BuildContext context, MetradosState state) {
    print('🔍 MetradosState recibido: ${state.runtimeType}');

    if (state is MetradoAdded) {
      print('✅ Metrado creado exitosamente con ID: ${state.metradoId}');

      final results = _getCalculatedResults();
      if (results.isEmpty) {
        print('❌ Error: No hay resultados para guardar');
        setState(() {
          _isLoading = false;
        });
        _showMessage('Error: No hay resultados para guardar', isError: true);
        return;
      }

      // ✅ Verificar estado de ResultBloc antes de proceder
      final currentResultState = context.read<ResultBloc>().state;
      print('📊 Estado actual de ResultBloc: ${currentResultState.runtimeType}');

      if (currentResultState is ResultLoading) {
        print('⚠️ ResultBloc está cargando, esperando...');
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _handleMetradoState(context, state);
          }
        });
        return;
      }

      // ✅ Guardar resultados con copia para evitar modificaciones
      print('💾 Guardando ${results.length} resultados...');

      // 🔍 Debug: Verificar tipos de resultados
      for (final result in results) {
        print('  📊 Tipo de resultado: ${result.runtimeType}');
        if (result is SteelColumn) {
          print('    - SteelColumn: ${result.description}');
          print('    - Barras: ${result.steelBars.length}');
          print('    - Estribos: ${result.stirrupDistributions.length}');
        } else if (result is SteelBeam) {
          print('    - SteelBeam: ${result.description}');
          print('    - Barras: ${result.steelBars.length}');
          print('    - Estribos: ${result.stirrupDistributions.length}');
        } else if (result is SteelSlab) {
          print('    - SteelSlab: ${result.description}');
          print('    - MeshBars: ${result.meshBars.length}');
        } else if (result is SteelFooting) {
          print('    - SteelFooting: ${result.description}');
        }
      }

      try {
        final copiedResults = results.map((r) => _createCopyOfResult(r)).toList();

        // 🔍 Debug: Verificar copias
        print('  📝 Resultados copiados: ${copiedResults.length}');
        for (final copied in copiedResults) {
          print('  📊 Copia tipo: ${copied.runtimeType}');
        }

        context.read<ResultBloc>().add(
          SaveResultEvent(
            results: copiedResults,
            metradoId: state.metradoId.toString(),
          ),
        );
      } catch (e) {
        print('❌ Error al disparar SaveResultEvent: $e');
        print('❌ Stack trace: ${StackTrace.current}');
        setState(() {
          _isLoading = false;
        });
        _showMessage('Error al guardar resultados: $e', isError: true);
        _resetBlocs();
      }

    } else if (state is MetradoFailure) {
      print('❌ Error creando metrado: ${state.message}');
      setState(() {
        _isLoading = false;
      });
      _showMessage('Error al crear metrado: ${state.message}', isError: true);
      _resetBlocs();

    } else if (state is MetradoNameAlreadyExists) {
      print('❌ Nombre de metrado duplicado: ${state.message}');
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
    // 🔧 FIX: Reset inmediato sin delay y con mejor manejo de errores
    try {
      if (mounted) {
        context.read<ResultBloc>().add(ResetResultStateEvent());
        context.read<MetradosBloc>().add(ResetMetradoStateEvent());
        print('🔄 BLoCs reseteados'); // Debug
      }
    } catch (e) {
      print('⚠️ Error al resetear BLoCs: $e'); // Debug
    }
  }

  dynamic _createCopyOfResult(dynamic result) {
    // Esto evita problemas de referencias compartidas
    if (result is Ladrillo) {
      return Ladrillo(
        idLadrillo: result.idLadrillo,
        description: result.description,
        tipoLadrillo: result.tipoLadrillo,
        factorDesperdicio: result.factorDesperdicio,
        factorDesperdicioMortero: result.factorDesperdicioMortero,
        proporcionMortero: result.proporcionMortero,
        tipoAsentado: result.tipoAsentado,
        largo: result.largo,
        altura: result.altura,
        area: result.area,
      );
    } else if (result is Columna) {
      return Columna(
        idColumna: result.idColumna,
        description: result.description,
        resistencia: result.resistencia,
        factorDesperdicio: result.factorDesperdicio,
        largo: result.largo,
        ancho: result.ancho,
        altura: result.altura,
        volumen: result.volumen,
      );
    }
    else if (result is Viga) {
      return Viga(
        idViga: result.idViga,
        description: result.description,
        resistencia: result.resistencia,
        factorDesperdicio: result.factorDesperdicio,
        largo: result.largo,
        ancho: result.ancho,
        altura: result.altura,
        volumen: result.volumen,
      );
    }
    else if (result is Sobrecimiento) {
      return Sobrecimiento(
        idSobrecimiento: result.idSobrecimiento,
        description: result.description,
        resistencia: result.resistencia,
        factorDesperdicio: result.factorDesperdicio,
        largo: result.largo,
        ancho: result.ancho,
        altura: result.altura,
        volumen: result.volumen,
      );
    }
    else if (result is CimientoCorrido) {
      return CimientoCorrido(
        idCimientoCorrido: result.idCimientoCorrido,
        description: result.description,
        resistencia: result.resistencia,
        factorDesperdicio: result.factorDesperdicio,
        largo: result.largo,
        ancho: result.ancho,
        altura: result.altura,
        volumen: result.volumen,
      );
    }
    else if (result is Solado) {
      return Solado(
        idSolado: result.idSolado,
        description: result.description,
        resistencia: result.resistencia,
        factorDesperdicio: result.factorDesperdicio,
        largo: result.largo,
        ancho: result.ancho,
        area: result.area,
        espesorFijo: result.espesorFijo,
      );
    }
    // ✅ COPIAS DE RESULTADOS DE ACERO
    else if (result is SteelColumn) {
      // Copiar listas embebidas
      final steelBarsCopy = result.steelBars.map((bar) => SteelBarEmbedded()
        ..idSteelBar = bar.idSteelBar
        ..quantity = bar.quantity
        ..diameter = bar.diameter
      ).toList();

      final stirrupDistributionsCopy = result.stirrupDistributions.map((dist) => StirrupDistributionEmbedded()
        ..idStirrupDistribution = dist.idStirrupDistribution
        ..quantity = dist.quantity
        ..separation = dist.separation
      ).toList();

      return SteelColumn(
        idSteelColumn: result.idSteelColumn,
        description: result.description,
        waste: result.waste,
        elements: result.elements,
        cover: result.cover,
        height: result.height,
        length: result.length,
        width: result.width,
        hasFooting: result.hasFooting,
        footingHeight: result.footingHeight,
        footingBend: result.footingBend,
        useSplice: result.useSplice,
        stirrupDiameter: result.stirrupDiameter,
        stirrupBendLength: result.stirrupBendLength,
        restSeparation: result.restSeparation,
        steelBars: steelBarsCopy,
        stirrupDistributions: stirrupDistributionsCopy,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
    }
    else if (result is SteelBeam) {
      // Copiar listas embebidas
      final steelBarsCopy = result.steelBars.map((bar) => SteelBeamBarEmbedded()
        ..idSteelBar = bar.idSteelBar
        ..quantity = bar.quantity
        ..diameter = bar.diameter
      ).toList();

      final stirrupDistributionsCopy = result.stirrupDistributions.map((dist) => SteelBeamStirrupDistributionEmbedded()
        ..idStirrupDistribution = dist.idStirrupDistribution
        ..quantity = dist.quantity
        ..separation = dist.separation
      ).toList();

      return SteelBeam(
        idSteelBeam: result.idSteelBeam,
        description: result.description,
        waste: result.waste,
        elements: result.elements,
        cover: result.cover,
        height: result.height,
        length: result.length,
        width: result.width,
        supportA1: result.supportA1,
        supportA2: result.supportA2,
        bendLength: result.bendLength,
        useSplice: result.useSplice,
        stirrupDiameter: result.stirrupDiameter,
        stirrupBendLength: result.stirrupBendLength,
        restSeparation: result.restSeparation,
        steelBars: steelBarsCopy,
        stirrupDistributions: stirrupDistributionsCopy,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
    }
    else if (result is SteelSlab) {
      // Copiar lista de meshBars embebidos
      final meshBarsCopy = result.meshBars.map((bar) => SteelMeshBarEmbedded()
        ..idSteelMeshBar = bar.idSteelMeshBar
        ..meshType = bar.meshType
        ..direction = bar.direction
        ..diameter = bar.diameter
        ..separation = bar.separation
      ).toList();

      // Copiar configuración superior embebida
      final superiorMeshConfigCopy = SuperiorMeshConfigEmbedded()
        ..idConfig = result.superiorMeshConfig.idConfig
        ..enabled = result.superiorMeshConfig.enabled;

      return SteelSlab(
        idSteelSlab: result.idSteelSlab,
        description: result.description,
        waste: result.waste,
        elements: result.elements,
        length: result.length,
        width: result.width,
        bendLength: result.bendLength,
        meshBars: meshBarsCopy,
        superiorMeshConfig: superiorMeshConfigCopy,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
    }
    else if (result is SteelFooting) {
      return SteelFooting(
        idSteelFooting: result.idSteelFooting,
        description: result.description,
        waste: result.waste,
        elements: result.elements,
        cover: result.cover,
        length: result.length,
        width: result.width,
        inferiorHorizontalDiameter: result.inferiorHorizontalDiameter,
        inferiorHorizontalSeparation: result.inferiorHorizontalSeparation,
        inferiorVerticalDiameter: result.inferiorVerticalDiameter,
        inferiorVerticalSeparation: result.inferiorVerticalSeparation,
        inferiorBendLength: result.inferiorBendLength,
        hasSuperiorMesh: result.hasSuperiorMesh,
        superiorHorizontalDiameter: result.superiorHorizontalDiameter,
        superiorHorizontalSeparation: result.superiorHorizontalSeparation,
        superiorVerticalDiameter: result.superiorVerticalDiameter,
        superiorVerticalSeparation: result.superiorVerticalSeparation,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
    }
    // Agregar otros tipos según necesidades...
    return result;
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