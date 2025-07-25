// lib/domain/usecases/home/muro/get_all_custom_bricks.dart
import 'package:fpdart/fpdart.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../config/usecase/usecase.dart';
import '../../../../entities/home/muro/custom_brick.dart';
import '../../../../repositories/home/muro/custom_brick_repository.dart';

class GetAllCustomBricks implements UseCase<List<CustomBrick>, NoParams> {
  final CustomBrickRepository _repository;

  GetAllCustomBricks(this._repository);

  @override
  Future<Either<Failure, List<CustomBrick>>> call(NoParams params) {
    return _repository.getAllCustomBricks();
  }
}

