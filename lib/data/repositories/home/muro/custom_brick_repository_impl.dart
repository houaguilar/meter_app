import 'package:fpdart/fpdart.dart';
import '../../../../../config/constants/error/exceptions.dart';
import '../../../../../config/constants/error/failures.dart';
import '../../../../../domain/entities/home/muro/custom_brick.dart';
import '../../../../../domain/repositories/home/muro/custom_brick_repository.dart';
import '../../../../domain/datasources/home/muro/custom_brick_local_data_source.dart';

class CustomBrickRepositoryImpl implements CustomBrickRepository {
  final CustomBrickLocalDataSource _localDataSource;

  CustomBrickRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<CustomBrick>>> getAllCustomBricks() async {
    try {
      final bricks = await _localDataSource.getAllCustomBricks();
      return right(bricks);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message:'Error inesperado al cargar ladrillos personalizados'));
    }
  }

  @override
  Future<Either<Failure, CustomBrick?>> getCustomBrickById(String customId) async {
    try {
      final brick = await _localDataSource.getCustomBrickById(customId);
      return right(brick);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al buscar ladrillo personalizado'));
    }
  }

  @override
  Future<Either<Failure, CustomBrick>> saveCustomBrick(CustomBrick brick) async {
    try {
      final savedBrick = await _localDataSource.saveCustomBrick(brick);
      return right(savedBrick);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al guardar ladrillo personalizado'));
    }
  }

  @override
  Future<Either<Failure, CustomBrick>> updateCustomBrick(CustomBrick brick) async {
    try {
      final updatedBrick = await _localDataSource.updateCustomBrick(brick);
      return right(updatedBrick);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al actualizar ladrillo personalizado'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomBrick(String customId) async {
    try {
      await _localDataSource.deleteCustomBrick(customId);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al eliminar ladrillo personalizado'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllCustomBricks() async {
    try {
      await _localDataSource.deleteAllCustomBricks();
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al eliminar todos los ladrillos personalizados'));
    }
  }

  @override
  Future<Either<Failure, bool>> existsByName(String name, {String? excludeId}) async {
    try {
      final exists = await _localDataSource.existsByName(name, excludeId: excludeId);
      return right(exists);
    } on ServerException catch (e) {
      return left(Failure(message: e.message));
    } catch (e) {
      return left(Failure(message: 'Error inesperado al verificar nombre'));
    }
  }
}