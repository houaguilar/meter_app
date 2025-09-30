

import 'package:fpdart/fpdart.dart';
import 'package:meter_app/domain/repositories/projects/metrados/result/result_local_repository.dart';

import '../../../../../config/constants/error/exceptions.dart';
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
    } on ServerException catch (e) {
      // ✅ FIX: Mapear ServerException correctamente
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } on Failure catch (f) {
      // ✅ FIX: Re-lanzar Failure tal como está
      return left(f);
    } catch (e) {
      // ✅ FIX: Manejo específico de errores desconocidos
      return left(Failure(
        message: 'Error inesperado al guardar resultados: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }

  @override
  Future<Either<Failure, List<dynamic>>> loadResults(String metradoId) async {
    try {
      final results = await dataSource.loadResults(metradoId);
      return right(results);
    } on ServerException catch (e) {
      return left(Failure(
        message: e.message,
        type: FailureType.general,
      ));
    } catch (e) {
      return left(Failure(
        message: 'Error inesperado al cargar resultados: ${e.toString()}',
        type: FailureType.unknown,
      ));
    }
  }
}