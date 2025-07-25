// lib/domain/usecases/home/muro/delete_custom_brick.dart
import 'package:fpdart/fpdart.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../config/usecase/usecase.dart';
import '../../../../repositories/home/muro/custom_brick_repository.dart';

class DeleteCustomBrick implements UseCase<void, DeleteCustomBrickParams> {
  final CustomBrickRepository _repository;

  DeleteCustomBrick(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteCustomBrickParams params) {
    return _repository.deleteCustomBrick(params.customId);
  }
}

class DeleteCustomBrickParams {
  final String customId;

  DeleteCustomBrickParams({required this.customId});
}
