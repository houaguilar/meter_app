import 'dart:convert';
import '../../../domain/entities/map/product.dart';

class ProductModel extends Product {
  ProductModel({
    super.id,
    super.supabaseId,
    super.locationId,
    super.categoryId,
    super.name,
    super.description,
    super.price,
    super.currency = Currency.PEN,
    super.unitString,
    super.attributesJson,
    super.stockAvailable = true,
    super.featured = false,
    super.createdAt,
    super.updatedAt,
  });

  /// Constructor desde Supabase
  factory ProductModel.fromSupabase(Map<String, dynamic> map) {
    // Manejar attributes de forma segura
    String? attributesJson;
    try {
      if (map.containsKey('attributes') && map['attributes'] != null) {
        // Si attributes es un Map (JSONB), convertirlo a String
        if (map['attributes'] is Map) {
          attributesJson = jsonEncode(map['attributes']);
        } else if (map['attributes'] is String) {
          attributesJson = map['attributes'] as String;
        }
      }
    } catch (e) {
      // Si hay error, dejar attributes como null
      attributesJson = null;
    }

    return ProductModel(
      supabaseId: map['id']?.toString(),
      locationId: map['location_id']?.toString(),
      categoryId: map['category_id']?.toString(),
      name: map['name']?.toString(),
      description: map['description']?.toString(),
      price: (map['price'] as num?)?.toDouble(),
      currency: map['currency'] != null
          ? _parseCurrency(map['currency'].toString())
          : Currency.PEN,
      unitString: map['unit']?.toString(),
      attributesJson: attributesJson,
      stockAvailable: map['stock_available'] as bool? ?? true,
      featured: map['featured'] as bool? ?? false,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  /// Constructor desde entity (para conversión)
  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      supabaseId: entity.supabaseId,
      locationId: entity.locationId,
      categoryId: entity.categoryId,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      currency: entity.currency,
      unitString: entity.unitString,
      attributesJson: entity.attributesJson,
      stockAvailable: entity.stockAvailable,
      featured: entity.featured,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convierte a Map para Supabase
  Map<String, dynamic> toSupabase() {
    // Manejar attributes de forma segura
    dynamic attributesValue;
    try {
      if (attributesJson != null && attributesJson!.isNotEmpty && attributesJson != '{}') {
        attributesValue = jsonDecode(attributesJson!);
      }
    } catch (e) {
      // Si hay error al decodificar, usar objeto vacío
      attributesValue = <String, dynamic>{};
    }

    final map = <String, dynamic>{
      'location_id': locationId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency.name,
      'unit': unitString,
      'stock_available': stockAvailable,
      'featured': featured,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Solo incluir attributes si tiene valor
    if (attributesValue != null) {
      map['attributes'] = attributesValue;
    }

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

  /// Helper para parsear Currency desde string
  static Currency _parseCurrency(String value) {
    switch (value.toUpperCase()) {
      case 'PEN':
        return Currency.PEN;
      case 'USD':
        return Currency.USD;
      default:
        return Currency.PEN;
    }
  }


  @override
  ProductModel copyWith({
    int? id,
    String? supabaseId,
    String? locationId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    Currency? currency,
    String? unitString,
    String? attributesJson,
    bool? stockAvailable,
    bool? featured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      supabaseId: supabaseId ?? this.supabaseId,
      locationId: locationId ?? this.locationId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      unitString: unitString ?? this.unitString,
      attributesJson: attributesJson ?? this.attributesJson,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      featured: featured ?? this.featured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
