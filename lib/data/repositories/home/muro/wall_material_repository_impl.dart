
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/domain/repositories/home/muro/wall_material_repository.dart';
import 'package:meter_app/presentation/assets/images.dart';

class WallMaterialRepositoryImpl implements WallMaterialRepository {
  @override
  Future<List<WallMaterial>> fetchWallMaterials() async {
    return [
      // ✅ PANDERETA 1 - Corregido según Excel (23×12×9 cm)
      WallMaterial(
        id: '1',
        name: 'Pandereta 1',
        image: AppImages.panderetaFirstImg,
        size: '23cm x 12cm x 9cm', // ✅ Dimensiones CORRECTAS del Excel
        lengthBrick: 23, // ✅ Corregido
        widthBrick: 12,  // ✅ Corregido
        heightBrick: 9,  // ✅ Corregido
        details: '· Ladrillo hueco para muros no portantes.\n· Absorción de agua 18%.\n· Dimensiones: 23×12×9 cm.\n· Rendimiento: 39 u/m² en soga.',
      ),

      // ✅ PANDERETA 2 - Manteniendo como Pandereta (mismo tipo)
      WallMaterial(
        id: '2',
        name: 'Pandereta 2',
        image: AppImages.pandereta2Img,
        size: '23cm x 12cm x 9cm', // ✅ Mismo que Pandereta estándar
        lengthBrick: 23, // ✅ Agregado para consistencia
        widthBrick: 12,  // ✅ Agregado para consistencia
        heightBrick: 9,  // ✅ Agregado para consistencia
        details: '· Ladrillo hueco para muros no portantes.\n· Absorción de agua 18%.\n· Dimensiones: 23×12×9 cm.\n· Rendimiento: 39 u/m² en soga.',
      ),

      // ✅ KING KONG 1 - Corregido según Excel (24×13×9 cm)
      WallMaterial(
        id: '3',
        name: 'King Kong 1',  // ✅ Nombre claro y consistente
        image: AppImages.kingkong1Img,
        size: '24cm x 13cm x 9cm', // ✅ Dimensiones CORRECTAS del Excel
        lengthBrick: 24, // ✅ Corregido
        widthBrick: 13,  // ✅ Corregido
        heightBrick: 9,  // ✅ Corregido
        details: '· Ladrillo resistente para muros portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 24×13×9 cm.\n· Rendimiento: 47 u/m² en soga.',
      ),

      // ✅ KING KONG 2 - Mismo tipo, diferentes características
      WallMaterial(
        id: '4',
        name: 'King Kong 2',  // ✅ Nombre consistente
        image: AppImages.kingkong2Img,
        size: '24cm x 13cm x 9cm', // ✅ Dimensiones CORRECTAS del Excel
        lengthBrick: 24, // ✅ Corregido
        widthBrick: 13,  // ✅ Corregido
        heightBrick: 9,  // ✅ Corregido
        details: '· Ladrillo resistente para muros portantes.\n· Absorción de agua máx. 22%.\n· Dimensiones: 24×13×9 cm.\n· Rendimiento: 47 u/m² en soga.',
      ),

      WallMaterial(
        id: 'custom',
        name: 'Ladrillo Personalizado',
        image: AppImages.tabiconImg, // Necesitarás agregar esta imagen
        size: 'Configurable',
        lengthBrick: null, // Se configurará dinámicamente
        widthBrick: null,
        heightBrick: null,
        details: '· Personaliza las dimensiones según tu proyecto.\n· Largo, ancho y alto configurables.\n· Cálculos precisos con tus medidas exactas.\n· Ideal para proyectos especiales.',
      ),
    ];
  }
}