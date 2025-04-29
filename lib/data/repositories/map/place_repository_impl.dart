
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/domain/datasources/map/place_remote_data_source.dart';
import 'package:meter_app/domain/entities/map/place_entity.dart';
import 'package:meter_app/domain/repositories/map/place_repository.dart';

class PlaceRepositoryImpl implements PlaceRepository {
  final PlaceRemoteDataSource remoteDataSource;

  PlaceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<PlaceEntity>>> getPlaceSuggestions(String input) async {
    try {
      final suggestions = await remoteDataSource.getPlaceSuggestions(input);
      return Right(suggestions);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaceEntity>> getPlaceDetails(String placeId) async {
    try {
      final place = await remoteDataSource.getPlaceDetails(placeId);
      return Right(place);
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
