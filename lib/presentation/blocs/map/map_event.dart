part of 'map_bloc.dart';

@immutable
sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class AddMarkerEvent extends MapEvent {
  final MapMarker marker;

  const AddMarkerEvent(this.marker);

  @override
  List<Object> get props => [marker];
}

class LoadMarkersEvent extends MapEvent {}