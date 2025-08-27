
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/domain/repositories/home/tarrajeo/coating_repository.dart';
import 'package:meter_app/presentation/assets/images.dart';

class CoatingRepositoryImpl implements CoatingRepository {
  @override
  Future<List<Coating>> fetchCoatings() async {
    return [
      Coating(
          id: '1',
          name: 'Muro interiores',
          image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '2',
        name: 'Muro exteriores',
        image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '3',
        name: 'Cielorraso',
        image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '4',
        name: 'Derrames',
        image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '5',
        name: 'Columna',
        image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
      Coating(
        id: '6',
        name: 'Viga',
        image: AppImages.mezclaCementoImg,
        details: '· Adecuado para muros portantes y cercos perimetrados. \n· Absorción de agua 18%. \n· Modelo de 6 huecos. \n· Rendimiento 38 u/m2.',
      ),
    ];
  }
  
}