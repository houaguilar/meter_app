
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meter_app/data/repositories/home/piso/floor_repository_impl.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/domain/repositories/home/piso/floor_repository.dart';
import 'package:meter_app/domain/usecases/home/piso/get_floors_usecase.dart';

final floorRepositoryProvider = Provider<FloorRepository>((ref) {
  return FloorRepositoryImpl();
});

final getFloorsUseCaseProvider = Provider<GetFloorsUsecase>((ref) {
  final repository = ref.read(floorRepositoryProvider);
  return GetFloorsUsecase(repository);
});

final floorsProvider = FutureProvider<List<Floor>>((ref) async {
  final useCase = ref.read(getFloorsUseCaseProvider);
  return await useCase();
});

final selectedFloorProvider = StateProvider<Floor?>((ref) => null);
