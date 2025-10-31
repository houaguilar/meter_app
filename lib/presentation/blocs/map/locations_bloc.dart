import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../../config/usecase/usecase.dart';
import '../../../domain/entities/map/location.dart';
import '../../../domain/entities/map/location_with_distance.dart';
import '../../../domain/usecases/map/check_postgis_availability.dart';
import '../../../domain/usecases/map/delete_location.dart';
import '../../../domain/usecases/map/get_locations_by_user.dart';
import '../../../domain/usecases/map/get_nearby_locations.dart';
import '../../../domain/usecases/map/save_location.dart';
import '../../../domain/usecases/map/get_all_locations.dart';
import '../../../domain/usecases/map/toggle_location_active.dart';
import '../../../domain/usecases/map/upload_image.dart';

part 'locations_event.dart';
part 'locations_state.dart';

class LocationsBloc extends Bloc<LocationsEvent, LocationsState> {
  final GetAllLocations getAllLocations;
  final SaveLocation saveLocation;
  final UploadImage uploadImage;

  final GetNearbyLocations getNearbyLocations;
  final CheckPostGISAvailability checkPostGISAvailabilityUseCase;
  final GetLocationsByUser getLocationsByUser;
  final DeleteLocation deleteLocationUseCase;
  final ToggleLocationActive toggleLocationActiveUseCase;

  LocationsBloc({
    required this.getAllLocations,
    required this.saveLocation,
    required this.uploadImage,
    required this.getNearbyLocations,
    required this.checkPostGISAvailabilityUseCase,
    required this.getLocationsByUser,
    required this.deleteLocationUseCase,
    required this.toggleLocationActiveUseCase,
  }) : super(LocationsLoading()) {
    on<LoadLocations>(_onLoadLocations);
    on<AddNewLocation>(_onAddNewLocation);
    on<UploadImageEvent>(_onUploadImage);
    on<LoadNearbyLocations>(_onLoadNearbyLocations);
    on<RefreshNearbyLocations>(_onRefreshNearbyLocations);
    on<CheckPostGISAvailabilityEvent>(_onCheckPostGISAvailability);
    on<LoadLocationsByUser>(_onLoadLocationsByUser);
    on<DeleteLocationEvent>(_onDeleteLocation);
    on<ToggleLocationActiveEvent>(_onToggleLocationActive);
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
    emit(LocationsSaving());
    final result = await saveLocation(event.location);
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (_) => emit(LocationSaved()),
    );
  }

  void _onUploadImage(
      UploadImageEvent event, Emitter<LocationsState> emit) async {
    emit(ImageUploading());
    final result = await uploadImage(event.image);
    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (imageUrl) => emit(ImageUploaded(imageUrl)),
    );
  }

  void _onLoadNearbyLocations(
      LoadNearbyLocations event, Emitter<LocationsState> emit) async {
    emit(NearbyLocationsLoading());

    final params = GetNearbyLocationsParams(
      userLat: event.userLat,
      userLng: event.userLng,
      radiusKm: event.radiusKm,
      maxResults: event.maxResults,
    );

    final result = await getNearbyLocations(params);

    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (nearbyLocations) {
        if (nearbyLocations.isEmpty) {
          emit(NearbyLocationsEmpty(
            userLat: event.userLat,
            userLng: event.userLng,
            radiusKm: event.radiusKm,
          ));
        } else {
          // Determinar si se está usando PostGIS (si tiene distancia calculada)
          final usingPostGIS = nearbyLocations.isNotEmpty &&
              nearbyLocations.first.distanceKm != null;

          emit(NearbyLocationsLoaded(
            nearbyLocations: nearbyLocations,
            userLat: event.userLat,
            userLng: event.userLng,
            radiusKm: event.radiusKm,
            usingPostGIS: usingPostGIS,
          ));
        }
      },
    );
  }

  /// Handler para refrescar ubicaciones cercanas
  void _onRefreshNearbyLocations(
      RefreshNearbyLocations event, Emitter<LocationsState> emit) async {

    // Mantener ubicaciones previas durante la recarga
    List<LocationWithDistance>? previousLocations;
    if (state is NearbyLocationsLoaded) {
      previousLocations = (state as NearbyLocationsLoaded).nearbyLocations;
    }

    emit(LocationsRefreshing(previousNearbyLocations: previousLocations));

    final params = GetNearbyLocationsParams(
      userLat: event.userLat,
      userLng: event.userLng,
      radiusKm: event.radiusKm,
      maxResults: 15,
    );

    final result = await getNearbyLocations(params);

    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (nearbyLocations) {
        if (nearbyLocations.isEmpty) {
          emit(NearbyLocationsEmpty(
            userLat: event.userLat,
            userLng: event.userLng,
            radiusKm: event.radiusKm,
          ));
        } else {
          final usingPostGIS = nearbyLocations.isNotEmpty &&
              nearbyLocations.first.distanceKm != null;

          emit(NearbyLocationsLoaded(
            nearbyLocations: nearbyLocations,
            userLat: event.userLat,
            userLng: event.userLng,
            radiusKm: event.radiusKm,
            usingPostGIS: usingPostGIS,
          ));
        }
      },
    );
  }

  /// Handler para verificar disponibilidad de PostGIS
  void _onCheckPostGISAvailability(
      CheckPostGISAvailabilityEvent event, Emitter<LocationsState> emit) async {
    emit(PostGISChecking());

    final result = await checkPostGISAvailabilityUseCase(NoParams());

    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (isAvailable) => emit(PostGISAvailable(isAvailable)),
    );
  }

  /// Handler para cargar ubicaciones por usuario
  void _onLoadLocationsByUser(
      LoadLocationsByUser event, Emitter<LocationsState> emit) async {
    emit(UserLocationsLoading());

    final result = await getLocationsByUser(event.userId);

    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (userLocations) => emit(UserLocationsLoaded(
        userLocations: userLocations,
        userId: event.userId,
      )),
    );
  }

  /// Handler para eliminar ubicación
  void _onDeleteLocation(
      DeleteLocationEvent event, Emitter<LocationsState> emit) async {
    emit(LocationDeleting());

    final result = await deleteLocationUseCase(event.locationId);

    result.fold(
          (failure) => emit(LocationsError(failure.message)),
          (_) {
        emit(LocationDeleted(event.locationId));

        // Mostrar mensaje de éxito temporal
        emit(LocationOperationSuccess(
          message: 'Ubicación eliminada correctamente',
        ));
      },
    );
  }

  /// Handler para activar/desactivar ubicación
  void _onToggleLocationActive(
      ToggleLocationActiveEvent event, Emitter<LocationsState> emit) async {
    debugPrint('🔔 LocationsBloc: Recibido ToggleLocationActiveEvent');
    debugPrint('   locationId: ${event.locationId}');
    debugPrint('   isActive: ${event.isActive}');

    emit(LocationTogglingActive());

    debugPrint('📞 LocationsBloc: Llamando a toggleLocationActiveUseCase...');
    final result = await toggleLocationActiveUseCase(
      locationId: event.locationId,
      isActive: event.isActive,
    );

    result.fold(
          (failure) {
        debugPrint('❌ LocationsBloc: Error - ${failure.message}');
        emit(LocationsError(failure.message));
      },
          (_) {
        debugPrint('✅ LocationsBloc: Toggle exitoso!');
        emit(LocationActiveToggled(
          locationId: event.locationId,
          isActive: event.isActive,
        ));

        // Mostrar mensaje de éxito temporal
        emit(LocationOperationSuccess(
          message: event.isActive
              ? 'Negocio activado correctamente'
              : 'Negocio desactivado correctamente',
        ));
      },
    );
  }

  // ============================================================
  // MÉTODOS AUXILIARES PÚBLICOS
  // ============================================================

  /// Verificar si el estado actual tiene ubicaciones cercanas
  bool get hasNearbyLocations => state is NearbyLocationsLoaded;

  /// Obtener ubicaciones cercanas actuales
  List<LocationWithDistance> get currentNearbyLocations {
    if (state is NearbyLocationsLoaded) {
      return (state as NearbyLocationsLoaded).nearbyLocations;
    }
    return [];
  }

  /// Verificar si está usando PostGIS
  bool get isUsingPostGIS {
    if (state is NearbyLocationsLoaded) {
      return (state as NearbyLocationsLoaded).usingPostGIS;
    }
    return false;
  }

  /// Obtener información de la ubicación actual del usuario
  Map<String, double>? get currentUserLocation {
    if (state is NearbyLocationsLoaded) {
      final nearbyState = state as NearbyLocationsLoaded;
      return {
        'lat': nearbyState.userLat,
        'lng': nearbyState.userLng,
        'radius': nearbyState.radiusKm,
      };
    }
    return null;
  }
}
