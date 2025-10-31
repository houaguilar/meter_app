import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/map/location_repository.dart';

/// Parámetros para cambiar disponibilidad de stock
class ToggleProductStockParams {
  final String productId;
  final bool available;

  ToggleProductStockParams({
    required this.productId,
    required this.available,
  });
}

/// Use case para cambiar disponibilidad de stock de un producto
class ToggleProductStock implements UseCase<void, ToggleProductStockParams> {
  final LocationRepository repository;

  ToggleProductStock(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleProductStockParams params) async {
    return await repository.toggleProductStock(
      productId: params.productId,
      available: params.available,
    );
  }
}
