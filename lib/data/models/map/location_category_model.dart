import '../../../domain/entities/map/location_category.dart';
import '../../../domain/entities/map/category_config.dart';

class LocationCategoryModel extends LocationCategory {
  LocationCategoryModel({
    super.id,
    super.supabaseId,
    super.locationId,
    super.categoryId,
    super.enabled = true,
    super.config,
    super.displayOrder = 0,
    super.createdAt,
    super.updatedAt,
  });

  /// Constructor desde Supabase
  factory LocationCategoryModel.fromSupabase(Map<String, dynamic> map) {
    return LocationCategoryModel(
      supabaseId: map['id']?.toString(),
      locationId: map['location_id']?.toString(),
      categoryId: map['category_id']?.toString(),
      enabled: map['enabled'] as bool? ?? true,
      config: map['config'] != null
          ? CategoryConfig.fromJson(map['config'] as Map<String, dynamic>)
          : null,
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Constructor desde entity (para conversión)
  factory LocationCategoryModel.fromEntity(LocationCategory entity) {
    return LocationCategoryModel(
      id: entity.id,
      supabaseId: entity.supabaseId,
      locationId: entity.locationId,
      categoryId: entity.categoryId,
      enabled: entity.enabled,
      config: entity.config,
      displayOrder: entity.displayOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a Map para Supabase
  Map<String, dynamic> toSupabase() {
    final map = <String, dynamic>{
      'location_id': locationId,
      'category_id': categoryId,
      'enabled': enabled,
      'config': config?.toJson(),
      'display_order': displayOrder,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Solo incluir ID si no es null (para updates)
    if (supabaseId != null) {
      map['id'] = supabaseId;
    }

    // Solo incluir created_at si no es null
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }

    return map;
  }

  @override
  LocationCategoryModel copyWith({
    int? id,
    String? supabaseId,
    String? locationId,
    String? categoryId,
    bool? enabled,
    CategoryConfig? config,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationCategoryModel(
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
}
