import 'package:fpdart/fpdart.dart';
import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/auth/user.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';

class UserSignInWithApple implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  UserSignInWithApple(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.signInWithApple();
  }
}
