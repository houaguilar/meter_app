


import 'package:meter_app/config/assets/app_icons.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/config/assets/app_images.dart';

import '../../../../domain/repositories/home/inicio/measurement_repository.dart';

class MeasurementRepositoryImpl implements MeasurementRepository {

  @override
  Future<List<Measurement>> getMeasurementItems() async {
    return [
      Measurement(
        imageAsset: AppIcons.muroIcon,
        title: 'Muro',
        description: 'Realiza la medición para un muro en el espacio que requieras.',
        location: 'muro',
      ),
      Measurement(
        imageAsset: AppIcons.tarrajeoIcon,
        title: 'Tarrajeo',
        description: 'Valida la cantidad de material que necesitas para esta labor.',
        location: 'tarrajeo',
      ),
      Measurement(
        imageAsset: AppIcons.pisoIcon,
        title: 'Piso',
        description: 'Ingresa la medida de tu espacio y valida la cantidad de producto.',
        location: 'pisos',
      ),
      Measurement(
        imageAsset: AppIcons.losaIcon,
        title: 'Losas de entrepiso',
        description: 'Ingresa los datos y revisa los resultados para las losas.',
        location: 'losas',
      ),
      Measurement(
        imageAsset: AppIcons.concretoIcon,
        title: 'Concreto',
        description: 'Ingresa los datos y revisa los resultados para los elementos estructurales.',
        location: 'structural-elements',
      ),
      Measurement(
        imageAsset: AppIcons.aceroIcon,
        title: 'Acero',
        description: 'Ingresa los datos y revisa los resultados para los elementos estructurales.',
        location: 'steel',
      ),
    ];
  }
}