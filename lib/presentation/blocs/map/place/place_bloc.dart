import 'dart:async';

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

  // Cache para evitar llamadas innecesarias
  final Map<String, List<PlaceEntity>> _suggestionsCache = {};
  final Map<String, PlaceEntity> _detailsCache = {};

  // Control de rate limiting
  Timer? _rateLimitTimer;
  String? _lastQuery;
  DateTime? _lastRequestTime;

  // Configuración de optimización
  static const Duration _rateLimitDuration = Duration(milliseconds: 300);
  static const Duration _cacheValidDuration = Duration(minutes: 10);
  static const int _maxCacheSize = 50;

  PlaceBloc({
    required this.getPlaceSuggestions,
    required this.getPlaceDetails,
  }) : super(OptimizedPlaceInitial()) {

    on<FetchOptimizedPlaceSuggestions>(_onFetchSuggestions);
    on<SelectOptimizedPlace>(_onSelectPlace);
    on<ClearOptimizedPlaceCache>(_onClearCache);
    on<_RateLimitedSearch>(_onRateLimitedSearch);
  }

  @override
  Future<void> close() {
    _rateLimitTimer?.cancel();
    _suggestionsCache.clear();
    _detailsCache.clear();
    return super.close();
  }

  void _onFetchSuggestions(
      FetchOptimizedPlaceSuggestions event,
      Emitter<PlaceState> emit,
      ) {
    // Evitar búsquedas duplicadas
    if (event.query == _lastQuery) {
      return;
    }

    // Cancelar timer anterior si existe
    _rateLimitTimer?.cancel();

    // Verificar si hay resultados en cache
    final cachedResults = _getCachedSuggestions(event.query);
    if (cachedResults != null) {
      emit(OptimizedPlaceSuggestionsLoaded(cachedResults, fromCache: true));
      return;
    }

    // Rate limiting: evitar demasiadas llamadas muy seguidas
    final now = DateTime.now();
    if (_lastRequestTime != null &&
        now.difference(_lastRequestTime!) < _rateLimitDuration) {

      // Programar búsqueda con delay
      _rateLimitTimer = Timer(_rateLimitDuration, () {
        add(_RateLimitedSearch(event.query));
      });
      return;
    }

    // Realizar búsqueda inmediata
    add(_RateLimitedSearch(event.query));
  }

  Future<void> _onRateLimitedSearch(
      _RateLimitedSearch event,
      Emitter<PlaceState> emit,
      ) async {
    final query = event.query;

    // Actualizar estado de carga solo si es necesario
    if (state is! OptimizedPlaceLoading) {
      emit(OptimizedPlaceLoading());
    }

    _lastQuery = query;
    _lastRequestTime = DateTime.now();

    try {
      final result = await getPlaceSuggestions(query);

      await result.fold(
            (failure) async {
          emit(OptimizedPlaceError(
            "Error al buscar lugares: ${failure.message}",
            canRetry: true,
          ));
        },
            (suggestions) async {
          // Guardar en cache
          _cacheSuggestions(query, suggestions);

          emit(OptimizedPlaceSuggestionsLoaded(suggestions, fromCache: false));
        },
      );
    } catch (e) {
      emit(OptimizedPlaceError(
        "Error inesperado: $e",
        canRetry: true,
      ));
    }
  }

  Future<void> _onSelectPlace(
      SelectOptimizedPlace event,
      Emitter<PlaceState> emit,
      ) async {
    // Verificar cache de detalles
    final cachedPlace = _getCachedPlaceDetails(event.placeId);
    if (cachedPlace != null) {
      emit(OptimizedPlaceSelected(cachedPlace, fromCache: true));
      return;
    }

    emit(OptimizedPlaceLoading());

    try {
      final result = await getPlaceDetails(event.placeId);

      await result.fold(
            (failure) async {
          emit(OptimizedPlaceError(
            "Error al obtener detalles del lugar: ${failure.message}",
            canRetry: true,
          ));
        },
            (place) async {
          // Guardar en cache
          _cachePlaceDetails(event.placeId, place);

          emit(OptimizedPlaceSelected(place, fromCache: false));
        },
      );
    } catch (e) {
      emit(OptimizedPlaceError(
        "Error inesperado: $e",
        canRetry: true,
      ));
    }
  }

  void _onClearCache(
      ClearOptimizedPlaceCache event,
      Emitter<PlaceState> emit,
      ) {
    _suggestionsCache.clear();
    _detailsCache.clear();
    emit(OptimizedPlaceInitial());
  }

  // Métodos de cache

  List<PlaceEntity>? _getCachedSuggestions(String query) {
    // Buscar coincidencia exacta primero
    if (_suggestionsCache.containsKey(query)) {
      return _suggestionsCache[query];
    }

    // Buscar coincidencias parciales para queries más largos
    if (query.length > 3) {
      for (final cachedQuery in _suggestionsCache.keys) {
        if (query.toLowerCase().startsWith(cachedQuery.toLowerCase()) &&
            cachedQuery.length >= 3) {
          return _suggestionsCache[cachedQuery];
        }
      }
    }

    return null;
  }

  void _cacheSuggestions(String query, List<PlaceEntity> suggestions) {
    // Limpiar cache si está muy lleno
    if (_suggestionsCache.length >= _maxCacheSize) {
      _cleanOldCacheEntries();
    }

    _suggestionsCache[query] = suggestions;
  }

  PlaceEntity? _getCachedPlaceDetails(String placeId) {
    return _detailsCache[placeId];
  }

  void _cachePlaceDetails(String placeId, PlaceEntity place) {
    if (_detailsCache.length >= _maxCacheSize) {
      _cleanOldCacheEntries();
    }

    _detailsCache[placeId] = place;
  }

  void _cleanOldCacheEntries() {
    // Simplificado: eliminar la mitad de las entradas más antiguas
    final suggestionsKeys = _suggestionsCache.keys.toList();
    final detailsKeys = _detailsCache.keys.toList();

    if (suggestionsKeys.length > _maxCacheSize ~/ 2) {
      final keysToRemove = suggestionsKeys.take(suggestionsKeys.length ~/ 2);
      for (final key in keysToRemove) {
        _suggestionsCache.remove(key);
      }
    }

    if (detailsKeys.length > _maxCacheSize ~/ 2) {
      final keysToRemove = detailsKeys.take(detailsKeys.length ~/ 2);
      for (final key in keysToRemove) {
        _detailsCache.remove(key);
      }
    }
  }

  // Métodos de utilidad para debugging y monitoreo

  int get sugestionsCacheSize => _suggestionsCache.length;
  int get detailsCacheSize => _detailsCache.length;

  void logCacheStats() {
    print('PlaceBloc Cache Stats:');
    print('  Suggestions cache: ${_suggestionsCache.length} entries');
    print('  Details cache: ${_detailsCache.length} entries');
    print('  Last query: $_lastQuery');
    print('  Last request time: $_lastRequestTime');
  }
}