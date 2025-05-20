
import 'package:meter_app/domain/entities/home/losas/slab.dart';

import '../../../repositories/home/losa/slab_repository.dart';

class GetSlabsUseCase {
  final SlabRepository repository;

  GetSlabsUseCase(this.repository);

  Future<List<Slab>> call() async {
    return await repository.fetchSlabs();
  }
}