import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../config/usecase/usecase.dart';
import '../../../entities/projects/metrado/metrado.dart';
import '../../../repositories/projects/metrados/metrados_local_repository.dart';

class DeleteMetrado implements UseCase<void, DeleteMetradoParams> {
  final MetradosLocalRepository repository;

  const DeleteMetrado(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMetradoParams params) async {
    return await repository.deleteMetrado(params.metrado);
  }
}

class DeleteMetradoParams {
  final Metrado metrado;

  DeleteMetradoParams({required this.metrado});
}