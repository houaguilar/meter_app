part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class AuthSignUp extends AuthEvent {
  final String email;
  final String password;
  final String name;

  AuthSignUp({
    required this.email,
    required this.password,
    required this.name,
  });
}

final class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  AuthLogin({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

final class AuthCheckEmailVerified extends AuthEvent {}

final class AuthResendEmailVerification extends AuthEvent {}


final class AuthIsUserLoggedIn extends AuthEvent {}

final class AuthLogout extends AuthEvent {}

final class AuthLoginWithGoogle extends AuthEvent {}

final class AuthDeleteAccount extends AuthEvent {
  final String password;

  AuthDeleteAccount({
    required this.password,
  });
}
