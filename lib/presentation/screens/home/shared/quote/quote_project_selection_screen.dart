import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/screens/home/shared/quote/quote_metrados_selection_screen.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/entities.dart';
import '../../../../blocs/projects/projects_bloc.dart';

class QuoteProjectSelectionScreen extends StatefulWidget {
  final String providerName;
  final String providerImageUrl;

  const QuoteProjectSelectionScreen({
    super.key,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<QuoteProjectSelectionScreen> createState() => _QuoteProjectSelectionScreenState();
}

class _QuoteProjectSelectionScreenState extends State<QuoteProjectSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar proyectos al iniciar
    context.read<ProjectsBloc>().add(LoadProjectsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'MIS PROYECTOS',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.neutral900,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // Header con información del proveedor
        _buildProviderHeader(),

        const SizedBox(height: 24),

        // Lista de proyectos
        Expanded(
          child: _buildProjectsList(),
        ),
      ],
    );
  }

  Widget _buildProviderHeader() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.neutral100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProviderImage(),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cotizar con',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.providerName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selecciona el proyecto que deseas cotizar:',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderImage() {
    if (widget.providerImageUrl.startsWith('http') || widget.providerImageUrl.startsWith('https')) {
      return Image.network(
        widget.providerImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.neutral100,
            child: Icon(
              Icons.store,
              size: 24,
              color: AppColors.neutral400,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        widget.providerImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.neutral100,
            child: Icon(
              Icons.store,
              size: 24,
              color: AppColors.neutral400,
            ),
          );
        },
      );
    }
  }

  Widget _buildProjectsList() {
    return BlocBuilder<ProjectsBloc, ProjectsState>(
      builder: (context, state) {
        if (state is ProjectLoading) {
          return _buildLoadingState();
        } else if (state is ProjectSuccess) {
          if (state.projects.isEmpty) {
            return _buildEmptyState();
          }
          return _buildProjectsGrid(state.projects);
        } else if (state is ProjectFailure) {
          return _buildErrorState(state.message);
        } else {
          return _buildEmptyState();
        }
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Cargando proyectos...',
            style: TextStyle(
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.folder_outlined,
                size: 40,
                color: AppColors.neutral400,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No tienes proyectos',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Crea tu primer proyecto para comenzar a cotizar materiales',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                // Navegar a crear proyecto (implementa según tu navegación)
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Proyecto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),

            const SizedBox(height: 24),

            Text(
              'Error al cargar proyectos',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                context.read<ProjectsBloc>().add(LoadProjectsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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

  Widget _buildProjectsGrid(List<Project> projects) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: projects.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(project);
      },
    );
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToMetradosSelection(project),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icono del proyecto
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.folder,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 16),

                // Información del proyecto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Toca para seleccionar metrados',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icono de navegación
                Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMetradosSelection(Project project) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuoteMetradosSelectionScreen(
          project: project,
          providerName: widget.providerName,
          providerImageUrl: widget.providerImageUrl,
        ),
      ),
    );
  }
}