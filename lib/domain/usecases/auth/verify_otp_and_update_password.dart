import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/auth/auth_repository.dart';

class VerifyOTPAndUpdatePassword implements UseCase<void, VerifyOTPAndUpdatePasswordParams> {
  final AuthRepository repository;

  VerifyOTPAndUpdatePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyOTPAndUpdatePasswordParams params) async {
    // Validar el OTP (6 dígitos)
    if (!_isValidOTP(params.token)) {
      return left(Failure(message: 'El código debe tener 6 dígitos'));
    }

    // Validar el email
    if (!_isValidEmail(params.email)) {
      return left(Failure(message: 'Email inválido'));
    }

    // Validar la contraseña (mínimo 6 caracteres)
    if (!_isValidPassword(params.newPassword)) {
      return left(Failure(message: 'La contraseña debe tener al menos 6 caracteres'));
    }

    return await repository.verifyOTPAndUpdatePassword(
      email: params.email,
      token: params.token,
      newPassword: params.newPassword,
    );
  }

  bool _isValidOTP(String token) {
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(token);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}

class VerifyOTPAndUpdatePasswordParams {
  final String email;
  final String token;
  final String newPassword;

  VerifyOTPAndUpdatePasswordParams({
    required this.email,
    required this.token,
    required this.newPassword,
  });
}
