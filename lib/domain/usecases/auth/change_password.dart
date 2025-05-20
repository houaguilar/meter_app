// domain/usecases/auth/change_password.dart
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/auth/auth_repository.dart';

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    // Validate passwords match
    if (params.newPassword != params.confirmPassword) {
      return left(Failure(message: 'Las contraseñas no coinciden'));
    }

    // Validate password strength
    if (!_isPasswordStrong(params.newPassword)) {
      return left(Failure(
          message:
          'La contraseña debe tener al menos 8 caracteres, una letra mayúscula, una minúscula y un número'));
    }

    return await repository.changePassword(
      params.currentPassword,
      params.newPassword,
    );
  }

  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}