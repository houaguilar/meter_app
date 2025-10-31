import 'package:isar/isar.dart';
import 'category_config.dart';

part 'location_category.g.dart';

/// Categoría de productos configurada para una ubicación específica
/// Ejemplo: Una ferretería puede tener configuradas las categorías "cemento", "fierro", "arena"
@collection
class LocationCategory {
  /// ID auto-incremental de Isar
  Id id = Isar.autoIncrement;

  /// UUID de Supabase (para sincronización)
  @Index()
  String? supabaseId;

  /// ID de la ubicación a la que pertenece
  @Index()
  String? locationId;

  /// ID de la categoría (ej: 'cemento', 'fierro', 'arena')
  /// Corresponde a las categorías definidas en product_categories.dart
  @Index()
  String? categoryId;

  /// Si la categoría está habilitada para este proveedor
  bool enabled;

  /// Configuración específica de la categoría (marcas, atributos)
  CategoryConfig? config;

  /// Orden de visualización (para ordenar en UI)
  int displayOrder;

  /// Fecha de creación
  DateTime? createdAt;

  /// Fecha de última actualización
  DateTime? updatedAt;

  LocationCategory({
    this.id = Isar.autoIncrement,
    this.supabaseId,
    this.locationId,
    this.categoryId,
    this.enabled = true,
    this.config,
    this.displayOrder = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Constructor vacío para categoría nueva
  LocationCategory.empty({
    required String categoryId,
    required String locationId,
  })  : id = Isar.autoIncrement,
        supabaseId = null,
        locationId = locationId,
        categoryId = categoryId,
        enabled = true,
        config = CategoryConfig.empty(),
        displayOrder = 0,
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// Si tiene configuración válida
  bool get hasValidConfig {
    return config?.hasConfiguration ?? false;
  }

  /// Total de selecciones en la configuración
  int get totalSelections {
    return config?.totalSelections ?? 0;
  }

  /// Descripción para UI
  String get description {
    if (!hasValidConfig) return 'Sin configurar';

    final brands = config?.brands?.length ?? 0;
    final attributes = config?.attributes.values.fold<int>(
          0,
          (sum, list) => sum + list.length,
        ) ??
        0;

    final parts = <String>[];
    if (brands > 0) parts.add('$brands marca${brands > 1 ? 's' : ''}');
    if (attributes > 0) parts.add('$attributes variante${attributes > 1 ? 's' : ''}');

    return parts.join(', ');
  }

  LocationCategory copyWith({
    Id? id,
    String? supabaseId,
    String? locationId,
    String? categoryId,
    bool? enabled,
    CategoryConfig? config,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationCategory(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      locationId: locationId ?? this.locationId,
      categoryId: categoryId ?? this.categoryId,
      enabled: enabled ?? this.enabled,
      config: config ?? this.config,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'LocationCategory(id: $id, categoryId: $categoryId, enabled: $enabled, selections: $totalSelections)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationCategory &&
        other.supabaseId == supabaseId &&
        other.categoryId == categoryId &&
        other.locationId == locationId;
  }

  @override
  int get hashCode => Object.hash(supabaseId, categoryId, locationId);
}
