
import 'package:meter_app/domain/entities/home/losas/slab.dart';

import 'package:meter_app/features/losas/domain/repositories/slab_repository.dart';

class GetSlabsUseCase {
  final SlabRepository repository;

  GetSlabsUseCase(this.repository);

  Future<List<Slab>> call() async {
    return await repository.fetchSlabs();
  }
}