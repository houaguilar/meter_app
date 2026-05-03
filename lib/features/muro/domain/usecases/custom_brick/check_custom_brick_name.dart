// lib/domain/usecases/home/muro/check_custom_brick_name.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/muro/domain/repositories/custom_brick_repository.dart';

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