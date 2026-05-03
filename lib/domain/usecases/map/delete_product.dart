import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/repositories/map/location_repository.dart';

/// Use case para eliminar un producto
class DeleteProduct implements UseCase<void, String> {
  final LocationRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, void>> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
