import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../../domain/repositories/auth/auth_repository.dart';

class UpdateProfileImage implements UseCase<String, UpdateProfileImageParams> {
  final AuthRepository repository;

  UpdateProfileImage(this.repository);

  @override
  Future<Either<Failure, String>> call(UpdateProfileImageParams params) async {
    return await repository.uploadProfileImage(params.userId, params.filePath);
  }
}

class UpdateProfileImageParams {
  final String userId;
  final String filePath;

  UpdateProfileImageParams({required this.userId, required this.filePath});
}