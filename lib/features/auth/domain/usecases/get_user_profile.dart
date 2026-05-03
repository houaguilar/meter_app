import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/domain/entities/auth/user_profile.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';

class GetUserProfile implements UseCase<UserProfile, NoParams> {
  final AuthRepository authRepository;

  GetUserProfile(this.authRepository);

  @override
  Future<Either<Failure, UserProfile>> call(NoParams params) async {
    return await authRepository.getUserProfile();
  }
}