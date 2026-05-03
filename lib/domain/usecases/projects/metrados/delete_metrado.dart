import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/projects/metrado/metrado.dart';
import 'package:meter_app/domain/repositories/projects/metrados/metrados_local_repository.dart';

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