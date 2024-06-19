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
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserLogin userLogin,
    required CurrentUser currentUser,
    required UserLogout userLogout,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userLogin = userLogin,
        _currentUser = currentUser,
        _userLogout = userLogout,
      _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
    on<AuthLogout>(_onAuthLogout);
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

  void _emitAuthSuccess(
      User user,
      Emitter<AuthState> emit,
      ) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}