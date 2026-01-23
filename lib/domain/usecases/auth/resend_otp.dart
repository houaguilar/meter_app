// domain/usecases/auth/resend_otp.dart
import 'package:fpdart/fpdart.dart';

import '../../../config/constants/error/failures.dart';
import '../../../config/usecase/usecase.dart';
import '../../repositories/auth/auth_repository.dart';

class ResendOTP implements UseCase<void, ResendOTPParams> {
  final AuthRepository repository;

  ResendOTP(this.repository);

  @override
  Future<Either<Failure, void>> call(ResendOTPParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return left(Failure(message: 'Email inválido'));
    }

    return await repository.resendOTP(params.email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

class ResendOTPParams {
  final String email;

  ResendOTPParams({required this.email});
}
