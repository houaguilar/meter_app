import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meter_app/core/theme/theme.dart';
import 'package:meter_app/domain/entities/home/estructuras/structural_element.dart';
import 'package:meter_app/core/widgets/cards/generic_item_card.dart';
import 'package:meter_app/core/widgets/core/generic_module_config.dart';
import 'package:meter_app/core/widgets/shared/responsive_grid_builder.dart';

class StructuralElementCard extends StatelessWidget {
  final StructuralElement structuralElement;
  final VoidCallback onTap;
  final bool enabled;

  const StructuralElementCard({
    super.key,
    required this.structuralElement,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericItemCard<StructuralElement>(
      item: structuralElement,
      onTap: onTap,
      getId: (item) => item.id,
      getName: (item) => item.name,
      getImage: (item) => item.image,
      imageType: ImageType.svg,
      primaryColor: AppColors.primary,
    );
  }
}

class StructuralElementGridBuilder<T> extends StatelessWidget {
  final AsyncValue<List<T>> asyncValue;
  final Widget Function(T element, int index) itemBuilder;
  final VoidCallback? onRetry;
  final Widget? header;

  const StructuralElementGridBuilder({
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
      moduleConfig: GenericModuleConfig.structuralModuleConfig,
      loadingText: 'Cargando elementos estructurales...',
      emptyText: 'No hay elementos estructurales disponibles',
      errorText: 'Error al cargar elementos estructurales',
      onRetry: onRetry,
      header: header,
    );
  }
}
