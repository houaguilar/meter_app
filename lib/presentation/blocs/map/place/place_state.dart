part of 'place_bloc.dart';

@immutable
sealed class PlaceState {}

final class PlaceInitial extends PlaceState {}

class PlaceLoading extends PlaceState {}

class PlaceSuggestionsLoaded extends PlaceState {
  final List<PlaceEntity> suggestions;
  PlaceSuggestionsLoaded(this.suggestions);
}

class PlaceSelected extends PlaceState {
  final PlaceEntity place;
  PlaceSelected(this.place);
}

class PlaceError extends PlaceState {
  final String message;
  PlaceError(this.message);
}