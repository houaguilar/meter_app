

import 'package:meter_app/domain/domain.dart';

abstract class HomeListRepository {
  List<HomeListItem> getHomeListItems();
}