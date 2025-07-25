// lib/domain/usecases/home/muro/update_custom_brick.dart
import 'package:fpdart/fpdart.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../config/usecase/usecase.dart';
import '../../../../entities/home/muro/custom_brick.dart';
import '../../../../repositories/home/muro/custom_brick_repository.dart';


class UpdateCustomBrick implements UseCase<CustomBrick, UpdateCustomBrickParams> {
  final CustomBrickRepository _repository;

  UpdateCustomBrick(this._repository);

  @override
  Future<Either<Failure, CustomBrick>> call(UpdateCustomBrickParams params) {
    return _repository.updateCustomBrick(params.brick);
  }
}

class UpdateCustomBrickParams {
  final CustomBrick brick;

  UpdateCustomBrickParams({required this.brick});
}

