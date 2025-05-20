


import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/presentation/assets/images.dart';

import '../../../../domain/repositories/home/inicio/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {

  @override
  Future<List<Measurement>> getMeasurementItems() async {
    return [
      Measurement(
        imageAsset: AppImages.muroImg,
        title: 'Muro',
        description: 'Realiza la medición para un muro en el espacio que requieras.',
        location: 'muro',
      ),
      Measurement(
        imageAsset: AppImages.tarrajeoImg,
        title: 'Tarrajeo',
        description: 'Valida la cantidad de material que necesitas para esta labor.',
        location: 'tarrajeo',
      ),
      Measurement(
        imageAsset: AppImages.pisosImg,
        title: 'Piso',
        description: 'Ingresa la medida de tu espacio y valida la cantidad de producto.',
        location: 'pisos',
      ),
      Measurement(
        imageAsset: AppImages.concretoImg,
        title: 'Losas \naligeradas',
        description: 'Ingresa los datos y revisa los resultados para las losas.',
        location: 'losas',
      ),
      Measurement(
        imageAsset: AppImages.concretoImg,
        title: 'Elementos \nestructurales',
        description: 'Ingresa los datos y revisa los resultados para los elementos estructurales.',
        location: 'structural-elements',
      ),
    ];
  }
}