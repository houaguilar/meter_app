// lib/domain/usecases/home/muro/get_all_custom_bricks.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/home/muro/custom_brick.dart';
import 'package:meter_app/features/muro/domain/repositories/custom_brick_repository.dart';

class GetAllCustomBricks implements UseCase<List<CustomBrick>, NoParams> {
  final CustomBrickRepository _repository;

  GetAllCustomBricks(this._repository);

  @override
  Future<Either<Failure, List<CustomBrick>>> call(NoParams params) {
    return _repository.getAllCustomBricks();
  }
}

