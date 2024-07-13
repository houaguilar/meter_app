import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../domain/entities/map/map_marker.dart';
import '../../../domain/usecases/use_cases.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final AddMarkerUseCase addMarkerUseCase;
  final GetMarkersUseCase getMarkersUseCase;

  MapBloc({
    required this.addMarkerUseCase,
    required this.getMarkersUseCase,
  }) : super(MapInitial()) {
    on<AddMarkerEvent>(_onAddMarker);
    on<LoadMarkersEvent>(_onLoadMarkers);
  }

  void _onAddMarker(AddMarkerEvent event, Emitter<MapState> emit) async {
    emit(MapLoading());
    await addMarkerUseCase(event.marker);
    add(LoadMarkersEvent());
  }

  void _onLoadMarkers(LoadMarkersEvent event, Emitter<MapState> emit) async {
    emit(MapLoading());
    final markers = await getMarkersUseCase();
    emit(MapLoaded(markers));
  }
}
