
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/domain/repositories/home/losa/slab_repository.dart';

import '../../../../presentation/assets/images.dart';

class SlabRepositoryImpl implements SlabRepository {
  @override
  Future<List<Slab>> fetchSlabs() async {
    return [
      Slab(
        id: '1',
        name: 'Losa aligerada tradicional',
        image: AppImages.pisoCardImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Slab(
        id: '1',
        name: 'Losa aligerada con viguetas prefabricadas',
        image: AppImages.pisoCardImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Slab(
        id: '1',
        name: 'Losa maciza',
        image: AppImages.pisoCardImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
    ];
  }

}