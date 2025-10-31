import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/map/product.dart';
import '../../repositories/map/location_repository.dart';

/// Use case para guardar un producto (insert o update)
class SaveProduct implements UseCase<Product, Product> {
  final LocationRepository repository;

  SaveProduct(this.repository);

  @override
  Future<Either<Failure, Product>> call(Product product) async {
    return await repository.saveProduct(product);
  }
}
