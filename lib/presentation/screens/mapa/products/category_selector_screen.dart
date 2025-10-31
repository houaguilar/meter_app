import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/product_categories.dart';
import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/map/product.dart';
import '../../../blocs/map/products_bloc.dart';
import '../../../widgets/app_bar/app_bar_widget.dart';

/// Pantalla para seleccionar la categoría de productos
class CategorySelectorScreen extends StatefulWidget {
  final String locationId;

  const CategorySelectorScreen({
    super.key,
    required this.locationId,
  });

  @override
  State<CategorySelectorScreen> createState() => _CategorySelectorScreenState();
}

class _CategorySelectorScreenState extends State<CategorySelectorScreen> {
  List<Product> _existingProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingProducts();
  }

  void _loadExistingProducts() {
    context.read<ProductsBloc>().add(LoadLocationProducts(widget.locationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(titleAppBar: 'Configurar Productos'),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              _existingProducts = state.products;
              _isLoading = false;
            });
          } else if (state is ProductsError) {
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando categorías...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildCategoriesGrid(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selecciona una Categoría',
                      style: AppTypography.h2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Elige el tipo de producto que vendes',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_existingProducts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text: '${_existingProducts.length} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          TextSpan(
                            text:
                                'producto${_existingProducts.length == 1 ? '' : 's'} configurado${_existingProducts.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Categorías Disponibles',
              style: AppTypography.h3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemCount: PRODUCT_CATEGORIES.length,
          itemBuilder: (context, index) {
            final entry = PRODUCT_CATEGORIES.entries.elementAt(index);
            final categoryId = entry.key;
            final categoryData = entry.value;
            final name = categoryData['name'] as String;
            final icon = categoryData['icon'] as String;

            // Contar productos configurados en esta categoría
            final productsInCategory = _existingProducts
                .where((product) => product.categoryId == categoryId)
                .length;

            return _buildCategoryCard(
              categoryId: categoryId,
              name: name,
              icon: icon,
              configuredCount: productsInCategory,
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String categoryId,
    required String name,
    required String icon,
    required int configuredCount,
  }) {
    final isConfigured = configuredCount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToBrandConfigurator(categoryId),
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isConfigured
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withOpacity(0.05),
                      AppColors.white,
                    ],
                  )
                : null,
            color: isConfigured ? null : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isConfigured
                  ? AppColors.success.withOpacity(0.4)
                  : AppColors.primary.withOpacity(0.15),
              width: isConfigured ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isConfigured
                    ? AppColors.success.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Contenido principal
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isConfigured
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: Text(
                          name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isConfigured) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'Configurado',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              // Badge de productos configurados
              if (configuredCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success,
                          AppColors.success.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.success.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$configuredCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToBrandConfigurator(String categoryId) {
    context.pushNamed(
      'brand-configurator',
      pathParameters: {
        'locationId': widget.locationId,
        'categoryId': categoryId,
      },
    );
  }
}
