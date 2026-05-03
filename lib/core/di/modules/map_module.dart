import 'package:get_it/get_it.dart';
import 'package:meter_app/core/constants/secrets/app_secrets.dart';
import 'package:meter_app/features/mapa/data/datasources/location_data_source_impl.dart';
import 'package:meter_app/features/mapa/data/datasources/place_remote_data_source_impl.dart';
import 'package:meter_app/features/mapa/data/repositories/location_repository_impl.dart';
import 'package:meter_app/features/mapa/data/repositories/place_repository_impl.dart';
import 'package:meter_app/features/mapa/domain/datasources/location_data_source.dart';
import 'package:meter_app/features/mapa/domain/datasources/place_remote_data_source.dart';
import 'package:meter_app/features/mapa/domain/repositories/location_repository.dart';
import 'package:meter_app/features/mapa/domain/repositories/place_repository.dart';
import 'package:meter_app/features/mapa/domain/usecases/check_postgis_availability.dart';
import 'package:meter_app/features/mapa/domain/usecases/delete_location.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_all_locations.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_locations_by_user.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_nearby_locations.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_place_details.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_place_suggestions.dart';
import 'package:meter_app/features/mapa/domain/usecases/save_location.dart';
import 'package:meter_app/features/mapa/domain/usecases/toggle_location_active.dart';
import 'package:meter_app/features/mapa/domain/usecases/upload_image.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_location_products.dart';
import 'package:meter_app/features/mapa/domain/usecases/save_product.dart';
import 'package:meter_app/features/mapa/domain/usecases/delete_product.dart';
import 'package:meter_app/features/mapa/domain/usecases/toggle_product_stock.dart';
import 'package:meter_app/features/mapa/domain/usecases/get_products_by_category.dart';
import 'package:meter_app/features/mapa/presentation/blocs/locations_bloc.dart';
import 'package:meter_app/features/mapa/presentation/blocs/place/place_bloc.dart';
import 'package:meter_app/features/mapa/presentation/blocs/products_bloc.dart';
import 'package:meter_app/features/cart/presentation/blocs/cart_bloc.dart';

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
  sl.registerFactory(() => ToggleLocationActive(sl()));

  // ==================== USE CASES - Places ====================
  sl.registerFactory(() => GetPlaceSuggestions(sl()));
  sl.registerFactory(() => GetPlaceDetails(sl()));

  // ==================== USE CASES - Products ====================
  sl.registerFactory(() => GetLocationProducts(sl()));
  sl.registerFactory(() => SaveProduct(sl()));
  sl.registerFactory(() => DeleteProduct(sl()));
  sl.registerFactory(() => ToggleProductStock(sl()));
  sl.registerFactory(() => GetProductsByCategory(sl()));

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
      toggleLocationActiveUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PlaceBloc(
      getPlaceSuggestions: sl(),
      getPlaceDetails: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ProductsBloc(
      getLocationProducts: sl(),
      getProductsByCategory: sl(),
      saveProduct: sl(),
      deleteProduct: sl(),
      toggleProductStock: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => CartBloc(),
  );
}
