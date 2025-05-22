import '../../../config/theme/theme.dart';
import '../../../domain/domain.dart';
import '../../../domain/repositories/home/home_list_repository.dart';

class HomeListRepositoryImpl implements HomeListRepository {

  @override
  List<HomeListItem> getHomeListItems() {

    return [
      HomeListItem(
        imageAsset: 'assets/images/muro.png',
        title: 'Muro',
        location: 'muro',
        bgColor: AppColors.silver,
      ),
     /* HomeListItem(
        imageAsset: 'assets/images/perfil.png',
        title: 'Columna',
        location: 'columna',
        bgColor: getRandomColor(),
      ),*/
      HomeListItem(
        imageAsset: 'assets/images/pisos.png',
        title: 'Piso',
        location: 'pisos',
        bgColor: AppColors.silver,
      ),
      HomeListItem(
        imageAsset: 'assets/images/tarrajeo.png',
        title: 'Losa',
        location: 'losas',
        bgColor: AppColors.silver,
      ),
    ];
  }
}