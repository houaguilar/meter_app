

import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../../domain/repositories/home/muro/wall_material_repository.dart';
import '../../../../presentation/assets/images.dart';

class WallMaterialRepositoryImpl implements WallMaterialRepository {
  @override
  Future<List<WallMaterial>> getWallMaterials() async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 800));

    return _getMaterialsData();
  }

  @override
  Future<WallMaterial?> getWallMaterialById(String id) async {
    final materials = await getWallMaterials();
    try {
      return materials.firstWhere((material) => material.id == id);
    } catch (e) {
      return null;
    }
  }

  List<WallMaterial> _getMaterialsData() {
    return [
      // PANDERETAS
      WallMaterial(
        id: '1',
        name: 'Pandereta 1',
        image: AppImages.panderetaFirstImg,
        size: '23cm x 12cm x 9cm',
        lengthBrick: 23,
        widthBrick: 12,
        heightBrick: 9,
        details: '· Ladrillo para muros no portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 23×12×9 cm.\n· Rendimiento: 44 u/m² en soga.',
      ),

      WallMaterial(
        id: '2',
        name: 'Pandereta 2',
        image: AppImages.pandereta2Img,
        size: '23cm x 12cm x 9cm',
        lengthBrick: 23,
        widthBrick: 12,
        heightBrick: 9,
        details: '· Ladrillo para muros no portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 23×12×9 cm.\n· Rendimiento: 44 u/m² en soga.',
      ),

      // KING KONG
      WallMaterial(
        id: '3',
        name: 'King Kong 1',
        image: AppImages.kingkong1Img,
        size: '24cm x 13cm x 9cm',
        lengthBrick: 24,
        widthBrick: 13,
        heightBrick: 9,
        details: '· Ladrillo resistente para muros portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 24×13×9 cm.\n· Rendimiento: 47 u/m² en soga.',
      ),

      WallMaterial(
        id: '4',
        name: 'King Kong 2',
        image: AppImages.kingkong2Img,
        size: '24cm x 13cm x 9cm',
        lengthBrick: 24,
        widthBrick: 13,
        heightBrick: 9,
        details: '· Ladrillo resistente para muros portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 24×13×9 cm.\n· Rendimiento: 47 u/m² en soga.',
      ),

      // TABICÓN
      WallMaterial(
        id: '5',
        name: 'Tabicón',
        image: AppImages.tabiconImg,
        size: '20cm x 20cm x 15cm',
        lengthBrick: 20,
        widthBrick: 20,
        heightBrick: 15,
        details: '· Bloque hueco para tabiquería.\n· Excelente aislamiento térmico.\n· Dimensiones: 20×20×15 cm.\n· Instalación rápida y eficiente.',
      ),

      // LADRILLO PERSONALIZADO
      WallMaterial(
        id: 'custom',
        name: 'Ladrillo Personalizado',
        image: AppImages.tabiconImg, // Reutilizando imagen existente
        size: 'Configurable',
        lengthBrick: null, // Se configurará dinámicamente
        widthBrick: null,
        heightBrick: null,
        details: '· Personaliza las dimensiones según tu proyecto.\n· Largo, ancho y alto configurables.\n· Cálculos precisos con tus medidas exactas.\n· Ideal para proyectos especiales.',
      ),
    ];
  }
}