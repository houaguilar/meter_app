import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../domain/entities/map/place_entity.dart';
import '../../../../domain/usecases/map/get_place_details.dart';
import '../../../../domain/usecases/map/get_place_suggestions.dart';

part 'place_event.dart';
part 'place_state.dart';

class PlaceBloc extends Bloc<PlaceEvent, PlaceState> {
  final GetPlaceSuggestions getPlaceSuggestions;
  final GetPlaceDetails getPlaceDetails;

  PlaceBloc({
    required this.getPlaceSuggestions,
    required this.getPlaceDetails,
  }) : super(PlaceInitial()) {

    on<FetchPlaceSuggestions>((event, emit) async {
      emit(PlaceLoading());
      final failureOrSuggestions = await getPlaceSuggestions(event.query);
      failureOrSuggestions.fold(
            (failure) => emit(PlaceError("Failed to load suggestions")),
            (suggestions) => emit(PlaceSuggestionsLoaded(suggestions)),
      );
    });

    on<SelectPlace>((event, emit) async {
      emit(PlaceLoading());
      final failureOrPlace = await getPlaceDetails(event.placeId);
      failureOrPlace.fold(
            (failure) => emit(PlaceError("Failed to select place")),
            (place) => emit(PlaceSelected(place)),
      );
    });
  }
}
