import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../../domain/repositories/auth/auth_repository.dart';

class GetProfileImage implements UseCase<String, String> {
  final AuthRepository repository;

  GetProfileImage(this.repository);

  @override
  Future<Either<Failure, String>> call(String userId) async {
  //  final result = await repository.getUserProfile(userId);
    final result = await repository.getUserProfile();

    return result.map((profile) => profile.profileImageUrl ?? '');
  }
}
