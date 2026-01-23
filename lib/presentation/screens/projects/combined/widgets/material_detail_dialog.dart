import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../../config/theme/theme.dart';
import '../../../../../domain/services/shared/UnifiedResultsCombiner.dart';
import 'material_helpers.dart';

/// Redondea un número hacia arriba con la cantidad de decimales especificada
/// Similar a la función ROUNDUP de Excel
double roundUp(double value, int decimals) {
  final multiplier = pow(10, decimals).toInt();
  return (value * multiplier).ceil() / multiplier;
}

/// Dialog que muestra los detalles de un material combinado,
/// incluyendo sus contribuciones de cada metrado
class MaterialDetailDialog extends StatelessWidget {
  final CombinedMaterial material;

  const MaterialDetailDialog({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 16),

            // Contribuciones por metrado
            Expanded(
              child: _buildContributionsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(
          MaterialHelpers.getMaterialIcon(material.name),
          color: MaterialHelpers.getMaterialColor(material.name),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Total: ${material.formattedQuantity}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildContributionsList() {
    return ListView.builder(
      itemCount: material.contributions.length,
      itemBuilder: (context, index) {
        final entry = material.contributions.entries.elementAt(index);
        final percentage = material.getContributionPercentage(entry.key);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${_formatQuantity(entry.value, material.unit)} ${material.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Formatea la cantidad según el tipo de material (similar a Excel)
  String _formatQuantity(double quantity, String unit) {
    final isConcreteMaterial = unit == 'm³' || unit == 'bls' || unit == 'bls.' || unit == 'L';

    if (isConcreteMaterial) {
      if (unit == 'bls' || unit == 'bls.') {
        // Cemento: redondear hacia arriba a entero
        return quantity.ceil().toString();
      } else {
        // Arena, Piedra, Agua, Aditivo: redondear hacia arriba con 1 decimal
        return roundUp(quantity, 1).toString();
      }
    } else {
      // Otros materiales: 2 decimales
      return quantity.toStringAsFixed(2);
    }
  }
}
