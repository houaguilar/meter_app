

import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/projects/domain/repositories/metrados/result/result_local_repository.dart';

class LoadResultsUseCase implements UseCase<List<dynamic>, LoadResultsParams> {
  final ResultLocalRepository repository;

  LoadResultsUseCase(this.repository);

  @override
  Future<Either<Failure, List<dynamic>>> call(LoadResultsParams params) async {
    return await repository.loadResults(params.metradoId);
  }
}

class LoadResultsParams {
  final String metradoId;

  LoadResultsParams({required this.metradoId});
}