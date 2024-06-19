
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../data/models/models.dart';

part 'losas_aligeradas_providers.g.dart';

@riverpod
class LosaAigeradaResult extends _$LosaAigeradaResult {

  @override
  List<LosaAligeradaModel> build() => [];

  void createLosaAligerada(
      String description,
      String largo,
      String ancho,
      String peralte
      ) {
    state = [
      ...state, LosaAligeradaModel(id: uuid.v4(), description: description, largo: largo, ancho: ancho, peralte: peralte)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
class AddLosaAligerada1 extends _$AddLosaAligerada1 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada2 extends _$AddLosaAligerada2 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada3 extends _$AddLosaAligerada3 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada4 extends _$AddLosaAligerada4 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada5 extends _$AddLosaAligerada5 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada6 extends _$AddLosaAligerada6 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}

@riverpod
class AddLosaAligerada7 extends _$AddLosaAligerada7 {
  @override
  bool build() => true;

  void toggleAddLosaAligerada() {
    state = !state;
  }
}
