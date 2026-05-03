// lib/domain/usecases/home/muro/save_custom_brick.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/home/muro/custom_brick.dart';
import 'package:meter_app/features/muro/domain/repositories/custom_brick_repository.dart';

class SaveCustomBrick implements UseCase<CustomBrick, SaveCustomBrickParams> {
  final CustomBrickRepository _repository;

  SaveCustomBrick(this._repository);

  @override
  Future<Either<Failure, CustomBrick>> call(SaveCustomBrickParams params) {
    return _repository.saveCustomBrick(params.brick);
  }
}

class SaveCustomBrickParams {
  final CustomBrick brick;

  SaveCustomBrickParams({required this.brick});
}

