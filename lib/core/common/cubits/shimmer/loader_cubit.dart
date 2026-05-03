import 'package:flutter_bloc/flutter_bloc.dart';

class LoaderCubit extends Cubit<bool> {
  LoaderCubit() : super(false);

  // Mostrar el loader
  void showLoader() => emit(true);

  // Ocultar el loader
  void hideLoader() => emit(false);
}
