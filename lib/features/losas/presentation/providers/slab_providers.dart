
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/features/losas/domain/repositories/slab_repository.dart';
import 'package:meter_app/features/losas/domain/usecases/get_slabs_usecase.dart';
import 'package:meter_app/init_dependencies.dart';

final slabRepositoryProvider = Provider<SlabRepository>((ref) {
  return serviceLocator<SlabRepository>();
});

final getSlabsUseCaseProvider = Provider<GetSlabsUseCase>((ref) {
  final repository = ref.read(slabRepositoryProvider);
  return GetSlabsUseCase(repository);
});

final slabProvider = FutureProvider<List<Slab>>((ref) async {
  final useCase = ref.read(getSlabsUseCaseProvider);
  return await useCase();
});

final selectedSlabProvider = NotifierProvider<SelectedSlabNotifier, Slab?>(() => SelectedSlabNotifier());

class SelectedSlabNotifier extends Notifier<Slab?> {
  @override
  Slab? build() => null;

  void select(Slab? slab) => state = slab;
}
