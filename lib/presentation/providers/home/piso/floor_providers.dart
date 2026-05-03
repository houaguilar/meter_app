
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/domain/repositories/home/piso/floor_repository.dart';
import 'package:meter_app/domain/usecases/home/piso/get_floors_usecase.dart';
import 'package:meter_app/init_dependencies.dart';

final floorRepositoryProvider = Provider<FloorRepository>((ref) {
  return serviceLocator<FloorRepository>();
});

final getFloorsUseCaseProvider = Provider<GetFloorsUsecase>((ref) {
  final repository = ref.read(floorRepositoryProvider);
  return GetFloorsUsecase(repository);
});

final floorsProvider = FutureProvider<List<Floor>>((ref) async {
  final useCase = ref.read(getFloorsUseCaseProvider);
  return await useCase();
});

final selectedFloorProvider = NotifierProvider<SelectedFloorNotifier, Floor?>(() => SelectedFloorNotifier());

class SelectedFloorNotifier extends Notifier<Floor?> {
  @override
  Floor? build() => null;

  void select(Floor? floor) => state = floor;
}
