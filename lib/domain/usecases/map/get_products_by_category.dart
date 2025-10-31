import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/product.dart';
import '../../repositories/map/location_repository.dart';

/// Parámetros para obtener productos por categoría
class GetProductsByCategoryParams {
  final String locationId;
  final String categoryId;

  GetProductsByCategoryParams({
    required this.locationId,
    required this.categoryId,
  });
}

/// Use case para obtener productos por categoría específica
class GetProductsByCategory
    implements UseCase<List<Product>, GetProductsByCategoryParams> {
  final LocationRepository repository;

  GetProductsByCategory(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(
      GetProductsByCategoryParams params) async {
    return await repository.getProductsByCategory(
      locationId: params.locationId,
      categoryId: params.categoryId,
    );
  }
}
