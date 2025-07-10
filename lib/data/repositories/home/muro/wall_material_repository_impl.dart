
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

      // ✅ TABICÓN - No disponible pero con datos correctos
      WallMaterial(
        id: '5',
        name: 'Tabicón',
        image: AppImages.tabiconImg,
        size: '20cm x 15cm x 25cm', // Dimensiones típicas de tabicón
        lengthBrick: 25,
        widthBrick: 15,
        heightBrick: 20,
        details: '· Bloque hueco para muros divisorios.\n· Construcción rápida y eficiente.\n· Próximamente disponible en la app.\n· Contacta soporte para más información.',
      ),

      // ✅ BLOQUETAS - Mantener como están (no disponibles)
      WallMaterial(
        id: '6',
        name: 'Bloque de P14',
        image: AppImages.bloquetap14Img,
        size: '39cm x 19cm x 14cm', // Orden corregido: largo x ancho x alto
        lengthBrick: 39,
        widthBrick: 19,
        heightBrick: 14,
        details: '· Bloque de concreto para muros de carga.\n· Resistencia estructural alta.\n· Próximamente disponible en la app.\n· Contacta soporte para más información.',
      ),

      WallMaterial(
        id: '7',
        name: 'Bloque de P10',
        image: AppImages.bloquetap10Img,
        size: '39cm x 19cm x 10cm', // Orden corregido
        lengthBrick: 39,
        widthBrick: 19,
        heightBrick: 10,
        details: '· Bloque de concreto para muros medianos.\n· Balance entre resistencia y peso.\n· Próximamente disponible en la app.\n· Contacta soporte para más información.',
      ),

      WallMaterial(
        id: '8',
        name: 'Bloque de P7',
        image: AppImages.bloquetap7Img,
        size: '37cm x 19cm x 7cm', // Orden corregido
        lengthBrick: 37,
        widthBrick: 19,
        heightBrick: 7,
        details: '· Bloque de concreto liviano.\n· Para muros no estructurales.\n· Próximamente disponible en la app.\n· Contacta soporte para más información.',
      ),
    ];
  }
}