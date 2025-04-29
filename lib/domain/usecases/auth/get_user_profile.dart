import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/auth/user_profile.dart';
import '../../repositories/auth/auth_repository.dart';

class GetUserProfile implements UseCase<UserProfile, NoParams> {
  final AuthRepository authRepository;

  GetUserProfile(this.authRepository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await authRepository.getUserProfile();
  }
}