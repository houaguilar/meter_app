
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/data/repositories/home/tarrajeo/coating_repository_impl.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/domain/repositories/home/tarrajeo/coating_repository.dart';
import 'package:meter_app/domain/usecases/home/tarrajeo/get_coatings_usecase.dart';

final coatingRepositoryProvider = Provider<CoatingRepository>((ref) {
  return CoatingRepositoryImpl();
});

final getCoatingsUseCaseProvider = Provider<GetCoatingsUseCase>((ref) {
  final repository = ref.read(coatingRepositoryProvider);
  return GetCoatingsUseCase(repository);
});

final coatingsProvider = FutureProvider<List<Coating>>((ref) async {
  final useCase = ref.read(getCoatingsUseCaseProvider);
  return await useCase();
});

final selectedCoatingProvider = StateProvider<Coating?>((ref) => null);
