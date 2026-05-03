import 'package:fpdart/fpdart.dart';

import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/map/product.dart';
import '../../repositories/map/location_repository.dart';

/// Use case para obtener todos los productos de una ubicación
class GetLocationProducts implements UseCase<List<Product>, String> {
  final LocationRepository repository;

  GetLocationProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(String locationId) async {
    return await repository.getLocationProducts(locationId);
  }
}
