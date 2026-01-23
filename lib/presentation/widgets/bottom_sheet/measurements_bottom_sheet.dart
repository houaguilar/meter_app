import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../config/theme/theme.dart';
import '../../../domain/entities/entities.dart';
import '../cards/measurement_item_card.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Nuevo diálogo de mediciones con animación mejorada
class MeasurementItemsBottomSheet extends StatelessWidget {
  final List<Measurement> items;

  const MeasurementItemsBottomSheet({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.white,
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueMetraShop.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrastre mejorado
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.blueMetraShop.withOpacity(0.3),
                      AppColors.blueMetraShop.withOpacity(0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header mejorado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.blueMetraShop.withOpacity(0.05),
                      AppColors.blueMetraShop.withOpacity(0.02),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.blueMetraShop.withOpacity(0.15),
                            AppColors.blueMetraShop.withOpacity(0.25),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.architecture,
                        color: AppColors.blueMetraShop,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selecciona la partida',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Elige el tipo de medición',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neutral300.withOpacity(0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
              // Divider mejorado
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppColors.blueMetraShop.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Lista con fondo mejorado
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.backgroundLight.withOpacity(0.3),
                        AppColors.white,
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return MeasurementItemCard(
                        title: item.title,
                        imageAsset: item.imageAsset,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.pushNamed(item.location);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Función auxiliar para mostrar el bottom sheet con animación mejorada
void showMeasurementsSheet(BuildContext context, List<Measurement> items) {
  showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    expand: false,
    enableDrag: true,
    topRadius: const Radius.circular(16),
    duration: const Duration(milliseconds: 400),
    builder: (context) => MeasurementItemsBottomSheet(items: items),
  );
}
