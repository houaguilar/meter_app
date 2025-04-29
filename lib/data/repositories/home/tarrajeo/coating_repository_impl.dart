
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/domain/repositories/home/tarrajeo/coating_repository.dart';
import 'package:meter_app/presentation/assets/images.dart';

class CoatingRepositoryImpl implements CoatingRepository {
  @override
  Future<List<Coating>> fetchCoatings() async {
    return [
      Coating(
          id: '1',
          name: 'Tarrajeo normal',
          image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '2',
        name: 'Yeso',
        image: AppImages.yeseroImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
    ];
  }
  
}