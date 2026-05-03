// domain/usecases/auth/reset_password_for_email.dart
import 'package:fpdart/fpdart.dart';

import 'package:meter_app/core/constants/error/failures.dart';
import 'package:meter_app/core/usecase/usecase.dart';
import 'package:meter_app/features/auth/domain/repositories/auth_repository.dart';

class ResetPasswordForEmail implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;

  ResetPasswordForEmail(this.repository);

  @override
  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return left(Failure(message: 'Email inválido'));
    }

    return await repository.resetPasswordForEmail(params.email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

class ResetPasswordParams {
  final String email;

  ResetPasswordParams({required this.email});
}
