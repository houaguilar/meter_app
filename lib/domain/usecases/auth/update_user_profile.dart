import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../entities/auth/user_profile.dart';
import '../../repositories/auth/auth_repository.dart';

class UpdateUserProfile implements UseCase<void, UpdateUserProfileParams> {
  final AuthRepository authRepository;

  UpdateUserProfile(this.authRepository);

  @override
  Future<Either<Failure, void>> call(UpdateUserProfileParams params) async {
    return await authRepository.updateUserProfile(params.profile);
  }
}

class UpdateUserProfileParams {
  final UserProfile profile;

  UpdateUserProfileParams({required this.profile});
}
