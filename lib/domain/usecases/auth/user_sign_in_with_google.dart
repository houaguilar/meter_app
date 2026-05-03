
import 'package:fpdart/fpdart.dart';
import '../../../core/constants/error/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/auth/user.dart';
import '../../repositories/auth/auth_repository.dart';

class UserSignInWithGoogle implements UseCase<User, NoParams> {
  final AuthRepository authRepository;

  UserSignInWithGoogle(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.signInWithGoogle();
  }
}
