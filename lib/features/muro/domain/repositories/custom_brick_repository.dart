

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/domain/entities/home/muro/custom_brick.dart';

abstract interface class CustomBrickRepository {
  Future<Either<Failure, List<CustomBrick>>> getAllCustomBricks();
  Future<Either<Failure, CustomBrick?>> getCustomBrickById(String customId);
  Future<Either<Failure, CustomBrick>> saveCustomBrick(CustomBrick brick);
  Future<Either<Failure, CustomBrick>> updateCustomBrick(CustomBrick brick);
  Future<Either<Failure, void>> deleteCustomBrick(String customId);
  Future<Either<Failure, void>> deleteAllCustomBricks();
  Future<Either<Failure, bool>> existsByName(String name, {String? excludeId});
}