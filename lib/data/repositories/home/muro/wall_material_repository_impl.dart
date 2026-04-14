

import '../../../../domain/entities/home/muro/wall_material.dart';
import '../../../../domain/repositories/home/muro/wall_material_repository.dart';
import 'package:meter_app/config/assets/app_images.dart';

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
        image: AppImages.panderetaImg,
        size: '23cm x 11cm x 9cm',
        lengthBrick: 23,
        widthBrick: 11,
        heightBrick: 9,
        details: '· Ladrillo para muros no portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 23×12×9 cm.\n· Rendimiento: 44 u/m² en soga.',
      ),

      // KING KONG
      WallMaterial(
        id: '3',
        name: 'King Kong 18H',
        image: AppImages.kingkongImg,
        size: '23cm x 12.5cm x 9cm',
        lengthBrick: 23,
        widthBrick: 12.5,
        heightBrick: 9,
        details: '· Ladrillo resistente para muros portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 24×13×9 cm.\n· Rendimiento: 47 u/m² en soga.',
      ),

      // TABICÓN
      WallMaterial(
        id: '5',
        name: 'Tabicón',
        image: AppImages.tabiconImg,
        size: '25cm x 8cm x 15cm',
        lengthBrick: 25,
        widthBrick: 8,
        heightBrick: 15,
        details: '· Bloque hueco para tabiquería.\n· Excelente aislamiento térmico.\n· Dimensiones: 20×20×15 cm.\n· Instalación rápida y eficiente.',
      ),

      // LADRILLO PERSONALIZADO
      WallMaterial(
        id: 'custom',
        name: 'Ladrillo Personalizado',
        image: AppImages.personalizadoImg,
        size: 'Configurable',
        lengthBrick: null, // Se configurará dinámicamente
        widthBrick: null, // Se configurará dinámicamente
        heightBrick: null, // Se configurará dinámicamente
        details: '· Personaliza las dimensiones según tu proyecto.\n· Largo, ancho y alto configurables.\n· Cálculos precisos con tus medidas exactas.\n· Ideal para proyectos especiales.',
      ),
    ];
  }
}