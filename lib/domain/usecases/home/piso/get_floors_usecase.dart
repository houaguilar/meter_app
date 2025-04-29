
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/domain/repositories/home/piso/floor_repository.dart';

class GetFloorsUsecase {
  final FloorRepository repository;

  GetFloorsUsecase(this.repository);

  Future<List<Floor>> call() async {
    return await repository.fetchFloors();
  }
}