import 'package:flutter/material.dart';
import '../../../../config/theme/theme.dart';

class OptimizedSearchBar extends StatelessWidget {
  final VoidCallback onSearchTap;

  const OptimizedSearchBar({
    super.key,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSearchTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppColors.neutral400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Buscar dirección...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.neutral400,
                    ),
                  ),
                ),
                Icon(
                  Icons.tune,
                  color: AppColors.neutral400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

