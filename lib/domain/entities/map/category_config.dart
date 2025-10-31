import 'dart:convert';
import 'package:isar/isar.dart';

part 'category_config.g.dart';

/// Configuración de una categoría para un proveedor específico
/// Define qué marcas y atributos ofrece el proveedor en esta categoría
@embedded
class CategoryConfig {
  /// Lista de marcas que el proveedor ofrece
  /// Ejemplo: ['Sol', 'Inka', 'Pacasmayo']
  List<String>? brands;

  /// Atributos adicionales como JSON string
  /// Isar no soporta Map<String, List<String>> directamente
  /// Ejemplo serializado: {"types": ["Tipo I", "Tipo IP"], "presentations": ["Bolsa 42.5kg"]}
  String? attributesJson;

  CategoryConfig({
    this.brands,
    this.attributesJson,
  });

  /// Constructor vacío
  CategoryConfig.empty()
      : brands = [],
        attributesJson = '{}';

  /// Constructor desde JSON (JSONB de Supabase)
  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    final brands = json['brands'] as List<dynamic>?;
    final attributes = json['attributes'] as Map<String, dynamic>?;

    return CategoryConfig(
      brands: brands?.cast<String>(),
      attributesJson: attributes != null ? jsonEncode(attributes) : '{}',
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'brands': brands ?? [],
      'attributes': attributes,
    };
  }

  /// Getter para obtener los atributos como Map
  /// Ejemplo: {'types': ['Tipo I', 'Tipo IP'], 'presentations': ['Bolsa 42.5kg']}
  @ignore
  Map<String, List<String>> get attributes {
    if (attributesJson == null || attributesJson!.isEmpty || attributesJson == '{}') {
      return {};
    }

    try {
      final decoded = jsonDecode(attributesJson!) as Map<String, dynamic>;
      return decoded.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<String>());
        }
        return MapEntry(key, <String>[]);
      });
    } catch (e) {
      return {};
    }
  }

  /// Setter para establecer los atributos desde Map
  set attributes(Map<String, List<String>> value) {
    attributesJson = jsonEncode(value);
  }

  /// Total de selecciones (marcas + atributos)
  int get totalSelections {
    final brandsCount = brands?.length ?? 0;
    final attributesCount = attributes.values.fold<int>(
      0,
      (sum, list) => sum + list.length,
    );
    return brandsCount + attributesCount;
  }

  /// Si tiene alguna configuración
  bool get hasConfiguration {
    return (brands?.isNotEmpty ?? false) || attributes.isNotEmpty;
  }

  /// Agrega una marca
  void addBrand(String brand) {
    if (brands == null) {
      brands = [brand];
    } else if (!brands!.contains(brand)) {
      brands!.add(brand);
    }
  }

  /// Remueve una marca
  void removeBrand(String brand) {
    brands?.remove(brand);
  }

  /// Agrega un atributo a una categoría específica
  void addAttribute(String key, String value) {
    final currentAttributes = attributes;

    if (currentAttributes.containsKey(key)) {
      if (!currentAttributes[key]!.contains(value)) {
        currentAttributes[key]!.add(value);
      }
    } else {
      currentAttributes[key] = [value];
    }

    attributes = currentAttributes;
  }

  /// Remueve un atributo de una categoría específica
  void removeAttribute(String key, String value) {
    final currentAttributes = attributes;

    if (currentAttributes.containsKey(key)) {
      currentAttributes[key]!.remove(value);
      if (currentAttributes[key]!.isEmpty) {
        currentAttributes.remove(key);
      }
    }

    attributes = currentAttributes;
  }

  /// Verifica si una marca está seleccionada
  bool hasBrand(String brand) {
    return brands?.contains(brand) ?? false;
  }

  /// Verifica si un atributo está seleccionado
  bool hasAttribute(String key, String value) {
    return attributes[key]?.contains(value) ?? false;
  }

  CategoryConfig copyWith({
    List<String>? brands,
    String? attributesJson,
  }) {
    return CategoryConfig(
      brands: brands ?? this.brands,
      attributesJson: attributesJson ?? this.attributesJson,
    );
  }

  @override
  String toString() {
    return 'CategoryConfig(brands: ${brands?.length ?? 0}, attributes: ${attributes.keys.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryConfig &&
        other.attributesJson == attributesJson &&
        _listEquals(other.brands, brands);
  }

  @override
  int get hashCode => Object.hash(attributesJson, brands);

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
