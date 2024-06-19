
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/domain.dart';
import '../../../domain/repositories/home/home_list_repository.dart';
import '../../../data/repositories/home/home_list_repository_impl.dart';

final homeListRepositoryProvider = Provider<HomeListRepository>((ref) {
  return HomeListRepositoryImpl();
});

final homeListItemsProvider = Provider<List<HomeListItem>>((ref) {
  return ref.read(homeListRepositoryProvider).getHomeListItems();
});