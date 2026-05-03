import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/map/product.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';

/// Use case para guardar un producto (insert o update)
class SaveProduct implements UseCase<Product, Product> {
  final LocationRepository repository;

  SaveProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.saveProduct(product);
  }
}
