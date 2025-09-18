// lib/presentation/widgets/location/peru_location_picker.dart
import 'package:flutter/material.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../data/models/perfil/location/department.dart';
import '../../../../../data/models/perfil/location/district.dart';
import '../../../../../data/models/perfil/location/province.dart';
import '../../../../../data/repositories/perfil/location/peru_location_repository.dart';

/// Widget personalizado para seleccionar ubicaciones de Perú
/// Reemplaza a country_state_city_pro con una implementación nativa
class PeruLocationPicker extends StatefulWidget {
  /// Controller para el país (siempre será Perú)
  final TextEditingController countryController;

  /// Controller para el departamento
  final TextEditingController departmentController;

  /// Controller para la provincia
  final TextEditingController provinceController;

  /// Controller para el distrito
  final TextEditingController districtController;

  /// Decoración personalizada para los campos de texto
  final InputDecoration? textFieldDecoration;

  /// Color del diálogo
  final Color? dialogColor;

  /// Espaciado entre campos
  final double spacing;

  /// Si debe mostrar el campo de país (por defecto false, ya que siempre es Perú)
  final bool showCountryField;

  /// Callbacks para cuando cambian los valores
  final VoidCallback? onCountryChanged;
  final VoidCallback? onDepartmentChanged;
  final VoidCallback? onProvinceChanged;
  final VoidCallback? onDistrictChanged;

  const PeruLocationPicker({
    super.key,
    required this.countryController,
    required this.departmentController,
    required this.provinceController,
    required this.districtController,
    this.textFieldDecoration,
    this.dialogColor,
    this.spacing = 16.0,
    this.showCountryField = true,
    this.onCountryChanged,
    this.onDepartmentChanged,
    this.onProvinceChanged,
    this.onDistrictChanged,
  });

  @override
  State<PeruLocationPicker> createState() => _PeruLocationPickerState();
}

class _PeruLocationPickerState extends State<PeruLocationPicker> {
  final PeruLocationRepository _repository = PeruLocationRepository();

  Department? _selectedDepartment;
  Province? _selectedProvince;
  District? _selectedDistrict;

  @override
  void initState() {
    super.initState();
    _initializeCountry();
    _restoreSelectedValues();
  }

  /// Inicializa el país con Perú por defecto
  void _initializeCountry() {
    if (widget.countryController.text.isEmpty) {
      final country = _repository.getCountry();
      widget.countryController.text = country.name;
    }
  }

  /// Restaura los valores seleccionados desde los controllers
  void _restoreSelectedValues() {
    // Restaurar departamento
    if (widget.departmentController.text.isNotEmpty) {
      final departments = _repository.getDepartments();
      _selectedDepartment = departments.firstWhere(
            (dept) => dept.name == widget.departmentController.text,
        orElse: () => departments.first,
      );
    }

    // Restaurar provincia
    if (widget.provinceController.text.isNotEmpty && _selectedDepartment != null) {
      final provinces = _repository.getProvinces(_selectedDepartment!.code);
      try {
        _selectedProvince = provinces.firstWhere(
              (prov) => prov.name == widget.provinceController.text,
        );
      } catch (e) {
        _selectedProvince = null;
      }
    }

    // Restaurar distrito
    if (widget.districtController.text.isNotEmpty &&
        _selectedDepartment != null &&
        _selectedProvince != null) {
      final districts = _repository.getDistricts(
          _selectedDepartment!.code,
          _selectedProvince!.code
      );
      try {
        _selectedDistrict = districts.firstWhere(
              (dist) => dist.name == widget.districtController.text,
        );
      } catch (e) {
        _selectedDistrict = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de país (opcional)
        if (widget.showCountryField) ...[
          _buildCountryField(),
          SizedBox(height: widget.spacing),
        ],

        // Campo de departamento
        _buildLocationField<Department>(
          controller: widget.departmentController,
          labelText: 'Departamento',
          hintText: 'Selecciona tu departamento',
          icon: Icons.map_outlined,
          items: _repository.getDepartments(),
          selectedItem: _selectedDepartment,
          displayText: (dept) => dept.name,
          onChanged: _onDepartmentChanged,
          searchItems: (query) => _repository.searchDepartments(query),
        ),

        SizedBox(height: widget.spacing),

        // Campo de provincia
        _buildLocationField<Province>(
          controller: widget.provinceController,
          labelText: 'Provincia',
          hintText: 'Selecciona tu provincia',
          icon: Icons.location_city_outlined,
          items: _selectedDepartment != null
              ? _repository.getProvinces(_selectedDepartment!.code)
              : [],
          selectedItem: _selectedProvince,
          displayText: (prov) => prov.name,
          onChanged: _onProvinceChanged,
          enabled: _selectedDepartment != null,
          searchItems: _selectedDepartment != null
              ? (query) => _repository.searchProvinces(_selectedDepartment!.code, query)
              : null,
        ),

        SizedBox(height: widget.spacing),

        // Campo de distrito
        _buildLocationField<District>(
          controller: widget.districtController,
          labelText: 'Distrito',
          hintText: 'Selecciona tu distrito',
          icon: Icons.place_outlined,
          items: _selectedDepartment != null && _selectedProvince != null
              ? _repository.getDistricts(_selectedDepartment!.code, _selectedProvince!.code)
              : [],
          selectedItem: _selectedDistrict,
          displayText: (dist) => dist.name,
          onChanged: _onDistrictChanged,
          enabled: _selectedDepartment != null && _selectedProvince != null,
          searchItems: _selectedDepartment != null && _selectedProvince != null
              ? (query) => _repository.searchDistricts(
              _selectedDepartment!.code,
              _selectedProvince!.code,
              query
          )
              : null,
        ),
      ],
    );
  }

  /// Campo de país (solo lectura, siempre Perú)
  Widget _buildCountryField() {
    final country = _repository.getCountry();

    return TextFormField(
      controller: widget.countryController,
      readOnly: true,
      decoration: _getFieldDecoration(
        labelText: 'País',
        hintText: country.name,
        icon: Icons.public_outlined,
      ).copyWith(
        suffixIcon: Text(
          country.flag,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// Campo genérico para ubicaciones con búsqueda
  Widget _buildLocationField<T>({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
    required List<T> Function(String)? searchItems,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      decoration: _getFieldDecoration(
        labelText: labelText,
        hintText: enabled
            ? hintText
            : _getDisabledHint(labelText),
        icon: icon,
        enabled: enabled,
      ),
      onTap: enabled && items.isNotEmpty
          ? () => _showSelectionDialog<T>(
        context: context,
        title: 'Seleccionar $labelText',
        items: items,
        selectedItem: selectedItem,
        displayText: displayText,
        onChanged: onChanged,
        searchItems: searchItems,
      )
          : null,
    );
  }

  /// Obtiene la decoración de campo personalizada
  InputDecoration _getFieldDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    bool enabled = true,
  }) {
    final baseDecoration = widget.textFieldDecoration ?? InputDecoration(
      fillColor: AppColors.neutral50,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.border.withOpacity(0.3),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      labelStyle: TextStyle(
        color: enabled ? AppColors.textSecondary : AppColors.textSecondary.withOpacity(0.5),
        fontSize: 14,
      ),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 14,
      ),
    );

    return baseDecoration.copyWith(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: enabled ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
      ),
      suffixIcon: Icon(
        Icons.arrow_drop_down_rounded,
        color: enabled ? AppColors.primary : AppColors.textSecondary.withOpacity(0.5),
        size: 28,
      ),
    );
  }

  /// Obtiene el texto de hint cuando el campo está deshabilitado
  String _getDisabledHint(String labelText) {
    switch (labelText.toLowerCase()) {
      case 'provincia':
        return 'Primero selecciona un departamento';
      case 'distrito':
        return 'Primero selecciona una provincia';
      default:
        return 'Selección no disponible';
    }
  }

  /// Muestra el diálogo de selección con búsqueda
  Future<void> _showSelectionDialog<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required T? selectedItem,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
    required List<T> Function(String)? searchItems,
  }) async {
    await showDialog<T>(
      context: context,
      builder: (context) => _SelectionDialog<T>(
        title: title,
        items: items,
        selectedItem: selectedItem,
        displayText: displayText,
        onChanged: onChanged,
        searchItems: searchItems,
        dialogColor: widget.dialogColor,
      ),
    );
  }

  /// Maneja el cambio de departamento
  void _onDepartmentChanged(Department? department) {
    setState(() {
      _selectedDepartment = department;
      _selectedProvince = null;
      _selectedDistrict = null;

      widget.departmentController.text = department?.name ?? '';
      widget.provinceController.clear();
      widget.districtController.clear();
    });

    widget.onDepartmentChanged?.call();
  }

  /// Maneja el cambio de provincia
  void _onProvinceChanged(Province? province) {
    setState(() {
      _selectedProvince = province;
      _selectedDistrict = null;

      widget.provinceController.text = province?.name ?? '';
      widget.districtController.clear();
    });

    widget.onProvinceChanged?.call();
  }

  /// Maneja el cambio de distrito
  void _onDistrictChanged(District? district) {
    setState(() {
      _selectedDistrict = district;
      widget.districtController.text = district?.name ?? '';
    });

    widget.onDistrictChanged?.call();
  }
}

/// Diálogo personalizado para selección con búsqueda
class _SelectionDialog<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) displayText;
  final ValueChanged<T?> onChanged;
  final List<T> Function(String)? searchItems;
  final Color? dialogColor;

  const _SelectionDialog({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.displayText,
    required this.onChanged,
    this.searchItems,
    this.dialogColor,
  });

  @override
  State<_SelectionDialog<T>> createState() => _SelectionDialogState<T>();
}

class _SelectionDialogState<T> extends State<_SelectionDialog<T>> {
  late TextEditingController _searchController;
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      _filteredItems = widget.searchItems?.call(query) ??
          widget.items.where((item) =>
              widget.displayText(item).toLowerCase().contains(query.toLowerCase())
          ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: widget.dialogColor ?? AppColors.surface,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            // Campo de búsqueda
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de opciones
            Expanded(
              child: _filteredItems.isEmpty
                  ? const Center(
                child: Text(
                  'No se encontraron resultados',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = item == widget.selectedItem;

                  return ListTile(
                    title: Text(
                      widget.displayText(item),
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      widget.onChanged(item);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}