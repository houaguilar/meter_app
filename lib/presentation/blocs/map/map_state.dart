part of 'map_bloc.dart';

@immutable
sealed class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}

final class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final List<MapMarker> markers;

  const MapLoaded(this.markers);

  @override
  List<Object> get props => [markers];
}

class MapError extends MapState {
  final String message;

  const MapError(this.message);

  @override
  List<Object> get props => [message];
}