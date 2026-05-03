import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/projects/metrado/metrado.dart';
import 'package:meter_app/domain/repositories/projects/metrados/metrados_local_repository.dart';

class EditMetrado implements UseCase<void, EditMetradoParams> {
  final MetradosLocalRepository repository;

  const EditMetrado(this.repository);

  @override
  Future<Either<Failure, void>> call(EditMetradoParams params) async {
    return await repository.updateMetrado(params.metrado);
  }
}

class EditMetradoParams {
  final Metrado metrado;

  EditMetradoParams({required this.metrado});
}