// lib/presentation/screens/projects/metrados/metrados_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/projects/metrado/metrado.dart';
import '../../../blocs/projects/metrados/metrados_bloc.dart';
import '../combined/combined_results_screen.dart';

class MetradosScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const MetradosScreen({
    required this.projectId,
    required this.projectName,
    super.key
  });

  @override
  State<MetradosScreen> createState() => _MetradosScreenState();
}

class _MetradosScreenState extends State<MetradosScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Estado de selección múltiple
  final Set<int> _selectedMetrados = {};
  bool _selectionMode = false;

  // Animaciones
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _selectionModeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMetrados();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INICIALIZACIÓN Y CONFIGURACIÓN
  // ═══════════════════════════════════════════════════════════════════════════

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _selectionModeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  void _loadMetrados() {
    context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: widget.projectId));
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTROL DE SELECCIÓN MÚLTIPLE
  // ═══════════════════════════════════════════════════════════════════════════

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedMetrados.clear();
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMetrados.clear();
    });
  }

  void _toggleMetradoSelection(int metradoId) {
    setState(() {
      if (_selectedMetrados.contains(metradoId)) {
        _selectedMetrados.remove(metradoId);
      } else {
        _selectedMetrados.add(metradoId);
      }
    });
  }

  void _selectAllMetrados(List<Metrado> metrados) {
    setState(() {
      if (_selectedMetrados.length == metrados.length) {
        _selectedMetrados.clear();
      } else {
        _selectedMetrados.addAll(metrados.map((m) => m.id));
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCIONES PRINCIPALES
  // ═══════════════════════════════════════════════════════════════════════════

  void _combineSelectedMetrados() {
    if (_selectedMetrados.length < 2) {
      _showErrorSnackBar('Selecciona al menos 2 metrados para combinar');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CombinedResultsScreen(
          projectId: widget.projectId,
          selectedMetradoIds: _selectedMetrados.toList(),
          projectName: widget.projectName,
        ),
      ),
    );
  }

  void _deleteSelectedMetrados(List<int> metradoIds) {
    final currentState = context.read<MetradosBloc>().state;
    if (currentState is MetradoSuccess) {
      final metrados = currentState.metrados;

      for (final metradoId in metradoIds) {
        final metrado = metrados.firstWhere((m) => m.id == metradoId);
        context.read<MetradosBloc>().add(DeleteMetradoEvent(metrado: metrado));
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MANEJO DE EVENTOS
  // ═══════════════════════════════════════════════════════════════════════════

  void _handleMetradoTap(Metrado metrado) {
    if (_selectionMode) {
      _toggleMetradoSelection(metrado.id);
    } else {
      // Navegar a ResultScreen con todos los parámetros necesarios
      context.pushNamed(
        'results',
        pathParameters: {
          'projectId': widget.projectId.toString(),
          'projectName': widget.projectName,
          'metradoId': metrado.id.toString(),
        },
      );
    }
  }

  void _handleMetradoLongPress(Metrado metrado) {
    if (!_selectionMode) {
      _toggleSelectionMode();
      _toggleMetradoSelection(metrado.id);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DIÁLOGOS Y CONFIRMACIONES
  // ═══════════════════════════════════════════════════════════════════════════

  void _showDeleteConfirmation(List<int> metradoIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${metradoIds.length} '
              '${metradoIds.length == 1 ? "metrado" : "metrados"}?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedMetrados(metradoIds);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showProjectInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.secondary),
            const SizedBox(width: 8),
            const Text('Información del Proyecto'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proyecto: ${widget.projectName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('ID: ${widget.projectId}'),
            const SizedBox(height: 16),
            const Text(
              'Funcionalidad:\n'
                  'Seleccione para ver detalles o use el modo selección.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<MetradosBloc, MetradosState>(
              builder: (context, state) {
                if (state is MetradoSuccess) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ${state.metrados.length} metrados',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (_selectionMode)
                        Text(
                          'Seleccionados: ${_selectedMetrados.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  );
                }
                return const Text(
                  'Cargando metrados...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MÉTODOS AUXILIARES
  // ═══════════════════════════════════════════════════════════════════════════

  List<Metrado> _filterMetrados(List<Metrado> metrados) {
    if (_searchQuery.isEmpty) return metrados;

    return metrados.where((metrado) {
      return metrado.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectionMode
            ? Text(
          '${_selectedMetrados.length} seleccionados',
          key: const ValueKey('selection-title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        )
            : Text(
          widget.projectName,
          key: const ValueKey('project-title'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // CAMBIO 1: Siempre mostrar el botón de retroceso en lugar del icono info
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Volver',
      ),
      // CAMBIO 2: Mover el botón de información al lado del botón cerrar
      actions: [
        if (_selectionMode) ...[
          BlocBuilder<MetradosBloc, MetradosState>(
            builder: (context, state) {
              if (state is MetradoSuccess) {
                return IconButton(
                  icon: Icon(
                    _selectedMetrados.length == state.metrados.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  onPressed: () => _selectAllMetrados(state.metrados),
                  tooltip: _selectedMetrados.length == state.metrados.length
                      ? 'Deseleccionar todos'
                      : 'Seleccionar todos',
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _exitSelectionMode,
            tooltip: 'Salir de selección',
          ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showProjectInfo,
            tooltip: 'Información del proyecto',
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
            tooltip: 'Cerrar',
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      key: _refreshKey,
      onRefresh: () async {
        _loadMetrados();
      },
      color: AppColors.secondary,
      child: Column(
        children: [
          _buildProjectInfoCard(),
          _buildSearchBar(),
          Expanded(
            child: BlocConsumer<MetradosBloc, MetradosState>(
              listener: (context, state) {
                if (state is MetradoDeleted) {
                  _showSuccessSnackBar('Metrado(s) eliminado(s) correctamente');
                  _exitSelectionMode();
                  context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: widget.projectId));
                } else if (state is MetradoEdited) {
                  _showSuccessSnackBar('Metrado actualizado correctamente');
                } else if (state is MetradoFailure) {
                  _showErrorSnackBar(state.message);
                }
              },
              builder: (context, state) {
                if (state is MetradoLoading) {
                  return _buildLoadingState();
                } else if (state is MetradoSuccess) {
                  final filteredMetrados = _filterMetrados(state.metrados);
                  if (filteredMetrados.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildMetradosList(filteredMetrados);
                } else if (state is MetradoFailure) {
                  return _buildErrorState(state.message);
                }
                return _buildLoadingState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.8),
            AppColors.secondary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_special_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.projectName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Metrados registrados para este proyecto. '
                'Seleccione para ver detalles o use el modo selección.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          BlocBuilder<MetradosBloc, MetradosState>(
            builder: (context, state) {
              if (state is MetradoSuccess) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${state.metrados.length} metrados',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_selectionMode)
                      Text(
                        'Seleccionados: ${_selectedMetrados.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                );
              }
              return const Text(
                'Cargando metrados...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar metrados...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando metrados...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron metrados'
                  : 'No hay metrados registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Los metrados se agregarán desde otro flujo de la aplicación.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar metrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadMetrados,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetradosList(List<Metrado> metrados) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: metrados.length,
      itemBuilder: (context, index) {
        final metrado = metrados[index];
        return _buildMetradoCard(metrado, index);
      },
    );
  }

  Widget _buildMetradoCard(Metrado metrado, int index) {
    final isSelected = _selectedMetrados.contains(metrado.id);

    return AnimatedBuilder(
      animation: _selectionModeAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            border: _selectionMode && isSelected
                ? Border.all(color: AppColors.secondary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _handleMetradoTap(metrado),
              onLongPress: () => _handleMetradoLongPress(metrado),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icono o checkbox de selección
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _selectionMode
                          ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Icon(
                            Icons.check_circle,
                            color: AppColors.secondary,
                            key: const ValueKey('selected'),
                          )
                              : Icon(
                            Icons.radio_button_unchecked,
                            color: AppColors.neutral300,
                            key: const ValueKey('unselected'),
                          ))
                          : Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assessment,
                          color: AppColors.secondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Información del metrado
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            metrado.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${metrado.id}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Indicador visual (flecha o estado de selección)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: !_selectionMode
                          ? Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.neutral400,
                        size: 16,
                        key: const ValueKey('arrow'),
                      )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // CAMBIO 3: Nuevo sistema de FABs dinámicos
  Widget _buildFloatingActionButtons() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: _selectionMode
              ? _buildSelectionModeFABs()
              : _buildNormalModeFAB(),
        );
      },
    );
  }

  Widget _buildNormalModeFAB() {
    return FloatingActionButton.extended(
      onPressed: _toggleSelectionMode,
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.check_box_outlined),
      label: const Text(
        'Seleccionar',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      elevation: 6,
      heroTag: "select_metrados",
    );
  }

  Widget _buildSelectionModeFABs() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end, // Alineación a la derecha
      children: [
        // FAB Combinar (movido arriba)
        FloatingActionButton.extended(
          onPressed: _selectedMetrados.length >= 2 ? _combineSelectedMetrados : null,
          backgroundColor: _selectedMetrados.length >= 2 ? AppColors.success : AppColors.neutral300,
          foregroundColor: Colors.white,
          heroTag: "combine_metrados",
          // Texto a la izquierda del ícono
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedMetrados.length < 2
                    ? 'Selecciona 2+'
                    : 'Combinar (${_selectedMetrados.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.merge_type, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // FAB Eliminar (movido al medio)
        FloatingActionButton.extended(
          onPressed: _selectedMetrados.isNotEmpty
              ? () => _showDeleteConfirmation(_selectedMetrados.toList())
              : null,
          backgroundColor: _selectedMetrados.isNotEmpty ? Colors.red : AppColors.neutral300,
          foregroundColor: Colors.white,
          heroTag: "delete_metrados",
          // Texto a la izquierda del ícono
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedMetrados.isEmpty
                    ? 'Selecciona elementos'
                    : 'Eliminar (${_selectedMetrados.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.delete_outline, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // FAB Cancelar (queda abajo)
        FloatingActionButton.extended(
          onPressed: _exitSelectionMode,
          backgroundColor: AppColors.neutral600,
          foregroundColor: Colors.white,
          heroTag: "cancel_selection",
          // Texto a la izquierda del ícono
          label: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cancelar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(width: 8),
              Icon(Icons.close, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}