import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';

class DeleteAccount implements UseCase<void, DeleteAccountParams> {
  final AuthRepository authRepository;

  const DeleteAccount(this.authRepository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) async {
    return await authRepository.deleteAccount(
      password: params.password,
    );
  }
}

class DeleteAccountParams {
  final String password;

  const DeleteAccountParams({
    required this.password,
  });
}
