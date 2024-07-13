import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/usecases/map/save_location.dart';
import '../../../domain/usecases/map/get_all_locations.dart';

part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final GetAllLocations getAllLocations;
  final SaveLocation saveLocation;

  LocationsBloc({
    required this.getAllLocations,
    required this.saveLocation,
  }) : super(LocationsLoading()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddNewLocation>(_onAddNewLocation);
  }

  void _onLoadLocations(
      LoadLocations event, Emitter<LocationsState> emit) async {
    emit(LocationsLoading());
    final result = await getAllLocations(NoParams());
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (locations) => emit(LocationsLoaded(locations)),
    );
  }

  void _onAddNewLocation(
      AddNewLocation event, Emitter<LocationsState> emit) async {
    emit(LocationsLoading());
    final result = await saveLocation(event.location);
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (_) => add(LoadLocations()),
    );
  }
}
