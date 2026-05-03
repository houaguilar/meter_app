import 'package:fpdart/fpdart.dart';

import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/map/location_repository.dart';

/// Use case para eliminar un producto
class DeleteProduct implements UseCase<void, String> {
  final LocationRepository repository;

  DeleteProduct(this.repository);

  @override
  Future<Either<Failure, void>> call(String productId) async {
    return await repository.deleteProduct(productId);
  }
}
