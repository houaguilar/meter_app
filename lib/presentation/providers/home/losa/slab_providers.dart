
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/data/repositories/home/losa/slab_repository_impl.dart';
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/domain/repositories/home/losa/slab_repository.dart';
import 'package:meter_app/domain/usecases/home/losa/get_slabs_usecase.dart';

final slabRepositoryProvider = Provider<SlabRepository>((ref) {
  return SlabRepositoryImpl();
});

final getSlabsUseCaseProvider = Provider<GetSlabsUseCase>((ref) {
  final repository = ref.read(slabRepositoryProvider);
  return GetSlabsUseCase(repository);
});

final slabProvider = FutureProvider<List<Slab>>((ref) async {
  final useCase = ref.read(getSlabsUseCaseProvider);
  return await useCase();
});

final selectedSlabProvider = StateProvider<Slab?>((ref) => null);
