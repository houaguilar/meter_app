

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/repositories/projects/metrados/result/result_local_repository.dart';

import '../../../../../config/constants/error/failures.dart';
import '../../../../../domain/datasources/projects/metrados/result/result_local_data_source.dart';

class ResultLocalRepositoryImpl implements ResultLocalRepository {
  final ResultLocalDataSource dataSource;

  ResultLocalRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> saveResults(List<dynamic> results, String metradoId) async {
    try {
      await dataSource.saveResults(results, metradoId);
      return right(null);
    } catch (e) {
      return left(Failure(message: 'Error al guardar el resultado'));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> loadResults(String metradoId) async {
    try {
      final results = await dataSource.loadResults(metradoId);
      return right(results);
    } catch (e) {
      return left(Failure(message: 'Error al cargar los resultados'));
    }
  }
}