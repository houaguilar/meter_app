import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';

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
