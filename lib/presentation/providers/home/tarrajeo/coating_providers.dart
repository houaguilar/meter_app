
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/domain/repositories/home/tarrajeo/coating_repository.dart';
import 'package:meter_app/domain/usecases/home/tarrajeo/get_coatings_usecase.dart';
import 'package:meter_app/init_dependencies.dart';

final coatingRepositoryProvider = Provider<CoatingRepository>((ref) {
  return serviceLocator<CoatingRepository>();
});

final getCoatingsUseCaseProvider = Provider<GetCoatingsUseCase>((ref) {
  final repository = ref.read(coatingRepositoryProvider);
  return GetCoatingsUseCase(repository);
});

final coatingsProvider = FutureProvider<List<Coating>>((ref) async {
  final useCase = ref.read(getCoatingsUseCaseProvider);
  return await useCase();
});

final selectedCoatingProvider = NotifierProvider<SelectedCoatingNotifier, Coating?>(() => SelectedCoatingNotifier());

class SelectedCoatingNotifier extends Notifier<Coating?> {
  @override
  Coating? build() => null;

  void select(Coating? coating) => state = coating;
}
