import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:meter_app/domain/entities/auth/user.dart';

import '../../../core/common/cubits/app_user/app_user_cubit.dart';
import '../../../core/usecase/usecase.dart';
import '../../../core/local/shared_preferences_helper.dart';
import '../../../domain/usecases/use_cases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final UserSignInWithGoogle _userSignInWithGoogle;
  final UserSignInWithApple _userSignInWithApple;
  final DeleteAccount _deleteAccount;
  final ChangePassword _changePassword;
  final ResendOTP _resendOTP;
  final ResetPasswordForEmail _resetPasswordForEmail;
  final AppUserCubit _appUserCubit;
  final SharedPreferencesHelper _sharedPrefs;

  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required UserLogout userLogout,
    required UserSignInWithGoogle userSignInWithGoogle,
    required UserSignInWithApple userSignInWithApple,
    required DeleteAccount deleteAccount,
    required ChangePassword changePassword,
    required ResendOTP resendOTP,
    required ResetPasswordForEmail resetPasswordForEmail,
    required AppUserCubit appUserCubit,
    required SharedPreferencesHelper sharedPrefs,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _userLogout = userLogout,
        _userSignInWithGoogle = userSignInWithGoogle,
        _userSignInWithApple = userSignInWithApple,
        _deleteAccount = deleteAccount,
        _changePassword = changePassword,
        _resendOTP = resendOTP,
        _resetPasswordForEmail = resetPasswordForEmail,
        _appUserCubit = appUserCubit,
        _sharedPrefs = sharedPrefs,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthLoginWithGoogle>(_onAuthLoginWithGoogle);
    on<AuthLoginWithApple>(_onAuthLoginWithApple);
    on<AuthDeleteAccount>(_onAuthDeleteAccount);
    on<AuthChangePassword>(_onAuthChangePassword);
    on<AuthResendOTP>(_onAuthResendOTP);
    on<AuthResetPasswordForEmail>(_onAuthResetPasswordForEmail);
    on<AuthCancelEmailVerification>(_onAuthCancelEmailVerification);
  }

  void _isUserLoggedIn(
      AuthIsUserLoggedIn event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _currentUser(NoParams());

    res.fold(
      (l) {
        // Si hay un email de verificación pendiente, mantener ese estado
        // independientemente del tipo de error. Esto cubre el caso donde el
        // intercambio PKCE falla (enlace de verificación inválido) y evita mostrar
        // "error inesperado" cuando el usuario aún necesita confirmar su correo.
        final pendingEmail = _sharedPrefs.getPendingVerificationEmail();
        if (pendingEmail != null) {
          emit(AuthPendingEmailVerification(pendingEmail));
        } else if (l.message.contains('User not logged in')) {
          _appUserCubit.clearUser();
          emit(AuthInitial());
        } else {
          emit(AuthFailure(l.message));
        }
      },
      (r) {
        // Sesión activa y verificada: limpiar cualquier pendiente previo
        _sharedPrefs.clearPendingVerificationEmail();
        _emitAuthSuccess(r, emit);
      },
    );
  }

  void _onAuthSignUp(
      AuthSignUp event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _userSignUp(
      UserSignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) {},
    );

    if (res.isLeft()) return;

    // Supabase no crea sesión activa hasta que el email sea confirmado (PKCE).
    // Guardar el email y mostrar la pantalla de verificación.
    // IMPORTANTE: NO llamar a _userLogout aquí porque eliminaría el code_verifier
    // de PKCE que Supabase guardó localmente, rompiendo el intercambio al hacer
    // clic en el enlace de verificación.
    await _sharedPrefs.savePendingVerificationEmail(event.email);
    emit(AuthPendingEmailVerification(event.email));
  }

  void _onAuthLoginWithApple(
      AuthLoginWithApple event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final res = await _userSignInWithApple(NoParams());

    res.fold(
      (failure) {
        final errorMessage = failure.message.toLowerCase();
        final isCancellation = errorMessage.contains('canceló') ||
            errorMessage.contains('canceled') ||
            errorMessage.contains('cancelled');

        if (isCancellation) {
          emit(AuthInitial());
        } else {
          emit(AuthFailure(failure.message));
        }
      },
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLoginWithGoogle(
      AuthLoginWithGoogle event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final res = await _userSignInWithGoogle(NoParams());

    res.fold(
          (failure) {
        // Detectar cancelación del usuario
        final errorMessage = failure.message.toLowerCase();
        final isCancellation = errorMessage.contains('canceló') ||
            errorMessage.contains('canceled') ||
            errorMessage.contains('cancelled') ||
            errorMessage.contains('sign_in_canceled');

        if (isCancellation) {
          // Si el usuario canceló, volver al estado inicial sin mostrar error
          emit(AuthInitial());
        } else {
          // Para otros errores, emitir el fallo normalmente
          emit(AuthFailure(failure.message));
        }
      },
          (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(
      AuthLogin event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _userLogin(
      UserLoginParams(
        email: event.email,
        password: event.password,
      ),
    );

    res.fold(
          (l) => emit(AuthFailure(l.message)),
          (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthLogout(
      AuthLogout event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _userLogout(NoParams());

    res.fold(
          (l) => emit(AuthFailure(l.message)),
          (_) {
        _appUserCubit.clearUser();
        emit(AuthInitial());
      },
    );
  }

  void _emitAuthSuccess(
      User user,
      Emitter<AuthState> emit,
      ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }

  void _onAuthDeleteAccount(
      AuthDeleteAccount event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthDeletingAccount());
    final res = await _deleteAccount(
      DeleteAccountParams(password: event.password),
    );

    res.fold(
          (l) => emit(AuthFailure(l.message)),
          (_) {
        _appUserCubit.clearUser();
        emit(AuthAccountDeleted());
      },
    );
  }

  Future<void> _onAuthChangePassword(
      AuthChangePassword event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _changePassword(ChangePasswordParams(
      currentPassword: '',
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    ));

    await res.fold(
      (failure) async => emit(AuthFailure(failure.message)),
      (_) async {
        await _userLogout(NoParams());
        _appUserCubit.clearUser();
        emit(const AuthPasswordChanged());
      },
    );
  }

  Future<void> _onAuthResendOTP(
      AuthResendOTP event,
      Emitter<AuthState> emit,
      ) async {
    final res = await _resendOTP(ResendOTPParams(email: event.email));

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthOTPResent()),
    );
  }

  Future<void> _onAuthResetPasswordForEmail(
      AuthResetPasswordForEmail event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final res = await _resetPasswordForEmail(ResetPasswordParams(email: event.email));

    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthPasswordResetEmailSent(event.email)),
    );
  }

  Future<void> _onAuthCancelEmailVerification(
      AuthCancelEmailVerification event,
      Emitter<AuthState> emit,
      ) async {
    await _sharedPrefs.clearPendingVerificationEmail();
    _appUserCubit.clearUser();
    emit(AuthInitial());
  }
}