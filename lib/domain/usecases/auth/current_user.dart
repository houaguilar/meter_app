
import 'package:fpdart/fpdart.dart';
import 'package:meter_app/config/constants/error/failures.dart';
import 'package:meter_app/config/usecase/usecase.dart';
import 'package:meter_app/domain/entities/auth/user.dart';
import 'package:meter_app/domain/repositories/auth/auth_repository.dart';

class CurrentUser implements UseCase<User, NoParams> {
  final AuthRepository authRepository;
  CurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}