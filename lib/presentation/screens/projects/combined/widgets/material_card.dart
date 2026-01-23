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

/// Card que muestra un material combinado con sus contribuciones
class MaterialCard extends StatelessWidget {
  final CombinedMaterial material;
  final int index;
  final VoidCallback onTap;

  const MaterialCard({
    super.key,
    required this.material,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral200.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                if (material.contributions.length > 1) _buildContributions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: MaterialHelpers.getMaterialColor(material.name).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            MaterialHelpers.getMaterialIcon(material.name),
            color: MaterialHelpers.getMaterialColor(material.name),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Suma de ${material.contributions.length} metrado${material.contributions.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatQuantity(material.totalQuantity, material.unit),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              material.unit,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContributions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.merge_type,
              size: 14,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              'Combinado desde:',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: material.contributions.entries.map((entry) {
            final percentage = material.getContributionPercentage(entry.key);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.secondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
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
