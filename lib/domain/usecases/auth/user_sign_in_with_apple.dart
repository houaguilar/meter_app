import 'package:fpdart/fpdart.dart';
import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/auth/user.dart';
import '../../repositories/auth/auth_repository.dart';

class UserSignInWithApple implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  UserSignInWithApple(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.signInWithApple();
  }
}
