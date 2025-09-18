import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/exceptions.dart';
import '../../../../config/constants/error/failures.dart';
import '../../../../domain/datasources/projects/metrados/metrados_local_data_source.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/repositories/projects/metrados/metrados_local_repository.dart';

class MetradosLocalRepositoryImpl implements MetradosLocalRepository {
  final MetradosLocalDataSource dataSource;

  MetradosLocalRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, int>> saveMetrado(String name, int projectId) async {
    try {
      final metradoId = await dataSource.saveMetrado(name, projectId);
      return right(metradoId);
    } on ServerException catch (e) {
      // MEJORADO: Mapear correctamente los tipos de errores
      if (e.message.contains('Ya existe un metrado')) {
        return left(Failure(
          message: e.message,
          type: FailureType.duplicateName,
        ));
      }
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } on Failure catch (f) {
      // Si ya es un Failure, devolverlo directamente
      return left(f);
    } catch (e) {
      return left(Failure(
        message: 'Error inesperado al crear el metrado',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, List<Metrado>>> getAllMetrados(int projectId) async {
    try {
      final metrados = await dataSource.loadMetrados(projectId);
      return right(metrados);
    } on ServerException catch (e) {
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } catch (e) {
      return left(Failure(
        message: 'Error inesperado al cargar los metrados',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMetrado(Metrado metrado) async {
    try {
      await dataSource.deleteMetrado(metrado);
      return right(null);
    } on ServerException catch (e) {
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } catch (e) {
      return left(Failure(
        message: 'Error inesperado al eliminar el metrado',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateMetrado(Metrado metrado) async {
    try {
      await dataSource.updateMetrado(metrado);
      return right(null);
    } on ServerException catch (e) {
      // MEJORADO: Mapear correctamente los errores de actualización
      if (e.message.contains('Ya existe un metrado')) {
        return left(Failure(
          message: e.message,
          type: FailureType.duplicateName,
        ));
      }
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } catch (e) {
      return left(Failure(
        message: 'Error inesperado al actualizar el metrado',
        type: FailureType.unknown,
      ));
    }
  }
}