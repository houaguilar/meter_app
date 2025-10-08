import 'package:get_it/get_it.dart';
import 'package:meter_app/config/constants/secrets/app_secrets.dart';
import 'package:meter_app/data/datasources/map/location_data_source_impl.dart';
import 'package:meter_app/data/datasources/map/place_remote_data_source_impl.dart';
import 'package:meter_app/data/repositories/map/location_repository_impl.dart';
import 'package:meter_app/data/repositories/map/place_repository_impl.dart';
import 'package:meter_app/domain/datasources/map/location_data_source.dart';
import 'package:meter_app/domain/datasources/map/place_remote_data_source.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';
import 'package:meter_app/domain/repositories/map/place_repository.dart';
import 'package:meter_app/domain/usecases/map/check_postgis_availability.dart';
import 'package:meter_app/domain/usecases/map/delete_location.dart';
import 'package:meter_app/domain/usecases/map/get_all_locations.dart';
import 'package:meter_app/domain/usecases/map/get_locations_by_user.dart';
import 'package:meter_app/domain/usecases/map/get_nearby_locations.dart';
import 'package:meter_app/domain/usecases/map/get_place_details.dart';
import 'package:meter_app/domain/usecases/map/get_place_suggestions.dart';
import 'package:meter_app/domain/usecases/map/save_location.dart';
import 'package:meter_app/domain/usecases/map/upload_image.dart';
import 'package:meter_app/presentation/blocs/map/locations_bloc.dart';
import 'package:meter_app/presentation/blocs/map/place/place_bloc.dart';

/// Módulo de inyección de dependencias para mapas, ubicaciones y búsqueda de lugares
void registerMapModule(GetIt sl) {
  // ==================== DATASOURCES ====================
  sl.registerFactory<LocationDataSource>(
    () => LocationDataSourceImpl(sl()),
  );

  sl.registerFactory<PlaceRemoteDataSource>(
    () => PlaceRemoteDataSourceImpl(
      dio: sl(),
      apiKey: AppSecrets.googleApiKey,
    ),
  );

  // ==================== REPOSITORIES ====================
  sl.registerFactory<LocationRepository>(
    () => LocationRepositoryImpl(
      sl(), // LocationDataSource
      sl(), // ConnectionChecker
    ),
  );

  sl.registerFactory<PlaceRepository>(
    () => PlaceRepositoryImpl(sl()),
  );

  // ==================== USE CASES - Locations ====================
  sl.registerFactory(() => GetNearbyLocations(sl()));
  sl.registerFactory(() => CheckPostGISAvailability(sl()));
  sl.registerFactory(() => GetLocationsByUser(sl()));
  sl.registerFactory(() => DeleteLocation(sl()));
  sl.registerFactory(() => SaveLocation(sl()));
  sl.registerFactory(() => GetAllLocations(sl()));
  sl.registerFactory(() => UploadImage(sl()));

  // ==================== USE CASES - Places ====================
  sl.registerFactory(() => GetPlaceSuggestions(sl()));
  sl.registerFactory(() => GetPlaceDetails(sl()));

  // ==================== BLOCS ====================
  sl.registerLazySingleton(
    () => LocationsBloc(
      saveLocation: sl(),
      getAllLocations: sl(),
      uploadImage: sl(),
      getNearbyLocations: sl(),
      checkPostGISAvailabilityUseCase: sl(),
      getLocationsByUser: sl(),
      deleteLocationUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PlaceBloc(
      getPlaceSuggestions: sl(),
      getPlaceDetails: sl(),
    ),
  );
}
