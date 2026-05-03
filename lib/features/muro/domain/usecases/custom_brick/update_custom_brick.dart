// lib/domain/usecases/home/muro/update_custom_brick.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/home/muro/custom_brick.dart';
import 'package:meter_app/features/muro/domain/repositories/custom_brick_repository.dart';


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

