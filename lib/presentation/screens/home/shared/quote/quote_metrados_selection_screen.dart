import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/entities.dart';
import '../../../../blocs/projects/metrados/metrados_bloc.dart';

class QuoteMetradosSelectionScreen extends StatefulWidget {
  final Project project;
  final String providerName;
  final String providerImageUrl;

  const QuoteMetradosSelectionScreen({
    super.key,
    required this.project,
    required this.providerName,
    required this.providerImageUrl,
  });

  @override
  State<QuoteMetradosSelectionScreen> createState() => _QuoteMetradosSelectionScreenState();
}

class _QuoteMetradosSelectionScreenState extends State<QuoteMetradosSelectionScreen> {
  final Set<int> _selectedMetradoIds = <int>{};
  List<Metrado> _metrados = [];

  @override
  void initState() {
    super.initState();
    _loadMetrados();
  }

  void _loadMetrados() {
    context.read<MetradosBloc>().add(
      LoadMetradosEvent(projectId: widget.project.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'MIS PROYECTOS - ${widget.project.name.toUpperCase()}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        // Header con información del proyecto
        _buildProjectHeader(),

        const SizedBox(height: 24),

        // Lista de metrados con checkboxes
        Expanded(
          child: _buildMetradosList(),
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.folder,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.project.name,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Proyecto seleccionado',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.neutral600,
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
                  Icons.checklist,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Selecciona las partidas a cotizar:',
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

  Widget _buildMetradosList() {
    return BlocBuilder<MetradosBloc, MetradosState>(
      builder: (context, state) {
        if (state is MetradoLoading) {
          return _buildLoadingState();
        } else if (state is MetradoSuccess) {
          _metrados = state.metrados;
          if (state.metrados.isEmpty) {
            return _buildEmptyState();
          }
          return _buildMetradosGrid(state.metrados);
        } else if (state is MetradoFailure) {
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
            'Cargando metrados...',
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
                Icons.construction_outlined,
                size: 40,
                color: AppColors.neutral400,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No hay metrados',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Este proyecto aún no tiene metrados para cotizar',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
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
              'Error al cargar metrados',
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
              onPressed: _loadMetrados,
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

  Widget _buildMetradosGrid(List<Metrado> metrados) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: metrados.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final metrado = metrados[index];
        final isSelected = _selectedMetradoIds.contains(metrado.id);
        return _buildMetradoCard(metrado, isSelected);
      },
    );
  }

  Widget _buildMetradoCard(Metrado metrado, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.neutral200,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _toggleMetradoSelection(metrado.id),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox personalizado
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.neutral400,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isSelected
                      ? const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.white,
                  )
                      : null,
                ),

                const SizedBox(width: 16),

                // Icono del metrado
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getMetradoIconColor(metrado.name).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMetradoIcon(metrado.name),
                    color: _getMetradoIconColor(metrado.name),
                    size: 20,
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
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.neutral900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _getMetradoCategory(metrado.name),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final hasSelectedMetrados = _selectedMetradoIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasSelectedMetrados) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_selectedMetradoIds.length} metrado${_selectedMetradoIds.length != 1 ? 's' : ''} seleccionado${_selectedMetradoIds.length != 1 ? 's' : ''}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelectedMetrados ? AppColors.primary : AppColors.neutral300,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: hasSelectedMetrados ? 2 : 0,
                ),
                child: Text(
                  'COTIZAR',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para iconos y categorías
  IconData _getMetradoIcon(String metradoName) {
    final name = metradoName.toLowerCase();
    if (name.contains('muro') || name.contains('ladrillo')) {
      return Icons.view_module;
    } else if (name.contains('columna')) {
      return Icons.view_column;
    } else if (name.contains('viga')) {
      return Icons.horizontal_rule;
    } else if (name.contains('losa')) {
      return Icons.crop_square;
    } else if (name.contains('tarrajeo')) {
      return Icons.format_paint;
    } else if (name.contains('piso')) {
      return Icons.square_foot;
    } else if (name.contains('contra')) {
      return Icons.layers;
    } else {
      return Icons.construction;
    }
  }

  Color _getMetradoIconColor(String metradoName) {
    final name = metradoName.toLowerCase();
    if (name.contains('muro') || name.contains('ladrillo')) {
      return const Color(0xFFE65100); // Naranja
    } else if (name.contains('columna')) {
      return const Color(0xFF1976D2); // Azul
    } else if (name.contains('viga')) {
      return const Color(0xFF388E3C); // Verde
    } else if (name.contains('losa')) {
      return const Color(0xFF7B1FA2); // Púrpura
    } else if (name.contains('tarrajeo')) {
      return const Color(0xFFFBC02D); // Amarillo
    } else if (name.contains('piso')) {
      return const Color(0xFF5D4037); // Marrón
    } else if (name.contains('contra')) {
      return const Color(0xFF455A64); // Azul gris
    } else {
      return AppColors.primary;
    }
  }

  String _getMetradoCategory(String metradoName) {
    final name = metradoName.toLowerCase();
    if (name.contains('muro') || name.contains('ladrillo')) {
      return 'Albañilería';
    } else if (name.contains('columna') || name.contains('viga')) {
      return 'Elementos Estructurales';
    } else if (name.contains('losa')) {
      return 'Losas';
    } else if (name.contains('tarrajeo')) {
      return 'Acabados';
    } else if (name.contains('piso')) {
      return 'Pisos';
    } else if (name.contains('contra')) {
      return 'Acabados';
    } else {
      return 'General';
    }
  }

  void _toggleMetradoSelection(int metradoId) {
    setState(() {
      if (_selectedMetradoIds.contains(metradoId)) {
        _selectedMetradoIds.remove(metradoId);
      } else {
        _selectedMetradoIds.add(metradoId);
      }
    });
  }
}