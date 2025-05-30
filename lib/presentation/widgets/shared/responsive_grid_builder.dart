// lib/presentation/widgets/shared/responsive_grid_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/theme.dart';
import '../config/generic_module_config.dart';

/// Constructor de grids responsivos unificado para toda la aplicación
///
/// Proporciona una interfaz consistente para crear grids adaptativos
/// con manejo de estados asíncronos, animaciones y configuración centralizada.
class ResponsiveGridBuilder<T> extends StatelessWidget {
  /// Datos asíncronos a mostrar
  final AsyncValue<List<T>> asyncValue;

  /// Constructor de cada item del grid
  final Widget Function(T item, int index) itemBuilder;

  /// Configuración del módulo
  final ModuleConfig? moduleConfig;

  /// Configuración manual del grid (sobrescribe moduleConfig)
  final GridType? gridType;
  final SpacingSize? spacingSize;
  final PaddingSize? paddingSize;

  /// Textos personalizados
  final String? loadingText;
  final String? emptyText;
  final String? errorText;

  /// Callbacks
  final VoidCallback? onRetry;
  final bool Function(List<T>)? isEmpty;

  /// Configuración de animaciones
  final Duration? animationDuration;
  final int? maxAnimatedItems;
  final bool enableAnimations;

  /// Widget de header opcional
  final Widget? header;

  /// ScrollController opcional
  final ScrollController? scrollController;

  /// Physics del scroll
  final ScrollPhysics? physics;

  const ResponsiveGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.moduleConfig,
    this.gridType,
    this.spacingSize,
    this.paddingSize,
    this.loadingText,
    this.emptyText,
    this.errorText,
    this.onRetry,
    this.isEmpty,
    this.animationDuration,
    this.maxAnimatedItems,
    this.enableAnimations = true,
    this.header,
    this.scrollController,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: _getAnimationDuration(),
      child: asyncValue.when(
        data: (items) => _buildDataContent(context, items),
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) => _buildErrorState(context, error),
      ),
    );
  }

  Widget _buildDataContent(BuildContext context, List<T> items) {
    // Verificar si está vacío
    final isItemListEmpty = isEmpty?.call(items) ?? items.isEmpty;

    if (isItemListEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: _buildResponsiveGrid(context, items),
        ),
      ],
    );
  }

  Widget _buildResponsiveGrid(BuildContext context, List<T> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    final config = _getEffectiveConfig();

    // Calcular configuraciones responsivas
    final crossAxisCount = GenericModuleConfig.getCrossAxisCount(
      screenWidth,
      gridType: gridType ?? config.gridType,
    );

    final childAspectRatio = GenericModuleConfig.getChildAspectRatio(
      screenWidth,
      gridType: gridType ?? config.gridType,
    );

    final spacing = GenericModuleConfig.getGridSpacing(
      screenWidth,
      size: spacingSize ?? config.spacingSize,
    );

    final padding = GenericModuleConfig.getResponsivePadding(
      screenWidth,
      size: paddingSize ?? config.paddingSize,
    );

    return Padding(
      padding: EdgeInsets.all(padding),
      child: GridView.builder(
        controller: scrollController,
        physics: physics ?? const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];

          if (!enableAnimations) {
            return itemBuilder(item, index);
          }

          return _buildAnimatedItem(item, index);
        },
      ),
    );
  }

  Widget _buildAnimatedItem(T item, int index) {
    final maxItems = maxAnimatedItems ?? _getEffectiveConfig().maxAnimatedItems;

    // Solo animar los primeros elementos para mejor rendimiento
    if (index >= maxItems) {
      return itemBuilder(item, index);
    }

    return TweenAnimationBuilder<double>(
      duration: Duration(
        milliseconds: _getAnimationDuration().inMilliseconds + (index * 100),
      ),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.5 + (value * 0.5),
          child: Opacity(
            opacity: value,
            child: itemBuilder(item, index),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          if (loadingText != null) ...[
            const SizedBox(height: 16),
            Text(
              loadingText!,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          GenericModuleConfig.getResponsivePadding(
            MediaQuery.of(context).size.width,
          ),
        ),
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
              errorText ?? 'Error al cargar datos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ha ocurrido un problema. Inténtalo de nuevo.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          GenericModuleConfig.getResponsivePadding(
            MediaQuery.of(context).size.width,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppColors.neutral400,
            ),
            const SizedBox(height: 16),
            Text(
              emptyText ?? 'No hay datos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Los datos aparecerán aquí cuando estén disponibles.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  ModuleConfig _getEffectiveConfig() {
    return moduleConfig ?? ModuleConfig(
      gridType: gridType ?? GridType.standard,
      spacingSize: spacingSize ?? SpacingSize.medium,
      paddingSize: paddingSize ?? PaddingSize.medium,
      animationDuration: animationDuration ?? GenericModuleConfig.mediumAnimation,
      maxAnimatedItems: maxAnimatedItems ?? 10,
    );
  }

  Duration _getAnimationDuration() {
    return animationDuration ??
        moduleConfig?.animationDuration ??
        GenericModuleConfig.mediumAnimation;
  }
}

/// Widget específico para módulo de muros
class WallMaterialGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T material, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const WallMaterialGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.onRetry,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: GenericModuleConfig.wallModuleConfig,
      loadingText: 'Cargando materiales...',
      emptyText: 'No hay materiales disponibles',
      errorText: 'Error al cargar materiales',
      onRetry: onRetry,
      header: header,
    );
  }
}

/// Widget específico para módulo de losas
class SlabGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T slab, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const SlabGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.onRetry,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: GenericModuleConfig.slabModuleConfig,
      loadingText: 'Cargando losas...',
      emptyText: 'No hay losas disponibles',
      errorText: 'Error al cargar losas',
      onRetry: onRetry,
      header: header,
    );
  }
}

/// Widget específico para módulo de pisos
class FloorGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T floor, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const FloorGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.onRetry,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: GenericModuleConfig.floorModuleConfig,
      loadingText: 'Cargando pisos...',
      emptyText: 'No hay pisos disponibles',
      errorText: 'Error al cargar pisos',
      onRetry: onRetry,
      header: header,
    );
  }
}

/// Widget específico para módulo de revestimientos
class CoatingGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T coating, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const CoatingGridBuilder({
    super.key,
    required this.asyncValue,
    required this.itemBuilder,
    this.onRetry,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: GenericModuleConfig.coatingModuleConfig,
      loadingText: 'Cargando revestimientos...',
      emptyText: 'No hay revestimientos disponibles',
      errorText: 'Error al cargar revestimientos',
      onRetry: onRetry,
      header: header,
    );
  }
}

/// Helper class para crear headers responsivos
class ResponsiveHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final HeaderSize headerSize;
  final Color? titleColor;
  final Color? subtitleColor;
  final EdgeInsets? padding;

  const ResponsiveHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.headerSize = HeaderSize.h2,
    this.titleColor,
    this.subtitleColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final effectivePadding = padding ?? EdgeInsets.all(
      GenericModuleConfig.getResponsivePadding(screenWidth),
    );

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: GenericModuleConfig.getHeaderFontSize(
                screenWidth,
                size: headerSize,
              ),
              fontWeight: FontWeight.w900,
              color: titleColor ?? AppColors.textPrimary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: GenericModuleConfig.getSubtitleFontSize(screenWidth),
                color: subtitleColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Extension para simplificar el uso de grids responsivos
extension ResponsiveGridExtension on Widget {
  /// Envuelve el widget en un grid responsivo
  Widget wrapInResponsiveGrid<T>({
    required AsyncValue<List<T>> asyncValue,
    required Widget Function(T item, int index) itemBuilder,
    ModuleConfig? moduleConfig,
    String? loadingText,
    String? emptyText,
    VoidCallback? onRetry,
  }) {
    return ResponsiveGridBuilder<T>(
      asyncValue: asyncValue,
      itemBuilder: itemBuilder,
      moduleConfig: moduleConfig,
      loadingText: loadingText,
      emptyText: emptyText,
      onRetry: onRetry,
      header: this,
    );
  }
}