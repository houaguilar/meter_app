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

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _selectionModeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
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
  // MANEJO DE SELECCIÓN MÚLTIPLE
  // ═══════════════════════════════════════════════════════════════════════════

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedMetrados.clear();
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
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

  void _combineSelectedMetrados() {
    if (_selectedMetrados.length < 2) {
      _showErrorSnackBar('Selecciona al menos 2 metrados para combinar');
      return;
    }

    // Navegación directa para evitar conflictos de GoRouter
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

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMetrados.clear();
      _animationController.reverse();
    });
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
      floatingActionButton: _buildFloatingActionButton(),
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
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _selectionMode
            ? IconButton(
          key: const ValueKey('close-selection'),
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
          tooltip: 'Salir de selección',
        )
            : IconButton(
          key: const ValueKey('info'),
          icon: const Icon(Icons.info_outline),
          onPressed: _showProjectInfo,
          tooltip: 'Información del proyecto',
        ),
      ),
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
            icon: const Icon(Icons.delete_outline),
            onPressed: _selectedMetrados.isNotEmpty
                ? () => _showDeleteConfirmation(_selectedMetrados.toList())
                : null,
            tooltip: 'Eliminar seleccionados',
          ),
        ] else ...[
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
                  // Recargar metrados después de eliminar
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
            'Selecciona uno o más metrados para ver o combinar resultados.',
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
                      AnimatedBuilder(
                        animation: _selectionModeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _selectionModeAnimation.value,
                            child: Transform.scale(
                              scale: _selectionModeAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Seleccionados: ${_selectedMetrados.length}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.secondary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: _selectionMode
                ? _buildCombineFAB()
                : _buildSelectFAB(),
          ),
        );
      },
    );
  }

  Widget _buildSelectFAB() {
    return FloatingActionButton.extended(
      key: const ValueKey('select-fab'),
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

  Widget _buildCombineFAB() {
    final canCombine = _selectedMetrados.length >= 2;

    return FloatingActionButton.extended(
      key: const ValueKey('combine-fab'),
      onPressed: canCombine ? _combineSelectedMetrados : null,
      backgroundColor: canCombine ? AppColors.success : AppColors.neutral300,
      foregroundColor: AppColors.white,
      icon: Icon(
        canCombine ? Icons.merge_type : Icons.merge_type_outlined,
      ),
      label: Text(
        _selectedMetrados.isEmpty
            ? 'Selecciona metrados'
            : _selectedMetrados.length == 1
            ? 'Selecciona otro más'
            : 'Combinar (${_selectedMetrados.length})',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      elevation: canCombine ? 6 : 2,
      heroTag: "combine_metrados",
    );
  }

  Widget _buildMetradosList(List<Metrado> metrados) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: metrados.length,
      itemBuilder: (context, index) {
        final metrado = metrados[index];
        return _buildMetradoItem(metrado, index);
      },
    );
  }

  Widget _buildMetradoItem(Metrado metrado, int index) {
    final isSelected = _selectedMetrados.contains(metrado.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.neutral200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
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
                // Checkbox en modo selección
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectionMode
                      ? Container(
                    key: const ValueKey('checkbox'),
                    margin: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleMetradoSelection(metrado.id),
                      activeColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                      : Container(
                    key: const ValueKey('icon'),
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.assessment_outlined,
                      color: AppColors.secondary,
                      size: 24,
                    ),
                  ),
                ),

                // Contenido del metrado
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metrado.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${metrado.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicador de selección o flecha
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectionMode
                      ? (isSelected
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
                      : Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.neutral400,
                    size: 16,
                    key: const ValueKey('arrow'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
  // MÉTODOS AUXILIARES
  // ═══════════════════════════════════════════════════════════════════════════

  List<Metrado> _filterMetrados(List<Metrado> metrados) {
    if (_searchQuery.isEmpty) return metrados;

    return metrados.where((metrado) {
      return metrado.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
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
              'Funcionalidades disponibles:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildInfoBullet('Ver resultados individuales'),
            _buildInfoBullet('Seleccionar múltiples metrados'),
            _buildInfoBullet('Combinar resultados'),
            _buildInfoBullet('Generar reportes PDF'),
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

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(List<int> metradoIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar ${metradoIds.length} ${metradoIds.length == 1 ? "metrado" : "metrados"}?\n\nEsta acción no se puede deshacer.',
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

  void _deleteSelectedMetrados(List<int> metradoIds) {
    // Obtener los metrados del estado actual
    final currentState = context.read<MetradosBloc>().state;
    if (currentState is MetradoSuccess) {
      final metrados = currentState.metrados;

      // Eliminar cada metrado seleccionado
      for (final metradoId in metradoIds) {
        final metrado = metrados.firstWhere((m) => m.id == metradoId);
        context.read<MetradosBloc>().add(DeleteMetradoEvent(metrado: metrado));
      }
    }
  }

  // Estados de UI
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty
                ? 'No se encontraron metrados'
                : 'No hay metrados registrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Intenta con otros términos de búsqueda'
                : 'Los metrados se crean desde los cálculos',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar metrados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMetrados,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Snackbars
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}