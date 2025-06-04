import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/projects/metrado/metrado.dart';
import '../../../blocs/projects/metrados/metrados_bloc.dart';
import '../result/result_test.dart';

class MetradosScreen extends StatefulWidget {
  final int projectId;
  final String projectName;

  const MetradosScreen({required this.projectId, required this.projectName, super.key});

  @override
  State<MetradosScreen> createState() => _MetradosScreenState();
}

class _MetradosScreenState extends State<MetradosScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Set para controlar los metrados seleccionados
  final Set<int> _selectedMetrados = {};
  bool _selectionMode = false;

  @override
  void initState() {
    super.initState();

    // Start loading metrados data
    _loadMetrados();

    // Setup animation controller for animated list items
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Add listener to search controller
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _loadMetrados() {
    context.read<MetradosBloc>().add(LoadMetradosEvent(projectId: widget.projectId));
  }

  Future<void> _handleRefresh() async {
    _loadMetrados();
    // Wait for the bloc to complete loading
    await Future.delayed(const Duration(seconds: 1));
    return Future.value();
  }

  // Método para activar/desactivar el modo de selección
  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedMetrados.clear();
      }
    });
  }

  // Método para seleccionar/deseleccionar un metrado
  void _toggleMetradoSelection(int metradoId) {
    setState(() {
      if (_selectedMetrados.contains(metradoId)) {
        _selectedMetrados.remove(metradoId);
        if (_selectedMetrados.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selectedMetrados.add(metradoId);
      }
    });
  }

  // Método para eliminar metrados seleccionados
  void _deleteSelectedMetrados() async {
    final confirmed = await _showDeleteSelectedConfirmationDialog();
    if (confirmed == true) {
      // Eliminar los metrados seleccionados
      for (var metradoId in _selectedMetrados.toList()) {
        final metradosList = (context.read<MetradosBloc>().state as MetradoSuccess).metrados;
        final metrado = metradosList.firstWhere((m) => m.id == metradoId);
        context.read<MetradosBloc>().add(DeleteMetradoEvent(metrado: metrado));
      }
      // Salir del modo selección
      setState(() {
        _selectionMode = false;
        _selectedMetrados.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Metrados',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Proyecto: ${widget.projectName}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryMetraShop,
        elevation: 0,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.white),
              tooltip: 'Eliminar seleccionados',
              onPressed: _selectedMetrados.isNotEmpty ? _deleteSelectedMetrados : null,
            )
          else
            IconButton(
              icon: const Icon(Icons.select_all, color: AppColors.white),
              tooltip: 'Seleccionar metrados',
              onPressed: () => _toggleSelectionMode(),
            ),
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.white),
            tooltip: 'Ayuda',
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Project info card
            _buildProjectInfoCard(),

            // Search bar
            _buildSearchBar(),

            // Metrados content
            Expanded(
              child: BlocConsumer<MetradosBloc, MetradosState>(
                listener: (context, state) {
                  if (state is MetradoAdded) {
                    _showSuccessSnackBar('Metrado agregado correctamente');
                  } else if (state is MetradoNameAlreadyExists) {
                    _showErrorSnackBar(state.message);
                  } else if (state is MetradoDeleted) {
                    _showSuccessSnackBar('Metrado eliminado correctamente');
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
                    if (state.metrados.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildMetradosList(state.metrados);
                  } else if (state is MetradoFailure) {
                    return _buildErrorState(state.message);
                  }
                  return _buildLoadingState();
                },
              ),
            ),
          ],
        ),
      ),
      // Ya no incluimos el FloatingActionButton para agregar metrados
    );
  }

  Widget _buildProjectInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.blueMetraShop.withAlpha((0.8 * 255).round()),
            AppColors.blueMetraShop.withAlpha((0.6 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).round()),
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
          // Texto modificado para reflejar que no se pueden agregar metrados aquí
          const Text(
            'Metrados registrados para este proyecto. Seleccione para ver detalles o use el modo selección.',
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
            borderSide: const BorderSide(color: AppColors.blueMetraShop),
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
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
              Icons.folder_open,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay metrados registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Los metrados se agregarán desde otro flujo de la aplicación.',
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
                backgroundColor: AppColors.blueMetraShop,
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
    // Filter metrados based on search query
    final filteredMetrados = _searchQuery.isEmpty
        ? metrados
        : metrados.where((metrado) =>
        metrado.name.toLowerCase().contains(_searchQuery)
    ).toList();

    // Reset and start animation controller
    _animationController.reset();
    _animationController.forward();

    if (filteredMetrados.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron metrados que coincidan con "$_searchQuery"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear),
              label: const Text('Limpiar búsqueda'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blueMetraShop,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      key: _refreshKey,
      color: AppColors.blueMetraShop,
      onRefresh: _handleRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredMetrados.length,
        itemBuilder: (context, index) {
          final metrado = filteredMetrados[index];

          // Create staggered animation for list items
          final Animation<double> animation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index / filteredMetrados.length * 0.75,
              (index + 1) / filteredMetrados.length,
              curve: Curves.easeInOut,
            ),
          );

          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.5, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildMetradoCard(metrado),
          );
        },
      ),
    );
  }

  Widget _buildMetradoCard(Metrado metrado) {
    // Indicar si el metrado está seleccionado
    final bool isSelected = _selectedMetrados.contains(metrado.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.blueMetraShop, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: _selectionMode
            ? () => _toggleMetradoSelection(metrado.id)
            : () => _navigateToResults(metrado),
        onLongPress: () {
          if (!_selectionMode) {
            _toggleSelectionMode();
            _toggleMetradoSelection(metrado.id);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Checkbox o indicador de selección
              if (_selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleMetradoSelection(metrado.id),
                  activeColor: AppColors.blueMetraShop,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

              // Icono del metrado
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.yellowMetraShop.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.yellowMetraShop,
                  size: 24,
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
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryMetraShop,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${metrado.id} • ${_selectionMode ? "Toca para seleccionar" : "Toca para ver resultados"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Icono de navegación
              if (!_selectionMode)
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToResults(Metrado metrado) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResultScreens(
          metradoId: metrado.id.toString(),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteSelectedConfirmationDialog() {
    final count = _selectedMetrados.length;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[400],
              size: 40,
            ),
            const SizedBox(height: 16),
            const Text(
              'Eliminar metrados',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar $count ${count == 1 ? "metrado seleccionado" : "metrados seleccionados"}?\n\nEsta acción no se puede deshacer y eliminará todos los resultados asociados.',
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.all(16),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Ayuda - Metrados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.touch_app_outlined,
              title: 'Ver resultados',
              description: 'Toca un metrado para ver sus resultados asociados.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.select_all,
              title: 'Modo selección',
              description: 'Pulsa el botón de selección o mantén presionado un metrado para activar el modo selección.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.delete_outline,
              title: 'Eliminar metrados',
              description: 'En modo selección, selecciona los metrados y pulsa el icono de eliminar para borrarlos.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.search,
              title: 'Buscar metrados',
              description: 'Usa el campo de búsqueda para filtrar los metrados por nombre.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blueMetraShop,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.blueMetraShop.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.blueMetraShop, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMetraShop,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
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
}