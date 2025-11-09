
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/domain/repositories/home/losa/slab_repository.dart';

import '../../../../presentation/assets/images.dart';

class SlabRepositoryImpl implements SlabRepository {
  @override
  Future<List<Slab>> fetchSlabs() async {
    return [
      Slab(
        id: '1',
        name: 'Losa aligerada con viguetas prefabricadas',
        image: AppImages.pisoCardImg,
        details: '· Sistema prefabricado con bovedillas. \n· Mayor rapidez de construcción. \n· 6.33 bovedillas por m². \n· Alturas: 17, 20, 25 cm.',
      ),
      Slab(
        id: '2',
        name: 'Losa aligerada tradicional',
        image: AppImages.pisoCardImg,
        details: '· Con ladrillos huecos o casetón. \n· Sistema tradicional más económico. \n· 11.11 ladrillos huecos/m² o 2.78 casetón/m². \n· Alturas: 17, 20, 25 cm.',
      ),
      Slab(
        id: '3',
        name: 'Losa maciza',
        image: AppImages.pisoCardImg,
        details: '· Concreto sólido sin aligerante. \n· Mayor capacidad de carga. \n· Para luces grandes o cargas pesadas. \n· Alturas: 15, 20, 25 cm.',
      ),
    ];
  }

}