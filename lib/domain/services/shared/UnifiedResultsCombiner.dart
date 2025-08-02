// lib/domain/services/shared/unified_results_combiner.dart

import '../../../domain/entities/entities.dart';
import './UnifiedMaterialsCalculator.dart';

/// Servicio para combinar resultados YA CALCULADOS de múltiples metrados
/// Usa el mismo UnifiedMaterialsCalculator que ResultScreen
class UnifiedResultsCombiner {

  /// Combina resultados usando el MISMO calculador que ResultScreen
  static CombinedCalculationResult combineMetrados({
    required List<MetradoWithResults> metradosWithResults,
    required String projectName,
  }) {
    try {
      // Mapa para almacenar la suma total de cada material
      final combinedMaterials = <String, CombinedMaterial>{};
      final metradoSummaries = <MetradoSummary>[];
      double totalArea = 0.0;

      print('🔄 Iniciando combinación de ${metradosWithResults.length} metrados');

      // Procesar cada metrado con sus resultados
      for (final metradoData in metradosWithResults) {
        final metrado = metradoData.metrado;
        final results = metradoData.results; // Resultados del metrado

        print('📊 Procesando metrado: ${metrado.name} con ${results.length} resultados');

        // ✅ USAR EL MISMO CALCULADOR QUE RESULTSCREEN
        final calculationResult = UnifiedMaterialsCalculator.calculateMaterials(results);

        if (calculationResult.hasError) {
          print('⚠️ Error en cálculo de ${metrado.name}: ${calculationResult.errorMessage}');
          continue; // Saltar este metrado si hay error
        }

        // Extraer materiales del resultado calculado
        final metradoMaterials = _extractMaterialsFromCalculationResult(calculationResult);
        final metradoArea = calculationResult.totalValue;

        print('✅ Materiales calculados para ${metrado.name}:');
        metradoMaterials.forEach((material, cantidad) {
          print('   📦 $material: ${cantidad.toStringAsFixed(3)} ${_getMaterialUnit(material)}');
        });

        // Crear resumen del metrado individual
        final summary = MetradoSummary(
          metradoId: metrado.id,
          metradoName: metrado.name,
          materials: metradoMaterials,
          area: metradoArea,
          resultTypes: [_getTypeDisplayName(calculationResult.type)],
          itemCount: results.length,
        );
        metradoSummaries.add(summary);

        // CLAVE: Sumar materiales calculados
        print('🔗 Sumando materiales calculados de ${metrado.name}...');
        _combineMaterials(combinedMaterials, metradoMaterials, metrado.name);

        totalArea += metradoArea;
      }

      print('🎯 Combinación completada: ${combinedMaterials.length} materiales únicos');
      print('📊 RESUMEN FINAL DE MATERIALES:');
      combinedMaterials.forEach((name, material) {
        print('   🧱 $name: ${material.totalQuantity.toStringAsFixed(2)} ${material.unit}');
        print('      └─ Contribuciones: ${material.contributions.entries.map((e) => '${e.key}(${e.value.toStringAsFixed(2)})').join(', ')}');
      });

      return CombinedCalculationResult(
        combinedMaterials: combinedMaterials,
        metradoSummaries: metradoSummaries,
        totalArea: totalArea,
        projectName: projectName,
        combinationDate: DateTime.now(),
        metradoCount: metradosWithResults.length,
      );

    } catch (e) {
      print('❌ Error en combinación: $e');
      throw CombinationException(
        'Error al combinar metrados: ${e.toString()}',
      );
    }
  }

  /// EXTRAE materiales del CalculationResult (mismo formato que ResultScreen)
  static Map<String, double> _extractMaterialsFromCalculationResult(CalculationResult calculationResult) {
    final materials = <String, double>{};

    for (final material in calculationResult.materials) {
      final quantity = double.tryParse(material.quantity) ?? 0.0;
      if (quantity > 0) {
        materials[material.description] = quantity;
      }
    }

    return materials;
  }

  /// FUNCIÓN CLAVE: Combina/suma materiales de diferentes metrados
  static void _combineMaterials(
      Map<String, CombinedMaterial> combinedMaterials,
      Map<String, double> metradoMaterials,
      String metradoName,
      ) {
    metradoMaterials.forEach((materialName, quantity) {
      if (quantity <= 0) return; // Skip materiales con cantidad 0 o negativa

      // Normalizar el nombre del material para mejor agrupación
      final normalizedName = _normalizeMaterialName(materialName);

      if (combinedMaterials.containsKey(normalizedName)) {
        // MATERIAL YA EXISTE: SUMAR la cantidad
        final existing = combinedMaterials[normalizedName]!;
        final newContributions = Map<String, double>.from(existing.contributions);

        // Sumar la contribución de este metrado
        final currentContribution = newContributions[metradoName] ?? 0.0;
        newContributions[metradoName] = currentContribution + quantity;

        // Actualizar el material combinado con la nueva suma
        combinedMaterials[normalizedName] = existing.copyWith(
          totalQuantity: existing.totalQuantity + quantity, // ✅ SUMA CORRECTA AQUÍ
          contributions: newContributions,
        );

        print('➕ Sumando $normalizedName: ${existing.totalQuantity.toStringAsFixed(2)} + ${quantity.toStringAsFixed(2)} = ${(existing.totalQuantity + quantity).toStringAsFixed(2)} ${existing.unit}');
      } else {
        // MATERIAL NUEVO: agregarlo
        combinedMaterials[normalizedName] = CombinedMaterial(
          name: normalizedName,
          unit: _getMaterialUnit(normalizedName),
          totalQuantity: quantity,
          contributions: {metradoName: quantity},
        );

        print('🆕 Nuevo material $normalizedName: ${quantity.toStringAsFixed(2)} ${_getMaterialUnit(normalizedName)} (de $metradoName)');
      }
    });
  }

  /// Normaliza los nombres de materiales para mejor agrupación
  static String _normalizeMaterialName(String materialName) {
    // Normalizar nombres similares para que se sumen correctamente
    final name = materialName.toLowerCase().trim();

    // Cemento (todas las variaciones se agrupan como "Cemento")
    if (name.contains('cemento')) return 'Cemento';

    // Arena (distinguir entre arena fina y gruesa)
    if (name.contains('arena fina')) return 'Arena fina';
    if (name.contains('arena gruesa')) return 'Arena gruesa';
    if (name.contains('arena') && !name.contains('fina') && !name.contains('gruesa')) {
      return 'Arena gruesa'; // Por defecto
    }

    // Agua (todas se agrupan)
    if (name.contains('agua')) return 'Agua';

    // Piedra
    if (name.contains('piedra chancada') || name.contains('piedra')) return 'Piedra chancada';

    // Acero
    if (name.contains('acero')) return 'Acero';

    // Ladrillos - mantener el tipo específico
    if (name.contains('ladrillo')) {
      if (name.contains('king kong')) return 'Ladrillo King Kong';
      if (name.contains('pandereta')) return 'Ladrillo Pandereta';
      if (name.contains('artesanal')) return 'Ladrillo Artesanal';
      if (name.contains('techo') || name.contains('hueco')) return 'Ladrillo techo';
      return materialName; // Mantener nombre original si no coincide
    }

    // Retornar nombre original para casos no identificados
    return materialName;
  }

  /// Obtiene la unidad correcta para cada material
  static String _getMaterialUnit(String materialName) {
    final name = materialName.toLowerCase();

    if (name.contains('cemento')) return 'bls';
    if (name.contains('arena') || name.contains('piedra') || name.contains('agua')) return 'm³';
    if (name.contains('ladrillo')) return 'und';
    if (name.contains('acero')) return 'kg';

    return 'und'; // Por defecto
  }

  /// Convierte CalculationType a nombre display
  static String _getTypeDisplayName(CalculationType type) {
    switch (type) {
      case CalculationType.ladrillo:
        return 'Muro de Ladrillos';
      case CalculationType.piso:
        return 'Piso';
      case CalculationType.losaAligerada:
        return 'Losa Aligerada';
      case CalculationType.tarrajeo:
        return 'Tarrajeo';
      case CalculationType.columna:
        return 'Columna';
      case CalculationType.viga:
        return 'Viga';
      }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLASES DE DATOS PARA RESULTADOS COMBINADOS
// ═══════════════════════════════════════════════════════════════════════════

/// Resultado de la unión/combinación de múltiples metrados
class CombinedCalculationResult {
  final Map<String, CombinedMaterial> combinedMaterials;
  final List<MetradoSummary> metradoSummaries;
  final double totalArea;
  final String projectName;
  final DateTime combinationDate;
  final int metradoCount;

  const CombinedCalculationResult({
    required this.combinedMaterials,
    required this.metradoSummaries,
    required this.totalArea,
    required this.projectName,
    required this.combinationDate,
    required this.metradoCount,
  });

  /// Lista ordenada de materiales por cantidad (mayor a menor)
  List<CombinedMaterial> get sortedMaterials {
    final materials = combinedMaterials.values.toList();
    materials.sort((a, b) => b.totalQuantity.compareTo(a.totalQuantity));
    return materials;
  }

  /// Material más usado en el proyecto
  CombinedMaterial? get topMaterial {
    if (combinedMaterials.isEmpty) return null;
    return sortedMaterials.first;
  }

  /// Estadísticas generales de la combinación
  CombinationStats get stats {
    return CombinationStats(
      totalMaterials: combinedMaterials.length,
      totalMetrados: metradoCount,
      totalArea: totalArea,
    );
  }
}

/// Material combinado con contribuciones de cada metrado
class CombinedMaterial {
  final String name;
  final String unit;
  final double totalQuantity; // SUMA TOTAL del material
  final Map<String, double> contributions; // Cuánto aporta cada metrado

  const CombinedMaterial({
    required this.name,
    required this.unit,
    required this.totalQuantity,
    required this.contributions,
  });

  CombinedMaterial copyWith({
    String? name,
    String? unit,
    double? totalQuantity,
    Map<String, double>? contributions,
  }) {
    return CombinedMaterial(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      contributions: contributions ?? this.contributions,
    );
  }

  /// Obtiene el porcentaje de contribución de un metrado específico
  double getContributionPercentage(String metradoName) {
    final contribution = contributions[metradoName] ?? 0.0;
    return totalQuantity > 0 ? (contribution / totalQuantity) * 100 : 0.0;
  }

  /// Metrado que más contribuye a este material
  String get topContributor {
    if (contributions.isEmpty) return '';
    return contributions.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Formatea la cantidad con su unidad
  String get formattedQuantity {
    return '${totalQuantity.toStringAsFixed(2)} $unit';
  }
}

/// Resumen de un metrado individual
class MetradoSummary {
  final int metradoId;
  final String metradoName;
  final Map<String, double> materials;
  final double area;
  final List<String> resultTypes;
  final int itemCount;

  const MetradoSummary({
    required this.metradoId,
    required this.metradoName,
    required this.materials,
    required this.area,
    required this.resultTypes,
    required this.itemCount,
  });

  /// Material principal de este metrado
  String get primaryMaterial {
    if (materials.isEmpty) return 'N/A';
    return materials.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Descripción resumida del metrado
  String get description {
    return '${itemCount} elemento${itemCount != 1 ? 's' : ''} • ${materials.length} material${materials.length != 1 ? 'es' : ''}';
  }
}

/// Datos de entrada para la combinación
class MetradoWithResults {
  final Metrado metrado;
  final List<dynamic> results;

  const MetradoWithResults({
    required this.metrado,
    required this.results,
  });
}

/// Estadísticas de la combinación
class CombinationStats {
  final int totalMaterials;
  final int totalMetrados;
  final double totalArea;

  const CombinationStats({
    required this.totalMaterials,
    required this.totalMetrados,
    required this.totalArea,
  });

  /// Promedio de materiales por metrado
  double get averageMaterialsPerMetrado {
    return totalMetrados > 0 ? totalMaterials / totalMetrados : 0.0;
  }

  /// Área promedio por metrado
  double get averageAreaPerMetrado {
    return totalMetrados > 0 ? totalArea / totalMetrados : 0.0;
  }
}

/// Excepción para errores en la combinación
class CombinationException implements Exception {
  final String message;

  const CombinationException(this.message);

  @override
  String toString() => 'CombinationException: $message';
}