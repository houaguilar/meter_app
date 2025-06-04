import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme/theme.dart';
import '../../../blocs/map/place/place_analytics.dart';
import '../../../blocs/map/place/place_bloc.dart';

class OptimizedPlaceSearchScreen extends StatefulWidget {
  const OptimizedPlaceSearchScreen({super.key});

  @override
  State<OptimizedPlaceSearchScreen> createState() => _OptimizedPlaceSearchScreenState();
}

class _OptimizedPlaceSearchScreenState extends State<OptimizedPlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PlaceSearchAnalytics _analytics = PlaceSearchAnalytics();
  Timer? _debounceTimer;

  // Configuración de debounce para ahorrar llamadas API
  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const int _minSearchLength = 3;

  @override
  void initState() {
    super.initState();
    // Auto-focus en el campo de búsqueda
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Listener para el controller de texto
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {}); // Para actualizar el suffixIcon
  }

  void _onSearchChanged(String query) {
    // Cancelar timer anterior
    _debounceTimer?.cancel();

    if (query.length < _minSearchLength) {
      return;
    }

    // Registrar búsqueda en analytics
    _analytics.recordSearch(query);

    // Crear nuevo timer para debounce
    _debounceTimer = Timer(_debounceDuration, () {
      if (mounted && query.isNotEmpty) {
        context.read<PlaceBloc>().add(FetchOptimizedPlaceSuggestions(query));
      }
    });
  }

  void _selectPlace(String placeId, String description) {
    context.read<PlaceBloc>().add(SelectOptimizedPlace(placeId));
    context.pop();

    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ubicación seleccionada: $description'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _debounceTimer?.cancel();
    FocusScope.of(context).unfocus();
  }

  void _retryLastSearch() {
    final query = _searchController.text;
    if (query.length >= _minSearchLength) {
      context.read<PlaceBloc>().add(FetchOptimizedPlaceSuggestions(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Buscar dirección'),
        elevation: 0,
        actions: [
          // Botón de estadísticas en modo debug
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              onPressed: () => _showAnalytics(),
              icon: const Icon(Icons.analytics),
              tooltip: 'Ver estadísticas',
            ),
        ],
      ),
      body: Column(
        children: [
          // Campo de búsqueda
          _buildSearchField(),

          // Divisor
          Container(
            height: 1,
            color: AppColors.border,
          ),

          // Lista de resultados
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Ingresa dirección, distrito o referencia...',
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral400,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: AppColors.neutral400,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                onPressed: _clearSearch,
                icon: Icon(
                  Icons.clear,
                  color: AppColors.neutral400,
                ),
                tooltip: 'Limpiar búsqueda',
              )
                  : null,
              filled: true,
              fillColor: AppColors.neutral100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),

          // Mostrar información de ayuda si el texto es muy corto
          if (_searchController.text.isNotEmpty && _searchController.text.length < _minSearchLength)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 16),
              child: Text(
                'Escribe al menos $_minSearchLength caracteres para buscar',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocConsumer<PlaceBloc, PlaceState>(
      listener: (context, state) {
        // Registrar eventos en analytics
        if (state is OptimizedPlaceSuggestionsLoaded) {
          if (state.fromCache) {
            _analytics.recordCacheHit();
          } else {
            _analytics.recordApiCall();
          }
        } else if (state is OptimizedPlaceSelected) {
          if (state.fromCache) {
            _analytics.recordCacheHit();
          } else {
            _analytics.recordApiCall();
          }
        } else if (state is OptimizedPlaceError) {
          _analytics.recordError();
        }
      },
      builder: (context, state) {
        if (state is OptimizedPlaceLoading) {
          return _buildLoadingState();
        }

        if (state is OptimizedPlaceSuggestionsLoaded) {
          if (state.suggestions.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSuggestionsList(state);
        }

        if (state is OptimizedPlaceError) {
          return _buildErrorState(state.message, state.canRetry);
        }

        return _buildInitialState();
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Buscando direcciones...',
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsList(OptimizedPlaceSuggestionsLoaded state) {
    return Column(
      children: [
        // Mostrar indicador si viene del cache
        if (state.fromCache)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.success.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.memory,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text(
                  'Resultados desde cache (más rápido)',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.suggestions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: AppColors.border,
              indent: 16,
              endIndent: 16,
            ),
            itemBuilder: (context, index) {
              final suggestion = state.suggestions[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  suggestion.description,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.neutral400,
                  size: 16,
                ),
                onTap: () => _selectPlace(suggestion.placeId, suggestion.description),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: AppTypography.h6.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Intenta con otros términos de búsqueda o verifica la ortografía',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, bool canRetry) {
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
            'Error en la búsqueda',
            style: AppTypography.h6.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (canRetry) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retryLastSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'Busca una dirección',
            style: AppTypography.h6.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Escribe una dirección, distrito o punto de referencia para encontrar ubicaciones cercanas',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.neutral400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          _buildSearchTips(),
        ],
      ),
    );
  }

  Widget _buildSearchTips() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.infoBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Consejos de búsqueda',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...['• Usa nombres de calles y números', '• Incluye el distrito (ej: "Miraflores")', '• Prueba con referencias conocidas'].map(
                (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                tip,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textInfo,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAnalytics() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estadísticas de Búsqueda'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Búsquedas totales: ${_analytics.totalSearches}'),
              Text('Cache hits: ${_analytics.cacheHits}'),
              Text('Llamadas API: ${_analytics.apiCalls}'),
              Text('Errores: ${_analytics.errors}'),
              Text('Cache hit ratio: ${(_analytics.cacheHitRatio * 100).toStringAsFixed(1)}%'),
              Text('Error rate: ${(_analytics.errorRate * 100).toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              const Text('Rendimiento:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_analytics.cachePerformanceMessage),
              Text(_analytics.overallPerformanceMessage),
              if (_analytics.optimizationRecommendations.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Recomendaciones:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._analytics.optimizationRecommendations.map(
                      (rec) => Text('• $rec', style: const TextStyle(fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _analytics.reset();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Estadísticas reiniciadas')),
              );
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}