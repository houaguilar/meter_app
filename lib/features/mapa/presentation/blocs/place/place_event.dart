part of 'place_bloc.dart';

@immutable
sealed class PlaceEvent {}

class FetchOptimizedPlaceSuggestions extends PlaceEvent {
  final String query;

  FetchOptimizedPlaceSuggestions(this.query);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FetchOptimizedPlaceSuggestions &&
              runtimeType == other.runtimeType &&
              query == other.query;

  @override
  int get hashCode => query.hashCode;

  @override
  String toString() => 'FetchOptimizedPlaceSuggestions(query: $query)';
}

class SelectOptimizedPlace extends PlaceEvent {
  final String placeId;

  SelectOptimizedPlace(this.placeId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SelectOptimizedPlace &&
              runtimeType == other.runtimeType &&
              placeId == other.placeId;

  @override
  int get hashCode => placeId.hashCode;

  @override
  String toString() => 'SelectOptimizedPlace(placeId: $placeId)';
}

class ClearOptimizedPlaceCache extends PlaceEvent {
  @override
  String toString() => 'ClearOptimizedPlaceCache()';
}

// Evento interno para rate limiting
class _RateLimitedSearch extends PlaceEvent {
  final String query;

  _RateLimitedSearch(this.query);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is _RateLimitedSearch &&
              runtimeType == other.runtimeType &&
              query == other.query;

  @override
  int get hashCode => query.hashCode;

  @override
  String toString() => '_RateLimitedSearch(query: $query)';
}