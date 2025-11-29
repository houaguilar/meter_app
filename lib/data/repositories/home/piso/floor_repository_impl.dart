
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/domain/repositories/home/piso/floor_repository.dart';

import 'package:meter_app/config/assets/app_images.dart';

class FloorRepositoryImpl implements FloorRepository {
  @override
  Future<List<Floor>> fetchFloors() async {
    return [
      Floor(
        id: '1',
        name: 'Falso piso',
        image: AppImages.pisoCardImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Floor(
        id: '2',
        name: 'Contrapiso',
        image: AppImages.pisoCardImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
    ];
  }

}