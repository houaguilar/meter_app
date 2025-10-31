import 'dart:convert';
import 'package:isar/isar.dart';

part 'product.g.dart';

/// Moneda para el precio del producto
enum Currency {
  /// Soles peruanos
  PEN,

  /// Dólares americanos
  USD;

  /// Símbolo de la moneda
  String get symbol {
    switch (this) {
      case Currency.PEN:
        return 'S/';
      case Currency.USD:
        return '\$';
    }
  }

  /// Nombre completo
  String get displayName {
    switch (this) {
      case Currency.PEN:
        return 'Soles';
      case Currency.USD:
        return 'Dólares';
    }
  }
}

/// Unidad de medida del producto
enum ProductUnit {
  bolsa,
  kg,
  m3, // metro cúbico
  m2, // metro cuadrado
  unidad,
  metro,
  litro,
  galon,
  saco,
  caja,
  paquete;

  /// Nombre para mostrar en UI
  String get displayName {
    switch (this) {
      case ProductUnit.bolsa:
        return 'bolsa';
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.m3:
        return 'm³';
      case ProductUnit.m2:
        return 'm²';
      case ProductUnit.unidad:
        return 'unidad';
      case ProductUnit.metro:
        return 'metro';
      case ProductUnit.litro:
        return 'litro';
      case ProductUnit.galon:
        return 'galón';
      case ProductUnit.saco:
        return 'saco';
      case ProductUnit.caja:
        return 'caja';
      case ProductUnit.paquete:
        return 'paquete';
    }
  }

  /// Abreviación
  String get abbreviation {
    switch (this) {
      case ProductUnit.bolsa:
        return 'bolsa';
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.m3:
        return 'm³';
      case ProductUnit.m2:
        return 'm²';
      case ProductUnit.unidad:
        return 'und';
      case ProductUnit.metro:
        return 'm';
      case ProductUnit.litro:
        return 'L';
      case ProductUnit.galon:
        return 'gal';
      case ProductUnit.saco:
        return 'saco';
      case ProductUnit.caja:
        return 'caja';
      case ProductUnit.paquete:
        return 'paq';
    }
  }
}

/// Producto ofrecido por un proveedor
@collection
class Product {
  /// ID auto-incremental de Isar
  Id id = Isar.autoIncrement;

  /// UUID de Supabase (para sincronización)
  @Index()
  String? supabaseId;

  /// ID de la ubicación/proveedor que ofrece este producto
  @Index()
  String? locationId;

  /// ID de la categoría (ej: 'cemento', 'fierro')
  @Index()
  String? categoryId;

  /// Nombre del producto
  /// Ejemplo: "Cemento Sol Tipo I"
  String? name;

  /// Descripción adicional
  String? description;

  /// Precio del producto (puede ser null si no se especifica)
  double? price;

  /// Moneda del precio
  @enumerated
  Currency currency;

  /// Unidad de medida como string (para permitir null en Isar)
  /// Valores: 'bolsa', 'kg', 'm3', 'm2', 'unidad', 'metro', 'litro', 'galon', 'saco', 'caja', 'paquete'
  String? unitString;

  /// Atributos del producto como JSON string
  /// Ejemplo: {"brand": "Sol", "type": "Tipo I", "presentation": "Bolsa 42.5kg"}
  /// Isar no soporta Map directamente
  String? attributesJson;

  /// Si hay stock disponible
  bool stockAvailable;

  /// Si es producto destacado (se muestra primero)
  bool featured;

  /// Fecha de creación
  DateTime? createdAt;

  /// Fecha de última actualización
  DateTime? updatedAt;

  Product({
    this.id = Isar.autoIncrement,
    this.supabaseId,
    this.locationId,
    this.categoryId,
    this.name,
    this.description,
    this.price,
    this.currency = Currency.PEN,
    this.unitString,
    this.attributesJson,
    this.stockAvailable = true,
    this.featured = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Getter para obtener unit como enum
  @ignore
  ProductUnit? get unit {
    if (unitString == null) return null;
    try {
      return ProductUnit.values.firstWhere((e) => e.name == unitString);
    } catch (e) {
      return null;
    }
  }

  /// Setter para establecer unit desde enum
  set unit(ProductUnit? value) {
    unitString = value?.name;
  }

  /// Getter para obtener los atributos como Map
  @ignore
  Map<String, String> get attributes {
    if (attributesJson == null || attributesJson!.isEmpty || attributesJson == '{}') {
      return {};
    }

    try {
      final decoded = jsonDecode(attributesJson!) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  /// Setter para establecer los atributos desde Map
  set attributes(Map<String, String> value) {
    attributesJson = jsonEncode(value);
  }

  /// Precio formateado con moneda
  /// Ejemplo: "S/ 22.50"
  String get formattedPrice {
    if (price == null) return 'Precio no disponible';
    return '${currency.symbol} ${price!.toStringAsFixed(2)}';
  }

  /// Precio con unidad
  /// Ejemplo: "S/ 22.50 / bolsa"
  String get priceWithUnit {
    if (price == null) return 'Precio no disponible';
    final unitText = unit?.displayName ?? '';
    return unitText.isNotEmpty ? '$formattedPrice / $unitText' : formattedPrice;
  }

  /// Precio corto (sin decimales si es entero)
  /// Ejemplo: "S/ 22" o "S/ 22.50"
  String get shortPrice {
    if (price == null) return '-';
    final isInteger = price! % 1 == 0;
    return '${currency.symbol} ${isInteger ? price!.toInt() : price!.toStringAsFixed(2)}';
  }

  /// Si tiene precio configurado
  bool get hasPrice {
    return price != null && price! > 0;
  }

  /// Obtiene un atributo específico
  String? getAttribute(String key) {
    return attributes[key];
  }

  /// Marca del producto (si existe en atributos)
  String? get brand => getAttribute('brand');

  /// Tipo del producto (si existe en atributos)
  String? get type => getAttribute('type');

  /// Presentación del producto (si existe en atributos)
  String? get presentation => getAttribute('presentation');

  Product copyWith({
    Id? id,
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
    return Product(
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

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $formattedPrice, stock: $stockAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product &&
        other.supabaseId == supabaseId &&
        other.locationId == locationId &&
        other.categoryId == categoryId;
  }

  @override
  int get hashCode => Object.hash(supabaseId, locationId, categoryId);
}
