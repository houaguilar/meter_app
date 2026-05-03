// lib/domain/usecases/home/muro/delete_custom_brick.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/muro/domain/repositories/custom_brick_repository.dart';

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
