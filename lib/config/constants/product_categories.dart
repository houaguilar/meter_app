/// Categorías de productos hardcodeadas para el marketplace
/// Las imágenes se encuentran en assets o URLs públicas
const PRODUCT_CATEGORIES = {
  'cemento': {
    'name': 'Cemento',
    'icon': '🧱',
    'description': 'Cemento para construcción',
    'brands': {
      'Sol': {
        'logo': 'assets/images/brands/cemento_sol.png',
        'products': {
          'Tipo I': {
            'image': 'assets/images/products/cemento_sol_tipo1.png',
            'description': 'Cemento Portland Tipo I',
            'presentations': ['Bolsa 42.5kg', 'A granel'],
          },
          'Tipo IP': {
            'image': 'assets/images/products/cemento_sol_tipoip.png',
            'description': 'Cemento Portland Tipo IP (con puzolana)',
            'presentations': ['Bolsa 42.5kg'],
          },
          'Tipo V': {
            'image': 'assets/images/products/cemento_sol_tipov.png',
            'description': 'Cemento Portland Tipo V (sulfato resistente)',
            'presentations': ['Bolsa 42.5kg'],
          },
        },
      },
      'Inka': {
        'logo': 'assets/images/brands/cemento_inka.png',
        'products': {
          'Tipo I': {
            'image': 'assets/images/products/cemento_inka_tipo1.png',
            'description': 'Cemento Portland Tipo I',
            'presentations': ['Bolsa 42.5kg'],
          },
          'Tipo IP': {
            'image': 'assets/images/products/cemento_inka_tipoip.png',
            'description': 'Cemento Portland Tipo IP',
            'presentations': ['Bolsa 42.5kg'],
          },
        },
      },
      'Pacasmayo': {
        'logo': 'assets/images/brands/cemento_pacasmayo.png',
        'products': {
          'Tipo I': {
            'image': 'assets/images/products/cemento_pacasmayo_tipo1.png',
            'description': 'Cemento Portland Tipo I',
            'presentations': ['Bolsa 42.5kg'],
          },
          'Tipo ICo': {
            'image': 'assets/images/products/cemento_pacasmayo_tipoico.png',
            'description': 'Cemento Portland Tipo ICo (compuesto)',
            'presentations': ['Bolsa 42.5kg'],
          },
        },
      },
      'Andino': {
        'logo': 'assets/images/brands/cemento_andino.png',
        'products': {
          'Tipo I': {
            'image': 'assets/images/products/cemento_andino_tipo1.png',
            'description': 'Cemento Portland Tipo I',
            'presentations': ['Bolsa 42.5kg'],
          },
        },
      },
      'Yura': {
        'logo': 'assets/images/brands/cemento_yura.png',
        'products': {
          'Tipo I': {
            'image': 'assets/images/products/cemento_yura_tipo1.png',
            'description': 'Cemento Portland Tipo I',
            'presentations': ['Bolsa 42.5kg'],
          },
          'Tipo IP': {
            'image': 'assets/images/products/cemento_yura_tipoip.png',
            'description': 'Cemento Portland Tipo IP',
            'presentations': ['Bolsa 42.5kg'],
          },
        },
      },
    },
    'attributes': {
      'types': ['Tipo I', 'Tipo IP', 'Tipo V', 'Tipo ICo'],
      'presentations': ['Bolsa 42.5kg', 'A granel'],
    },
  },
  'fierro': {
    'name': 'Fierro/Acero',
    'icon': '🔩',
    'description': 'Fierro de construcción y acero corrugado',
    'brands': {
      'Aceros Arequipa': {
        'logo': 'assets/images/brands/aceros_arequipa.png',
        'products': {
          '6mm': {
            'image': 'assets/images/products/fierro_6mm.png',
            'description': 'Fierro 6mm (1/4")',
            'types': ['Corrugado', 'Liso'],
          },
          '8mm': {
            'image': 'assets/images/products/fierro_8mm.png',
            'description': 'Fierro 8mm (5/16")',
            'types': ['Corrugado'],
          },
          '12mm': {
            'image': 'assets/images/products/fierro_12mm.png',
            'description': 'Fierro 12mm (1/2")',
            'types': ['Corrugado'],
          },
          '16mm': {
            'image': 'assets/images/products/fierro_16mm.png',
            'description': 'Fierro 16mm (5/8")',
            'types': ['Corrugado'],
          },
          '20mm': {
            'image': 'assets/images/products/fierro_20mm.png',
            'description': 'Fierro 20mm (3/4")',
            'types': ['Corrugado'],
          },
          '25mm': {
            'image': 'assets/images/products/fierro_25mm.png',
            'description': 'Fierro 25mm (1")',
            'types': ['Corrugado'],
          },
        },
      },
      'Siderperú': {
        'logo': 'assets/images/brands/siderperu.png',
        'products': {
          '6mm': {
            'image': 'assets/images/products/siderperu_6mm.png',
            'description': 'Fierro 6mm (1/4")',
            'types': ['Corrugado', 'Liso'],
          },
          '8mm': {
            'image': 'assets/images/products/siderperu_8mm.png',
            'description': 'Fierro 8mm (5/16")',
            'types': ['Corrugado'],
          },
          '12mm': {
            'image': 'assets/images/products/siderperu_12mm.png',
            'description': 'Fierro 12mm (1/2")',
            'types': ['Corrugado'],
          },
        },
      },
    },
    'attributes': {
      'diameters': ['6mm (1/4")', '8mm (5/16")', '12mm (1/2")', '16mm (5/8")', '20mm (3/4")', '25mm (1")'],
      'types': ['Corrugado', 'Liso'],
      'presentations': ['Varilla 9m', 'Rollo'],
    },
  },
  'arena': {
    'name': 'Arena',
    'icon': '⛱️',
    'description': 'Arena para construcción',
    'brands': {},
    'attributes': {
      'types': ['Arena gruesa', 'Arena fina', 'Arena de río'],
      'presentations': ['m³', 'Bolsa'],
    },
  },
  'piedra': {
    'name': 'Piedra',
    'icon': '🪨',
    'description': 'Piedra chancada y agregados',
    'brands': {},
    'attributes': {
      'types': ['Piedra chancada 1/2"', 'Piedra chancada 3/4"', 'Piedra de zanja', 'Piedra de cajón'],
      'presentations': ['m³', 'Bolsa'],
    },
  },
  'ladrillo': {
    'name': 'Ladrillo',
    'icon': '🟥',
    'description': 'Ladrillos para construcción',
    'brands': {
      'Lark': {
        'logo': 'assets/images/brands/ladrillo_lark.png',
        'products': {
          'King Kong': {
            'image': 'assets/images/products/ladrillo_kk.png',
            'description': 'Ladrillo King Kong 24x13x9cm',
            'types': ['Standard', '18 huecos', '12 huecos'],
          },
          'Pandereta': {
            'image': 'assets/images/products/ladrillo_pandereta.png',
            'description': 'Ladrillo Pandereta 24x12x6cm',
            'types': ['Standard'],
          },
        },
      },
      'Rex': {
        'logo': 'assets/images/brands/ladrillo_rex.png',
        'products': {
          'King Kong': {
            'image': 'assets/images/products/ladrillo_rex_kk.png',
            'description': 'Ladrillo King Kong',
            'types': ['Standard', '18 huecos'],
          },
        },
      },
      'Pirámide': {
        'logo': 'assets/images/brands/ladrillo_piramide.png',
        'products': {
          'King Kong': {
            'image': 'assets/images/products/ladrillo_piramide_kk.png',
            'description': 'Ladrillo King Kong',
            'types': ['Standard'],
          },
        },
      },
    },
    'attributes': {
      'types': ['King Kong', 'Pandereta', 'Techo', 'Pastelero', 'Caravista'],
      'dimensions': ['24x13x9cm', '24x12x6cm', '30x30cm'],
    },
  },
  'pintura': {
    'name': 'Pintura',
    'icon': '🎨',
    'description': 'Pinturas y acabados',
    'brands': {
      'Vencedor': {
        'logo': 'assets/images/brands/vencedor.png',
        'products': {
          'Látex': {
            'image': 'assets/images/products/vencedor_latex.png',
            'description': 'Pintura látex para interiores/exteriores',
            'presentations': ['Galón', '4 litros', '1 litro'],
          },
          'Esmalte': {
            'image': 'assets/images/products/vencedor_esmalte.png',
            'description': 'Esmalte sintético',
            'presentations': ['Galón', '1 litro'],
          },
        },
      },
      'Tekno': {
        'logo': 'assets/images/brands/tekno.png',
        'products': {
          'Látex': {
            'image': 'assets/images/products/tekno_latex.png',
            'description': 'Pintura látex',
            'presentations': ['Galón', '4 litros'],
          },
        },
      },
    },
    'attributes': {
      'types': ['Látex', 'Esmalte', 'Temple', 'Anticorrosivo'],
      'presentations': ['Galón', '4 litros', '1 litro'],
    },
  },
  'tuberia': {
    'name': 'Tubería',
    'icon': '🚰',
    'description': 'Tuberías y accesorios',
    'brands': {
      'Pavco': {
        'logo': 'assets/images/brands/pavco.png',
        'products': {
          'PVC Desagüe': {
            'image': 'assets/images/products/pavco_pvc_desague.png',
            'description': 'Tubería PVC para desagüe',
            'diameters': ['2"', '3"', '4"', '6"'],
          },
          'PVC Agua': {
            'image': 'assets/images/products/pavco_pvc_agua.png',
            'description': 'Tubería PVC para agua (presión)',
            'diameters': ['1/2"', '3/4"', '1"', '1 1/2"', '2"'],
          },
        },
      },
      'Nicoll': {
        'logo': 'assets/images/brands/nicoll.png',
        'products': {
          'PVC Desagüe': {
            'image': 'assets/images/products/nicoll_pvc_desague.png',
            'description': 'Tubería PVC para desagüe',
            'diameters': ['2"', '3"', '4"'],
          },
        },
      },
    },
    'attributes': {
      'types': ['PVC Desagüe', 'PVC Agua', 'PVC Eléctrico'],
      'diameters': ['1/2"', '3/4"', '1"', '2"', '3"', '4"', '6"'],
      'presentations': ['Tubo 3m', 'Tubo 5m'],
    },
  },
  'cable': {
    'name': 'Cable Eléctrico',
    'icon': '⚡',
    'description': 'Cables y materiales eléctricos',
    'brands': {
      'Indeco': {
        'logo': 'assets/images/brands/indeco.png',
        'products': {
          'THW': {
            'image': 'assets/images/products/indeco_thw.png',
            'description': 'Cable THW',
            'calibers': ['12 AWG', '14 AWG', '10 AWG', '8 AWG'],
          },
        },
      },
      'Cellocord': {
        'logo': 'assets/images/brands/cellocord.png',
        'products': {
          'THW': {
            'image': 'assets/images/products/cellocord_thw.png',
            'description': 'Cable THW',
            'calibers': ['12 AWG', '14 AWG'],
          },
        },
      },
    },
    'attributes': {
      'types': ['THW', 'TW', 'THHN', 'NMT'],
      'calibers': ['14 AWG', '12 AWG', '10 AWG', '8 AWG', '6 AWG'],
      'presentations': ['Metro', 'Rollo 100m'],
    },
  },
};

/// Helper para obtener imagen de un producto según categoría y atributos
class ProductImageHelper {
  /// Obtiene la URL de imagen de un producto
  static String? getImageUrl({
    required String categoryId,
    required Map<String, String> attributes,
  }) {
    final categoryData = PRODUCT_CATEGORIES[categoryId];
    if (categoryData == null) return _getDefaultImage(categoryId);

    final brand = attributes['brand'];
    if (brand == null || brand.isEmpty) return _getDefaultImage(categoryId);

    final brandsData = categoryData['brands'] as Map<String, dynamic>?;
    if (brandsData == null) return _getDefaultImage(categoryId);

    final brandData = brandsData[brand] as Map<String, dynamic>?;
    if (brandData == null) return _getDefaultImage(categoryId);

    final productsData = brandData['products'] as Map<String, dynamic>?;
    if (productsData == null) return _getDefaultImage(categoryId);

    // Lógica específica por categoría
    String? productKey;
    switch (categoryId) {
      case 'cemento':
        productKey = attributes['type']; // "Tipo I", "Tipo IP", etc.
        break;
      case 'fierro':
        productKey = attributes['diameter']; // "6mm", "8mm", etc.
        break;
      case 'ladrillo':
        productKey = attributes['type']; // "King Kong", "Pandereta", etc.
        break;
      case 'pintura':
        productKey = attributes['type']; // "Látex", "Esmalte", etc.
        break;
      case 'tuberia':
        productKey = attributes['type']; // "PVC Desagüe", "PVC Agua", etc.
        break;
      case 'cable':
        productKey = attributes['type']; // "THW", etc.
        break;
      default:
        return _getDefaultImage(categoryId);
    }

    if (productKey == null) return _getDefaultImage(categoryId);

    final productData = productsData[productKey] as Map<String, dynamic>?;
    if (productData == null) return _getDefaultImage(categoryId);

    return productData['image'] as String?;
  }

  /// Obtiene el logo de una marca
  static String? getBrandLogo(String categoryId, String brand) {
    final categoryData = PRODUCT_CATEGORIES[categoryId];
    if (categoryData == null) return null;

    final brandsData = categoryData['brands'] as Map<String, dynamic>?;
    if (brandsData == null) return null;

    final brandData = brandsData[brand] as Map<String, dynamic>?;
    return brandData?['logo'] as String?;
  }

  /// Imagen por defecto según categoría
  static String _getDefaultImage(String categoryId) {
    const defaults = {
      'cemento': 'assets/images/placeholders/cemento.png',
      'fierro': 'assets/images/placeholders/fierro.png',
      'arena': 'assets/images/placeholders/arena.png',
      'piedra': 'assets/images/placeholders/piedra.png',
      'ladrillo': 'assets/images/placeholders/ladrillo.png',
      'pintura': 'assets/images/placeholders/pintura.png',
      'tuberia': 'assets/images/placeholders/tuberia.png',
      'cable': 'assets/images/placeholders/cable.png',
    };
    return defaults[categoryId] ?? 'assets/images/placeholders/default.png';
  }

  /// Obtiene la lista de marcas de una categoría
  static List<String> getBrands(String categoryId) {
    final categoryData = PRODUCT_CATEGORIES[categoryId];
    if (categoryData == null) return [];

    final brandsData = categoryData['brands'] as Map<String, dynamic>?;
    if (brandsData == null) return [];

    return brandsData.keys.toList();
  }

  /// Obtiene los atributos de una categoría
  static Map<String, List<String>>? getAttributes(String categoryId) {
    final categoryData = PRODUCT_CATEGORIES[categoryId];
    if (categoryData == null) return null;

    final attributesData = categoryData['attributes'] as Map<String, dynamic>?;
    if (attributesData == null) return null;

    return attributesData.map(
      (key, value) => MapEntry(key, (value as List).cast<String>()),
    );
  }
}
