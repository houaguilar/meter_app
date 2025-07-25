// lib/domain/usecases/home/muro/check_custom_brick_name.dart
import 'package:fpdart/fpdart.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../config/usecase/usecase.dart';
import '../../../../repositories/home/muro/custom_brick_repository.dart';

class CheckCustomBrickName implements UseCase<bool, CheckCustomBrickNameParams> {
  final CustomBrickRepository _repository;

  CheckCustomBrickName(this._repository);

  @override
  Future<Either<Failure, bool>> call(CheckCustomBrickNameParams params) {
    return _repository.existsByName(params.name, excludeId: params.excludeId);
  }
}

class CheckCustomBrickNameParams {
  final String name;
  final String? excludeId;

  CheckCustomBrickNameParams({required this.name, this.excludeId});
}