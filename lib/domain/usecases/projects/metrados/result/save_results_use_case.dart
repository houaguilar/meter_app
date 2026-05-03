

import 'package:fpdart/fpdart.dart';

import '../../../../../core/constants/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';
import '../../../../repositories/projects/metrados/result/result_local_repository.dart';

class SaveResultsUseCase implements UseCase<void, SaveResultParams> {
  final ResultLocalRepository repository;

  SaveResultsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(SaveResultParams params) async {
    return await repository.saveResults(params.results, params.metradoId);
  }
}

class SaveResultParams {
  final List<dynamic> results;
  final String metradoId;

  SaveResultParams({required this.results, required this.metradoId});
}