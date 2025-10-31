import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/product_categories.dart';
import '../../../../config/theme/theme.dart';
import '../../../../config/utils/show_snackbar.dart';
import '../../../../domain/entities/map/product.dart';
import '../../../blocs/map/products_bloc.dart';
import '../../../widgets/app_bar/app_bar_widget.dart';

/// Pantalla para configurar marcas y precios de una categoría específica
class BrandConfiguratorScreen extends StatefulWidget {
  final String locationId;
  final String categoryId;

  const BrandConfiguratorScreen({
    super.key,
    required this.locationId,
    required this.categoryId,
  });

  @override
  State<BrandConfiguratorScreen> createState() => _BrandConfiguratorScreenState();
}

class _BrandConfiguratorScreenState extends State<BrandConfiguratorScreen> {
  late Map<String, dynamic> _categoryData;
  String? _categoryName;
  String? _categoryIcon;

  List<String> _selectedBrands = [];
  Map<String, TextEditingController> _priceControllers = {};
  Map<String, ProductUnit> _unitSelections = {};

  // Control de marca personalizada
  bool _showCustomBrandInput = false;
  final TextEditingController _customBrandController = TextEditingController();
  final TextEditingController _customPriceController = TextEditingController();
  ProductUnit _customUnit = ProductUnit.unidad;

  // Productos existentes
  List<Product> _existingProducts = [];
  bool _isLoading = false;

  // Control de edición de productos configurados
  Map<String, bool> _editingProducts = {};
  Map<String, TextEditingController> _editPriceControllers = {};
  Map<String, ProductUnit> _editUnitSelections = {};

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
    _loadExistingProducts();
  }

  @override
  void dispose() {
    for (var controller in _priceControllers.values) {
      controller.dispose();
    }
    for (var controller in _editPriceControllers.values) {
      controller.dispose();
    }
    _customBrandController.dispose();
    _customPriceController.dispose();
    super.dispose();
  }

  void _loadCategoryData() {
    _categoryData = PRODUCT_CATEGORIES[widget.categoryId] ?? {};
    _categoryName = _categoryData['name'] as String?;
    _categoryIcon = _categoryData['icon'] as String?;
  }

  void _loadExistingProducts() {
    context.read<ProductsBloc>().add(LoadLocationProducts(widget.locationId));
  }

  List<String> _getAvailableBrands() {
    final brandsRaw = _categoryData['brands'];
    if (brandsRaw == null || brandsRaw is! Map) return [];

    final brandsData = Map<String, dynamic>.from(brandsRaw as Map);
    final configuredBrands = _getConfiguredBrands();
    final availableBrands = brandsData.keys
        .where((brand) => !configuredBrands.contains(brand))
        .toList();

    return availableBrands;
  }

  List<String> _getConfiguredBrands() {
    return _existingProducts
        .where((product) => product.categoryId == widget.categoryId)
        .map((product) => product.attributes?['brand'] as String?)
        .where((brand) => brand != null)
        .cast<String>()
        .toList();
  }

  /// Genera una clave única para identificar un producto basada en su marca
  String _getProductKey(Product product) {
    final brand = product.attributes?['brand'] as String? ?? 'unknown';
    return '${widget.categoryId}_$brand';
  }

  void _toggleBrand(String brand) {
    setState(() {
      if (_selectedBrands.contains(brand)) {
        _selectedBrands.remove(brand);
        _priceControllers[brand]?.dispose();
        _priceControllers.remove(brand);
        _unitSelections.remove(brand);
      } else {
        _selectedBrands.add(brand);
        _priceControllers[brand] = TextEditingController();
        _unitSelections[brand] = ProductUnit.bolsa;
      }
    });
  }

  void _startEditingProduct(Product product) {
    final productKey = _getProductKey(product);

    setState(() {
      _editingProducts[productKey] = true;
      _editPriceControllers[productKey] = TextEditingController(
        text: product.price.toString(),
      );
      _editUnitSelections[productKey] = ProductUnit.values.firstWhere(
        (unit) => unit.name == product.unitString,
        orElse: () => ProductUnit.unidad,
      );
    });
  }

  void _cancelEditingProduct(String productKey) {
    setState(() {
      _editingProducts[productKey] = false;
      _editPriceControllers[productKey]?.dispose();
      _editPriceControllers.remove(productKey);
      _editUnitSelections.remove(productKey);
    });
  }

  Future<void> _saveEditedProduct(Product product) async {
    final productKey = _getProductKey(product);

    final priceText = _editPriceControllers[productKey]?.text ?? '';
    if (priceText.isEmpty) {
      showSnackBar(context, 'Ingresa un precio válido');
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      showSnackBar(context, 'Precio inválido');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Crear producto actualizado preservando TODOS los campos existentes
      final updatedProduct = Product(
        id: product.id, // ID de Isar (local)
        supabaseId: product.supabaseId, // ⭐ IMPORTANTE: ID de Supabase
        locationId: product.locationId,
        categoryId: product.categoryId,
        name: product.name,
        description: product.description,
        price: price,
        currency: product.currency,
        unitString: _editUnitSelections[productKey]?.name,
        stockAvailable: product.stockAvailable,
        featured: product.featured,
        createdAt: product.createdAt,
        updatedAt: DateTime.now(),
      );

      // Copiar atributos (attributes)
      updatedProduct.attributesJson = product.attributesJson;

      // ⭐ Actualizar el estado local INMEDIATAMENTE para reflejar cambios en UI
      final productIndex = _existingProducts.indexWhere(
        (p) => p.supabaseId == product.supabaseId,
      );
      if (productIndex != -1) {
        _existingProducts[productIndex] = updatedProduct;
      }

      // Enviar actualización al BLoC
      context.read<ProductsBloc>().add(UpdateProduct(updatedProduct));

      showSnackBar(context, 'Producto actualizado correctamente');

      setState(() {
        _editingProducts[productKey] = false;
        _isLoading = false;
      });

      // Limpiar controladores de edición
      _editPriceControllers[productKey]?.dispose();
      _editPriceControllers.remove(productKey);
      _editUnitSelections.remove(productKey);
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, 'Error al actualizar producto: $e');
    }
  }

  Future<void> _deleteProduct(Product product) async {
    // Validar que el producto tenga un supabaseId válido
    if (product.supabaseId == null || product.supabaseId!.isEmpty) {
      showSnackBar(context, 'Error: Este producto no se ha guardado correctamente');
      return;
    }

    final brand = product.attributes?['brand'] as String? ?? 'este producto';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de eliminar $brand?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      try {
        // Usar supabaseId en lugar de id
        context.read<ProductsBloc>().add(DeleteProductEvent(product.supabaseId!));
        showSnackBar(context, 'Producto eliminado correctamente');

        // Limpiar el estado de edición si estaba activo
        final productKey = _getProductKey(product);
        if (_editingProducts[productKey] == true) {
          _cancelEditingProduct(productKey);
        }

        await Future.delayed(const Duration(milliseconds: 300));
        _loadExistingProducts();
      } catch (e) {
        showSnackBar(context, 'Error al eliminar: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _saveProducts() async {
    if (_selectedBrands.isEmpty && !_showCustomBrandInput) {
      showSnackBar(context, 'Selecciona al menos una marca');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Guardar marcas seleccionadas
      for (final brand in _selectedBrands) {
        final priceText = _priceControllers[brand]?.text ?? '';
        if (priceText.isEmpty) {
          showSnackBar(context, 'Ingresa el precio para $brand');
          setState(() => _isLoading = false);
          return;
        }

        final price = double.tryParse(priceText);
        if (price == null || price <= 0) {
          showSnackBar(context, 'Precio inválido para $brand');
          setState(() => _isLoading = false);
          return;
        }

        final product = Product(
          locationId: widget.locationId,
          categoryId: widget.categoryId,
          name: _categoryName ?? '',
          price: price,
          currency: Currency.PEN,
          unitString: _unitSelections[brand]?.name,
        );

        product.attributes = {'brand': brand};
        context.read<ProductsBloc>().add(AddProduct(product));
      }

      // Guardar marca personalizada
      if (_showCustomBrandInput && _customBrandController.text.isNotEmpty) {
        final customPrice = double.tryParse(_customPriceController.text);
        if (customPrice != null && customPrice > 0) {
          final product = Product(
            locationId: widget.locationId,
            categoryId: widget.categoryId,
            name: _categoryName ?? '',
            price: customPrice,
            currency: Currency.PEN,
            unitString: _customUnit.name,
          );

          product.attributes = {'brand': _customBrandController.text};
          context.read<ProductsBloc>().add(AddProduct(product));
        }
      }

      showSnackBar(context, 'Productos guardados correctamente');

      // Volver a la pantalla anterior
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      showSnackBar(context, 'Error al guardar productos');
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = _getAvailableBrands();
    final configuredBrands = _getConfiguredBrands();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(titleAppBar: _categoryName ?? 'Configurar'),
      body: BlocListener<ProductsBloc, ProductsState>(
        listener: (context, state) {
          if (state is ProductsError) {
            showSnackBar(context, state.message);
          } else if (state is ProductsLoaded) {
            setState(() {
              _existingProducts = state.products;
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryChip(),
                    const SizedBox(height: 24),
                    _buildHeader(brands),
                    const SizedBox(height: 24),

                    if (brands.isNotEmpty) ...[
                      _buildBrandsGrid(brands),
                      const SizedBox(height: 24),
                    ],

                    if (_selectedBrands.isNotEmpty) ...[
                      _buildPriceFormsSection(),
                      const SizedBox(height: 24),
                    ],

                    _buildCustomBrandSection(),

                    if (configuredBrands.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Divider(color: AppColors.neutral200, thickness: 2),
                      const SizedBox(height: 24),
                      _buildConfiguredBrandsSection(),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_categoryIcon ?? '', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                _categoryName ?? '',
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(List<String> brands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.label_important_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brands.isNotEmpty
                        ? 'Selecciona Marcas'
                        : 'Agregar Marca Personalizada',
                    style: AppTypography.h2.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    brands.isNotEmpty
                        ? 'Elige las marcas que vendes'
                        : 'No hay marcas predefinidas',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandsGrid(List<String> brands) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        final isSelected = _selectedBrands.contains(brand);
        return _buildBrandChip(brand, isSelected);
      },
    );
  }

  Widget _buildBrandChip(String brand, bool isSelected) {
    return InkWell(
      onTap: () => _toggleBrand(brand),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                brand,
                style: AppTypography.bodyMedium.copyWith(
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceFormsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configura Precios',
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ..._selectedBrands.map((brand) => _buildPriceForm(brand)),
      ],
    );
  }

  Widget _buildPriceForm(String brand) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            brand,
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                flex: 2,
                child: TextField(
                  controller: _priceControllers[brand],
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Precio',
                    prefixText: 'S/. ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                flex: 2,
                child: DropdownButtonFormField<ProductUnit>(
                  value: _unitSelections[brand],
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Unidad',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  items: ProductUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(
                        unit.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _unitSelections[brand] = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_showCustomBrandInput)
          OutlinedButton.icon(
            onPressed: () => setState(() => _showCustomBrandInput = true),
            icon: const Icon(Icons.add),
            label: const Text('Agregar Marca Personalizada'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Marca Personalizada',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showCustomBrandInput = false;
                          _customBrandController.clear();
                          _customPriceController.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _customBrandController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la marca',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      flex: 2,
                      child: TextField(
                        controller: _customPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Precio',
                          prefixText: 'S/. ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      flex: 2,
                      child: DropdownButtonFormField<ProductUnit>(
                        value: _customUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Unidad',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                        items: ProductUnit.values.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(
                              unit.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _customUnit = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConfiguredBrandsSection() {
    final categoryProducts = _existingProducts
        .where((product) => product.categoryId == widget.categoryId)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.success.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Marcas Ya Configuradas',
                      style: AppTypography.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Puedes editar el precio o eliminar',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...categoryProducts.map((product) => _buildConfiguredProductCard(product)),
      ],
    );
  }

  Widget _buildConfiguredProductCard(Product product) {
    final productKey = _getProductKey(product);
    final brand = product.attributes?['brand'] as String? ?? 'Sin marca';
    final isEditing = _editingProducts[productKey] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditing ? AppColors.primary : AppColors.success.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isEditing ? AppColors.primary : AppColors.success).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (isEditing ? AppColors.primary : AppColors.success).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.inventory_2_rounded,
                    color: isEditing ? AppColors.primary : AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              brand,
                              style: AppTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (!isEditing)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: AppColors.success,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Activo',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!isEditing)
                        Text(
                          product.priceWithUnit,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else
                        _buildEditPriceForm(product),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isEditing)
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _startEditingProduct(product),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(14),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: AppColors.primary, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Editar',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.neutral200,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _deleteProduct(product),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(14),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete, color: AppColors.error, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Eliminar',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelEditingProduct(productKey),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text(
                        'Cancelar',
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.neutral200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _saveEditedProduct(product),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text(
                        'Guardar',
                        style: TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
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

  Widget _buildEditPriceForm(Product product) {
    final productKey = _getProductKey(product);

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: TextField(
            controller: _editPriceControllers[productKey],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: 'Precio',
              prefixText: 'S/. ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<ProductUnit>(
            value: _editUnitSelections[productKey],
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'Unidad',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 8,
              ),
              isDense: true,
            ),
            items: ProductUnit.values.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(
                  unit.displayName,
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _editUnitSelections[productKey] = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final hasSelection = _selectedBrands.isNotEmpty ||
        (_showCustomBrandInput && _customBrandController.text.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: hasSelection && !_isLoading ? _saveProducts : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    'Guardar Productos',
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
