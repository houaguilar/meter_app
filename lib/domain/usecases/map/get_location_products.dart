import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/map/product.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';

/// Use case para obtener todos los productos de una ubicación
class GetLocationProducts implements UseCase<List<Product>, String> {
  final LocationRepository repository;

  GetLocationProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(String locationId) async {
    return await repository.getLocationProducts(locationId);
  }
}
