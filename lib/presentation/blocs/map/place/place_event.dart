part of 'place_bloc.dart';

@immutable
sealed class PlaceEvent {}

class FetchPlaceSuggestions extends PlaceEvent {
  final String query;
  FetchPlaceSuggestions(this.query);
}

class SelectPlace extends PlaceEvent {
  final String placeId;
  SelectPlace(this.placeId);
}