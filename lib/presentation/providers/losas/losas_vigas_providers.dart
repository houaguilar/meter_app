
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../data/models/models.dart';

part 'losas_vigas_providers.g.dart';

@riverpod
class LosaVigasResult extends _$LosaVigasResult {

  @override
  List<VigaModel> build() => [];

  void createVigas(
      String description,
      String largo,
      String ancho,
      String altura
      ) {
    state = [
      ...state, VigaModel(id: uuid.v4(), description: description, largo: largo, ancho: ancho, altura: altura)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
class AddViga1 extends _$AddViga1 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga2 extends _$AddViga2 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga3 extends _$AddViga3 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga4 extends _$AddViga4 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga5 extends _$AddViga5 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga6 extends _$AddViga6 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}

@riverpod
class AddViga7 extends _$AddViga7 {
  @override
  bool build() => true;

  void toggleAddViga() {
    state = !state;
  }
}
