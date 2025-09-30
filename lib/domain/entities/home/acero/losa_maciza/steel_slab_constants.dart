// lib/domain/entities/home/acero/losa/steel_slab_calculation_result.dart
import 'mesh_enums.dart';

/// Resultado del cálculo de acero para una losa
class SteelSlabCalculationResult {
  final String slabId;
  final String description;
  final double totalWeight; // Peso total en kg
  final double wireWeight; // Alambre #16 en kg
  final Map<String, MaterialQuantity> materials; // Materiales por diámetro
  final Map<String, double> totalsByDiameter; // Totales en metros por diámetro
  final SlabMeshCalculation inferiorMesh; // Cálculos malla inferior
  final SlabMeshCalculation? superiorMesh; // Cálculos malla superior (opcional)

  const SteelSlabCalculationResult({
    required this.slabId,
    required this.description,
    required this.totalWeight,
    required this.wireWeight,
    required this.materials,
    required this.totalsByDiameter,
    required this.inferiorMesh,
    this.superiorMesh,
  });
}

/// Cálculo de una malla específica
class SlabMeshCalculation {
  final MeshType type;
  final SlabDirectionCalculation horizontal;
  final SlabDirectionCalculation vertical;
  final double totalWeight; // Peso de esta malla

  const SlabMeshCalculation({
    required this.type,
    required this.horizontal,
    required this.vertical,
    required this.totalWeight,
  });
}

/// Cálculo de una dirección específica (horizontal o vertical)
class SlabDirectionCalculation {
  final String diameter;
  final double separation;
  final int quantity; // Cantidad de barras
  final double lengthPerBar; // Longitud por barra
  final double totalLength; // Longitud total
  final double weight; // Peso total de esta dirección

  const SlabDirectionCalculation({
    required this.diameter,
    required this.separation,
    required this.quantity,
    required this.lengthPerBar,
    required this.totalLength,
    required this.weight,
  });
}

/// Resultado consolidado de múltiples losas
class ConsolidatedSteelSlabResult {
  final int numberOfSlabs;
  final double totalWeight; // Peso total general en kg
  final double totalWire; // Alambre total en kg
  final List<SteelSlabCalculationResult> slabResults; // Resultados individuales
  final Map<String, MaterialQuantity> consolidatedMaterials; // Materiales consolidados

  const ConsolidatedSteelSlabResult({
    required this.numberOfSlabs,
    required this.totalWeight,
    required this.totalWire,
    required this.slabResults,
    required this.consolidatedMaterials,
  });
}

/// Cantidad de material (reutilizando de steel_constants.dart)
class MaterialQuantity {
  final double quantity; // Cantidad en varillas
  final String unit; // Unidad (Varillas)

  const MaterialQuantity({
    required this.quantity,
    required this.unit,
  });
}