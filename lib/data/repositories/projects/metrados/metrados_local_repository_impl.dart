

import 'package:fpdart/fpdart.dart';

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
    } catch (e) {
      return left(Failure(message: 'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, List<Metrado>>> getAllMetrados(int projectId) async {
    try {
      final metrados = await dataSource.loadMetrados(projectId);
      return right(metrados);
    } catch (e) {
      return left(Failure(message:'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMetrado(Metrado metrado) async {
    try {
      await dataSource.deleteMetrado(metrado);
      return right(null);
    } catch (e) {
      return left(Failure(message:'Error desconocido'));
    }
  }

  @override
  Future<Either<Failure, void>> updateMetrado(Metrado metrado) async{
    try {
      await dataSource.updateMetrado(metrado);
      return right(null);
    } catch (e) {
      return left(Failure(message:'Error desconocido'));
    }
  }

}