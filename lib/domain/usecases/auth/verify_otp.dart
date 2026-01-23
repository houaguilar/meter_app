// domain/usecases/auth/verify_otp.dart
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/auth/auth_repository.dart';

class VerifyOTP implements UseCase<void, VerifyOTPParams> {
  final AuthRepository repository;

  VerifyOTP(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyOTPParams params) async {
    // Validate OTP token (should be 6 digits)
    if (!_isValidOTP(params.token)) {
      return left(Failure(message: 'El código debe tener 6 dígitos'));
    }

    // Validate email format
    if (!_isValidEmail(params.email)) {
      return left(Failure(message: 'Email inválido'));
    }

    return await repository.verifyOTP(
      email: params.email,
      token: params.token,
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
}

class VerifyOTPParams {
  final String email;
  final String token;

  VerifyOTPParams({
    required this.email,
    required this.token,
  });
}
