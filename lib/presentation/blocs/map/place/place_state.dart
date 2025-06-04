part of 'place_bloc.dart';

@immutable
sealed class PlaceState {}

final class OptimizedPlaceInitial extends PlaceState {
  @override
  String toString() => 'OptimizedPlaceInitial()';
}

class OptimizedPlaceLoading extends PlaceState {
  @override
  String toString() => 'OptimizedPlaceLoading()';
}

class OptimizedPlaceSuggestionsLoaded extends PlaceState {
  final List<PlaceEntity> suggestions;
  final bool fromCache;

  OptimizedPlaceSuggestionsLoaded(this.suggestions, {this.fromCache = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OptimizedPlaceSuggestionsLoaded &&
              runtimeType == other.runtimeType &&
              suggestions == other.suggestions &&
              fromCache == other.fromCache;

  @override
  int get hashCode => suggestions.hashCode ^ fromCache.hashCode;

  @override
  String toString() =>
      'OptimizedPlaceSuggestionsLoaded(suggestions: ${suggestions.length}, fromCache: $fromCache)';
}

class OptimizedPlaceSelected extends PlaceState {
  final PlaceEntity place;
  final bool fromCache;

  OptimizedPlaceSelected(this.place, {this.fromCache = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OptimizedPlaceSelected &&
              runtimeType == other.runtimeType &&
              place == other.place &&
              fromCache == other.fromCache;

  @override
  int get hashCode => place.hashCode ^ fromCache.hashCode;

  @override
  String toString() =>
      'OptimizedPlaceSelected(place: ${place.description}, fromCache: $fromCache)';
}

class OptimizedPlaceError extends PlaceState {
  final String message;
  final bool canRetry;

  OptimizedPlaceError(this.message, {this.canRetry = true});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OptimizedPlaceError &&
              runtimeType == other.runtimeType &&
              message == other.message &&
              canRetry == other.canRetry;

  @override
  int get hashCode => message.hashCode ^ canRetry.hashCode;

  @override
  String toString() =>
      'OptimizedPlaceError(message: $message, canRetry: $canRetry)';
}