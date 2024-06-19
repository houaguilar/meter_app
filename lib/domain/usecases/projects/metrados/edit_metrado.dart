import 'package:fpdart/fpdart.dart';

import '../../../../config/constants/error/failures.dart';
import '../../../../config/usecase/usecase.dart';
import '../../../entities/projects/metrado/metrado.dart';
import '../../../repositories/projects/metrados/metrados_local_repository.dart';

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