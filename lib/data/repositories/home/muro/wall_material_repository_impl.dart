
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/domain/repositories/home/muro/wall_material_repository.dart';
import 'package:meter_app/presentation/assets/images.dart';

class WallMaterialRepositoryImpl implements WallMaterialRepository {
  @override
  Future<List<WallMaterial>> fetchWallMaterials() async {
    return [
      WallMaterial(
        id: '1',
        name: 'Pandereta',
        image: AppImages.panderetaFirstImg,
        size: '9cm x 12cm x 24cm',
        lengthBrick: 9,
        widthBrick: 12,
        heightBrick: 24,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '2',
        name: 'Pandereta 2',
        image: AppImages.pandereta2Img,
        size: '18.5cm x 10cm x 35cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '3',
        name: 'King Kong 18H',
        image: AppImages.kingkong1Img,
        size: '9cm x 12.5cm x 23cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '4',
        name: 'King Kong 30%',
        image: AppImages.kingkong2Img,
        size: '9cm x 13cm x 24cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '5',
        name: 'Tabicón',
        image: AppImages.tabiconImg,
        size: '8cm x 15cm x 25cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '6',
        name: 'Bloque de P14',
        image: AppImages.bloquetap14Img,
        size: '9cm x 19cm x 39cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '7',
        name: 'Bloque de P10',
        image: AppImages.bloquetap10Img,
        size: '12cm x 19cm x 39cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      WallMaterial(
        id: '8',
        name: 'Bloque de P7',
        image: AppImages.bloquetap7Img,
        size: '14cm x 19cm x 37cm',
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
    ];
  }
}