import 'package:flutter/material.dart';

import '../../../config/theme/theme.dart';
import '../../../data/models/perfil/location/administrative_level_2.dart';
import '../../../data/models/perfil/location/administrative_level_3.dart';
import '../../../data/models/perfil/location/administrative_level_4.dart';
import '../../../data/models/perfil/location/country.dart';
import '../../../data/repositories/perfil/location/location_repository.dart';
import '../../../data/repositories/perfil/location/location_repository_factory.dart';

/// Widget genérico para seleccionar ubicaciones de múltiples países
/// Soporta Perú 🇵🇪, Colombia 🇨🇴 y Brasil 🇧🇷
///
/// Uso:
/// ```dart
/// MultiCountryLocationPicker(
///   countryController: _countryController,
///   level2Controller: _departmentController,
///   level3Controller: _provinceController,
///   level4Controller: _districtController,
/// )
/// ```
class MultiCountryLocationPicker extends StatefulWidget {
  /// Controller para el país
  final TextEditingController countryController;

  /// Controller para el nivel 2 (Departamento/Estado)
  final TextEditingController level2Controller;

  /// Controller para el nivel 3 (Provincia/Municipio/Município)
  final TextEditingController level3Controller;

  /// Controller para el nivel 4 (Distrito/Corregimiento)
  final TextEditingController level4Controller;

  /// Decoración personalizada para los campos de texto
  final InputDecoration? textFieldDecoration;

  /// Color del diálogo
  final Color? dialogColor;

  /// Espaciado entre campos
  final double spacing;

  /// Callbacks para cuando cambian los valores
  final VoidCallback? onCountryChanged;
  final VoidCallback? onLevel2Changed;
  final VoidCallback? onLevel3Changed;
  final VoidCallback? onLevel4Changed;

  /// País inicial (PE por defecto)
  final String initialCountryCode;

  const MultiCountryLocationPicker({
    super.key,
    required this.countryController,
    required this.level2Controller,
    required this.level3Controller,
    required this.level4Controller,
    this.textFieldDecoration,
    this.dialogColor,
    this.spacing = 16.0,
    this.onCountryChanged,
    this.onLevel2Changed,
    this.onLevel3Changed,
    this.onLevel4Changed,
    this.initialCountryCode = 'PE',
  });

  @override
  State<MultiCountryLocationPicker> createState() =>
      _MultiCountryLocationPickerState();
}

class _MultiCountryLocationPickerState
    extends State<MultiCountryLocationPicker> {
  LocationRepository? _repository;

  AdministrativeLevel2? _selectedLevel2;
  AdministrativeLevel3? _selectedLevel3;
  AdministrativeLevel4? _selectedLevel4;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _restoreSelectedValues();
  }

  /// Inicializa el repositorio basado en el país inicial
  void _initializeRepository() {
    if (widget.countryController.text.isEmpty) {
      _repository = LocationRepositoryFactory.create(widget.initialCountryCode);
      widget.countryController.text = _repository!.getCountry().name;
    } else {
      // Intentar detectar el país desde el texto
      final country = _detectCountryFromName(widget.countryController.text);
      if (country != null) {
        _repository = LocationRepositoryFactory.create(country.code);
      } else {
        _repository =
            LocationRepositoryFactory.create(widget.initialCountryCode);
        widget.countryController.text = _repository!.getCountry().name;
      }
    }
  }

  /// Detecta el país desde el nombre
  Country? _detectCountryFromName(String countryName) {
    final repositories = LocationRepositoryFactory.getAllRepositories();
    for (var repo in repositories) {
      if (repo.getCountry().name == countryName) {
        return repo.getCountry();
      }
    }
    return null;
  }

  /// Restaura los valores seleccionados desde los controllers
  void _restoreSelectedValues() {
    if (_repository == null) return;

    // Restaurar nivel 2
    if (widget.level2Controller.text.isNotEmpty) {
      final level2List = _repository!.getLevel2();
      try {
        _selectedLevel2 = level2List.firstWhere(
          (item) => item.name == widget.level2Controller.text,
        );
      } catch (e) {
        _selectedLevel2 = null;
      }
    }

    // Restaurar nivel 3
    if (widget.level3Controller.text.isNotEmpty && _selectedLevel2 != null) {
      final level3List = _repository!.getLevel3(_selectedLevel2!.code);
      try {
        _selectedLevel3 = level3List.firstWhere(
          (item) => item.name == widget.level3Controller.text,
        );
      } catch (e) {
        _selectedLevel3 = null;
      }
    }

    // Restaurar nivel 4
    if (widget.level4Controller.text.isNotEmpty &&
        _selectedLevel2 != null &&
        _selectedLevel3 != null) {
      final level4List =
          _repository!.getLevel4(_selectedLevel2!.code, _selectedLevel3!.code);
      try {
        _selectedLevel4 = level4List.firstWhere(
          (item) => item.name == widget.level4Controller.text,
        );
      } catch (e) {
        _selectedLevel4 = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_repository == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final config = _repository!.config;

    return Column(
      children: [
        // Campo de país
        _buildCountryField(),
        SizedBox(height: widget.spacing),

        // Campo de nivel 2 (Departamento/Estado)
        _buildLocationField<AdministrativeLevel2>(
          controller: widget.level2Controller,
          labelText: config.level2Label,
          hintText: 'Selecciona tu ${config.level2Label.toLowerCase()}',
          icon: Icons.map_outlined,
          items: _repository!.getLevel2(),
          selectedItem: _selectedLevel2,
          displayText: (item) => item.name,
          onChanged: _onLevel2Changed,
          searchItems: (query) => _repository!.searchLevel2(query),
        ),

        SizedBox(height: widget.spacing),

        // Campo de nivel 3 (Provincia/Municipio/Município)
        _buildLocationField<AdministrativeLevel3>(
          controller: widget.level3Controller,
          labelText: config.level3Label,
          hintText: 'Selecciona tu ${config.level3Label.toLowerCase()}',
          icon: Icons.location_city_outlined,
          items: _selectedLevel2 != null
              ? _repository!.getLevel3(_selectedLevel2!.code)
              : [],
          selectedItem: _selectedLevel3,
          displayText: (item) => item.name,
          onChanged: _onLevel3Changed,
          enabled: _selectedLevel2 != null,
          searchItems: _selectedLevel2 != null
              ? (query) =>
                  _repository!.searchLevel3(_selectedLevel2!.code, query)
              : null,
        ),

        SizedBox(height: widget.spacing),

        // Campo de nivel 4 (Distrito/Corregimiento)
        _buildLocationField<AdministrativeLevel4>(
          controller: widget.level4Controller,
          labelText: config.level4Label,
          hintText: config.level4Optional
              ? '${config.level4Label} (opcional)'
              : 'Selecciona tu ${config.level4Label.toLowerCase()}',
          icon: Icons.place_outlined,
          items: _selectedLevel2 != null && _selectedLevel3 != null
              ? _repository!
                  .getLevel4(_selectedLevel2!.code, _selectedLevel3!.code)
              : [],
          selectedItem: _selectedLevel4,
          displayText: (item) => item.name,
          onChanged: _onLevel4Changed,
          enabled: _selectedLevel2 != null && _selectedLevel3 != null,
          searchItems: _selectedLevel2 != null && _selectedLevel3 != null
              ? (query) => _repository!.searchLevel4(
                    _selectedLevel2!.code,
                    _selectedLevel3!.code,
                    query,
                  )
              : null,
        ),
      ],
    );
  }

  /// Campo de país con selector
  Widget _buildCountryField() {
    final repositories = LocationRepositoryFactory.getAllRepositories();
    final countries = repositories.map((repo) => repo.getCountry()).toList();

    return GestureDetector(
      onTap: () => _showCountrySelectionDialog(countries),
      child: AbsorbPointer(
        child: TextFormField(
          controller: widget.countryController,
          decoration: _getFieldDecoration(
            labelText: 'País',
            hintText: 'Selecciona tu país',
            icon: Icons.public_outlined,
          ).copyWith(
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_repository != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      _repository!.getCountry().flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                const Icon(
                  Icons.arrow_drop_down_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ],
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Muestra el diálogo de selección de país
  Future<void> _showCountrySelectionDialog(List<Country> countries) async {
    await showDialog<Country>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.dialogColor ?? AppColors.surface,
        title: const Text(
          'Seleccionar País',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final isSelected = country.code == _repository?.getCountry().code;

              return ListTile(
                leading: Text(
                  country.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                title: Text(
                  country.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  _onCountryChanged(country);
                  Navigator.of(context).pop();
                },
              );
            },
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
    return GestureDetector(
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
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          enabled: enabled,
          decoration: _getFieldDecoration(
            labelText: labelText,
            hintText: enabled ? hintText : _getDisabledHint(labelText),
            icon: icon,
            enabled: enabled,
          ),
          style: TextStyle(
            fontSize: 16,
            color: controller.text.isEmpty
                ? AppColors.textSecondary.withValues(alpha: 0.7)
                : enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  /// Obtiene la decoración de campo personalizada
  InputDecoration _getFieldDecoration({
    required String labelText,
    required String hintText,
    required IconData icon,
    bool enabled = true,
  }) {
    final baseDecoration = widget.textFieldDecoration ??
        InputDecoration(
          fillColor: AppColors.neutral50,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.5),
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
              color: AppColors.border.withValues(alpha: 0.5),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          labelStyle: TextStyle(
            color: enabled
                ? AppColors.textSecondary
                : AppColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        );

    return baseDecoration.copyWith(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(
        icon,
        color: enabled
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.5),
      ),
      suffixIcon: Icon(
        Icons.arrow_drop_down_rounded,
        color: enabled
            ? AppColors.primary
            : AppColors.textSecondary.withValues(alpha: 0.5),
        size: 28,
      ),
    );
  }

  /// Obtiene el texto de hint cuando el campo está deshabilitado
  String _getDisabledHint(String labelText) {
    final config = _repository?.config;
    if (config == null) return 'Selección no disponible';

    if (labelText == config.level3Label) {
      return 'Primero selecciona ${config.level2Label.toLowerCase()}';
    } else if (labelText == config.level4Label) {
      return 'Primero selecciona ${config.level3Label.toLowerCase()}';
    }
    return 'Selección no disponible';
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

  /// Maneja el cambio de país
  void _onCountryChanged(Country country) {
    setState(() {
      _repository = LocationRepositoryFactory.create(country.code);
      _selectedLevel2 = null;
      _selectedLevel3 = null;
      _selectedLevel4 = null;

      widget.countryController.text = country.name;
      widget.level2Controller.clear();
      widget.level3Controller.clear();
      widget.level4Controller.clear();
    });

    widget.onCountryChanged?.call();
  }

  /// Maneja el cambio de nivel 2
  void _onLevel2Changed(AdministrativeLevel2? level2) {
    setState(() {
      _selectedLevel2 = level2;
      _selectedLevel3 = null;
      _selectedLevel4 = null;

      widget.level2Controller.text = level2?.name ?? '';
      widget.level3Controller.clear();
      widget.level4Controller.clear();
    });

    widget.onLevel2Changed?.call();
  }

  /// Maneja el cambio de nivel 3
  void _onLevel3Changed(AdministrativeLevel3? level3) {
    setState(() {
      _selectedLevel3 = level3;
      _selectedLevel4 = null;

      widget.level3Controller.text = level3?.name ?? '';
      widget.level4Controller.clear();
    });

    widget.onLevel3Changed?.call();
  }

  /// Maneja el cambio de nivel 4
  void _onLevel4Changed(AdministrativeLevel4? level4) {
    setState(() {
      _selectedLevel4 = level4;
      widget.level4Controller.text = level4?.name ?? '';
    });

    widget.onLevel4Changed?.call();
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
          widget.items
              .where((item) => widget
                  .displayText(item)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
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
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
