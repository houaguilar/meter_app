class TipoLadrilloModel {
  String imageAsset;
  String title;
  String location;

  TipoLadrilloModel({
    required this.imageAsset,
    required this.title,
    required this.location,
  });
  static List<TipoLadrilloModel> generateTipoLadrillo() {
    return [
      TipoLadrilloModel(
        imageAsset: 'assets/images/kingkong_piramide.png',
        title: 'Kingkong',
        location: 'tutorial-ladrillo',
      ),
      TipoLadrilloModel(
        imageAsset: 'assets/images/pandereta_piramide.png',
        title: 'Pandereta',
        location: 'tutorial-ladrillo',
      ),
      TipoLadrilloModel(
        imageAsset: 'assets/images/tabicon_piramide.png',
        title: 'Tabicon',
        location: 'tutorial-ladrillo',
      ),
    ];
  }
}


class BrickWallCalculator {
  // =============================================
  // Cálculo de cantidad de ladrillos por m² (CL)
  // =============================================
  static double calculateBricksPerSquareMeter({
    required double brickLength,    // Largo ladrillo (cm)
    required double brickHeight,    // Alto ladrillo (cm)
    required double horizontalJoint,// Junta horizontal (cm)
    required double verticalJoint,  // Junta vertical (cm)
  }) {
    // Convertir cm a metros
    final effectiveLength = (brickLength + horizontalJoint) / 100;
    final effectiveHeight = (brickHeight + verticalJoint) / 100;

    return 1 / (effectiveLength * effectiveHeight);
  }

  // =============================================
  // Cálculo de volumen de mortero por m² (Vmo)
  // =============================================
  static double calculateMortarVolumePerSquareMeter({
    required double wallThickness,     // Espesor muro (cm)
    required double bricksPerM2,
    required double brickLength,       // cm
    required double brickWidth,        // cm (ancho)
    required double brickHeight,       // cm
  }) {
    // Volumen total del muro (1m² * espesor en metros)
    final wallVolume = 1 * 1 * (wallThickness / 100);

    // Volumen ocupado por ladrillos
    final brickVolume = bricksPerM2 *
        (brickLength / 100) *
        (brickWidth / 100) *
        (brickHeight / 100);

    return wallVolume - brickVolume;
  }

  // =============================================
  // Cálculo de materiales finales con desperdicio
  // =============================================
  static double calculateMaterialWithWaste({
    required double quantity,
    required double wastePercentage,
  }) {
    return quantity * (1 + wastePercentage);
  }
}


class BrickWallData {
  final String brickType;
  final double brickLength;    // cm
  final double brickWidth;     // cm
  final double brickHeight;    // cm
  final double wallThickness;  // cm
  final double horizontalJoint;// cm
  final double verticalJoint;  // cm
  final double wallArea;       // m²

  BrickWallData({
    required this.brickType,
    required this.brickLength,
    required this.brickWidth,
    required this.brickHeight,
    required this.wallThickness,
    required this.horizontalJoint,
    required this.verticalJoint,
    required this.wallArea,
  });
}

class MaterialResult {
  final double totalBricks;
  final double mortarVolume;   // m³
  final double cementBags;     // bolsas
  final double sandVolume;     // m³
  final double waterVolume;    // m³

  MaterialResult({
    required this.totalBricks,
    required this.mortarVolume,
    required this.cementBags,
    required this.sandVolume,
    required this.waterVolume,
  });
}

MaterialResult calculateAllMaterials({
  required BrickWallData data,
  required double cementPerCubicMeter,  // Bolsas/m³ (ej: 7.4 para mortero 1:5)
  required double sandPerCubicMeter,    // m³/m³
  required double waterPerCubicMeter,   // m³/m³
  double brickWaste = 0.05,             // 5%
  double mortarWaste = 0.10,            // 10%
}) {
  // 1. Ladrillos por m²
  final bricksPerM2 = BrickWallCalculator.calculateBricksPerSquareMeter(
    brickLength: data.brickLength,
    brickHeight: data.brickHeight,
    horizontalJoint: data.horizontalJoint,
    verticalJoint: data.verticalJoint,
  );

  // 2. Volumen de mortero por m²
  final mortarPerM2 = BrickWallCalculator.calculateMortarVolumePerSquareMeter(
    wallThickness: data.wallThickness,
    bricksPerM2: bricksPerM2,
    brickLength: data.brickLength,
    brickWidth: data.brickWidth,
    brickHeight: data.brickHeight,
  );

  // 3. Cálculos totales
  final totalBricks = bricksPerM2 * data.wallArea;
  final totalMortar = mortarPerM2 * data.wallArea;

  // 4. Aplicar desperdicio
  final finalBricks = BrickWallCalculator.calculateMaterialWithWaste(
    quantity: totalBricks,
    wastePercentage: brickWaste,
  );

  final finalMortar = BrickWallCalculator.calculateMaterialWithWaste(
    quantity: totalMortar,
    wastePercentage: mortarWaste,
  );

  // 5. Materiales derivados
  return MaterialResult(
    totalBricks: finalBricks,
    mortarVolume: finalMortar,
    cementBags: finalMortar * cementPerCubicMeter,
    sandVolume: finalMortar * sandPerCubicMeter,
    waterVolume: finalMortar * waterPerCubicMeter,
  );
}