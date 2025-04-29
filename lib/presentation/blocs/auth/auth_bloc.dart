import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:meter_app/domain/entities/auth/user.dart';

import '../../../config/common/cubits/app_user/app_user_cubit.dart';
import '../../../config/usecase/usecase.dart';
import '../../../domain/usecases/use_cases.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogin;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final UserSignInWithGoogle _userSignInWithGoogle;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required UserLogout userLogout,
    required UserSignInWithGoogle userSignInWithGoogle,
    required AppUserCubit appUserCubit
  })  :_userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _userLogout = userLogout,
        _userSignInWithGoogle = userSignInWithGoogle,
      _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
    on<AuthLoginWithGoogle>(_onAuthLoginWithGoogle);
  }

  void _isUserLoggedIn(
      AuthIsUserLoggedIn event,
      Emitter<AuthState> emit,
      ) async {
    final res = await _currentUser(NoParams());

    res.fold(
          (l) => emit(AuthFailure(l.message)),
          (r) => _emitAuthSuccess(r, emit),
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
          (failure) => emit(AuthFailure(failure.message)),
          (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(
      AuthLogin event,
      Emitter<AuthState> emit,
      ) async {
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
    final res = await _userLogout(NoParams());

    res.fold(
          (l) => emit(AuthFailure(l.message)),
          (_) {
        _appUserCubit.clearUser();
        emit(AuthInitial());
      },
    );
  }

  // void _emitAuthSuccess(
  //     User user,
  //     Emitter<AuthState> emit,
  //     ) {
  //   // Actualiza el estado del cubit con el usuario logueado
  //   _appUserCubit.updateUser(user);
  //
  //   /*// Verifica si el estado de AppUserCubit es AppUserLoggedIn antes de acceder a user
  //   final currentState = _appUserCubit.state;
  //   if (currentState is AppUserLoggedIn) {
  //     emit(AuthSuccess(currentState.user)); // Usa el user del estado loggedIn
  //   } else {
  //     emit(const AuthFailure('Error al obtener el usuario'));
  //   }*/
  //   emit(AuthSuccess(user));
  // }

  void _emitAuthSuccess(
      User user,
      Emitter<AuthState> emit,
      ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}