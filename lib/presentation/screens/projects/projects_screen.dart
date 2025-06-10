import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/projects/project.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:meter_app/presentation/blocs/projects/projects_bloc.dart';

import '../../../config/theme/theme.dart';
import 'new_project/new_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  // Nuevos controladores para la búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProjects();

    // Initialize animation controller for list items
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Agregar listener para la búsqueda
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Método para manejar cambios en la búsqueda
  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  void _loadProjects() {
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  Future<void> _handleRefresh() async {
    _loadProjects();
    // Wait for the bloc to process the event
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        // Usa el color primario de tu tema automáticamente
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primaryMetraShop,
          title: const Text(
            'Mis Proyectos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: AppColors.white),
              tooltip: 'Ayuda',
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Message Area
              BlocBuilder<ProjectsBloc, ProjectsState>(
                builder: (context, state) {
                  if (state is ProjectSuccess && state.projects.isEmpty) {
                    return const _EmptyStateHeader();
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Buscador de proyectos (nuevo)
              _buildSearchBar(),

              // Project List
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: BlocConsumer<ProjectsBloc, ProjectsState>(
                    listener: (context, state) {
                      if (state is ProjectNameAlreadyExists) {
                        _showErrorSnackBar(context, state.message);
                      } else if (state is ProjectFailure) {
                        _showErrorSnackBar(context, state.message);
                      } else if (state is ProjectAdded) {
                        _showSuccessSnackBar(context, 'Proyecto guardado exitosamente');
                      }
                    },
                    builder: (context, state) {
                      if (state is ProjectLoading) {
                        return _buildLoadingContent();
                      } else if (state is ProjectSuccess) {
                        return _buildProjectsList(context, state);
                      } else if (state is ProjectFailure) {
                        return _buildErrorContent(context, state.message);
                      } else {
                        return const Center(child: Text('Cargando proyectos...'));
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedElevation: 6.0,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(56.0)),
          ),
          transitionDuration: const Duration(milliseconds: 500),
          openBuilder: (context, _) => const NewProjectScreen(),
          closedBuilder: (context, openContainer) => FloatingActionButton(
            backgroundColor: AppColors.blueMetraShop,
            onPressed: openContainer,
            tooltip: 'Crear nuevo proyecto',
            child: const Icon(Icons.add, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  // Nuevo widget para el buscador
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar proyectos...',
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

  Widget _buildLoadingContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando proyectos...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList(BuildContext context, ProjectSuccess state) {
    if (state.projects.isEmpty) {
      return _buildEmptyState();
    }

    // Filtrar proyectos por búsqueda
    final filteredProjects = _searchQuery.isEmpty
        ? state.projects
        : state.projects.where((project) =>
        project.name.toLowerCase().contains(_searchQuery)).toList();

    // Mostrar mensaje si no hay resultados para la búsqueda
    if (filteredProjects.isEmpty) {
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
              'No se encontraron proyectos que coincidan con "$_searchQuery"',
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
      key: _refreshIndicatorKey,
      color: AppColors.blueMetraShop,
      onRefresh: _handleRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100), // Add padding for FAB
        itemCount: filteredProjects.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final project = filteredProjects[index];

          // Create staggered animation for list items
          final Animation<double> animation = CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              index / filteredProjects.length,
              (index + 1) / filteredProjects.length,
              curve: Curves.easeInOut,
            ),
          );

          // Start animation if it hasn't started yet
          if (!_animationController.isAnimating && !_animationController.isCompleted) {
            _animationController.forward();
          }

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.5, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: _buildProjectCard(context, project),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    return Dismissible(
      key: Key(project.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        context.read<ProjectsBloc>().add(DeleteProjectEvent(project: project));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: () {
            context.pushNamed(
              'metrados',
              pathParameters: {
                'projectId': project.id.toString(),
                'projectName': project.name,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.yellowMetraShop.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    AppIcons.archiveProjectIcon,
                    width: 24,
                    height: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryMetraShop,
                        ),
                      ),
                      Text(
                        'Toca para ver metrados',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.blueMetraShop),
                      tooltip: 'Editar proyecto',
                      onPressed: () => _showEditProjectBottomSheet(context, project),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.archiveProjectIcon,
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(
                Colors.grey[400]!,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay proyectos creados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Presiona el botón "+" para crear un nuevo proyecto',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.pushNamed('new-project');
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Proyecto'),
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

  Widget _buildErrorContent(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Ocurrió un error',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadProjects,
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
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[400], size: 40),
            const SizedBox(height: 16),
            const Text(
              'Eliminar Proyecto',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este proyecto?\n\nSe eliminarán también los metrados correspondientes.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }

  void _showEditProjectBottomSheet(BuildContext context, Project project) {
    final TextEditingController controller = TextEditingController(text: project.name);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Editar proyecto',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: 'Nombre del proyecto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.edit_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El nombre del proyecto es obligatorio';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() == true) {
                            final newName = controller.text.trim();
                            context.read<ProjectsBloc>().add(
                              EditProjectEvent(
                                project: project.copyWith(name: newName),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blueMetraShop,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<ProjectsBloc, ProjectsState>(
                  builder: (context, state) {
                    if (state is ProjectNameAlreadyExists) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Ayuda - Mis Proyectos'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHelpItem(
              icon: Icons.create_new_folder_outlined,
              title: 'Crear nuevo proyecto',
              description: 'Presiona el botón "+" para crear un nuevo proyecto.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.touch_app_outlined,
              title: 'Ver metrados',
              description: 'Toca un proyecto para ver sus metrados asociados.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.edit_outlined,
              title: 'Editar proyecto',
              description: 'Presiona el ícono de edición para cambiar el nombre.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.swipe_left_outlined,
              title: 'Eliminar proyecto',
              description: 'Desliza un proyecto hacia la izquierda para eliminarlo.',
            ),
            const SizedBox(height: 16),
            _buildHelpItem(
              icon: Icons.search,
              title: 'Buscar proyectos',
              description: 'Usa el campo de búsqueda para filtrar proyectos por nombre.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.blueMetraShop,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  void _showErrorSnackBar(BuildContext context, String message) {
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

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _EmptyStateHeader extends StatelessWidget {
  const _EmptyStateHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.yellowMetraShop.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellowMetraShop, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700]),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'No tienes proyectos creados. Crea tu primer proyecto con el botón "+".',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryMetraShop,
              ),
            ),
          ),
        ],
      ),
    );
  }
}