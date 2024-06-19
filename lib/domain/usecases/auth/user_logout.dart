

import 'package:fpdart/src/either.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/usecase/usecase.dart';

import '../../repositories/auth/auth_repository.dart';

class UserLogout implements UseCase<void, NoParams> {
  final AuthRepository authRepository;
  UserLogout(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await authRepository.logout();
  }


}

