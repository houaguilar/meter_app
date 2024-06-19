
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../data/models/models.dart';

part 'losas_macizas_providers.g.dart';

@riverpod
class LosaMacizaResult extends _$LosaMacizaResult {

  @override
  List<LosaMacizaModel> build() => [];

  void createLosaMaciza(
      String description,
      String largo,
      String ancho,
      String peralte
      ) {
    state = [
      ...state, LosaMacizaModel(id: uuid.v4(), description: description, largo: largo, ancho: ancho, peralte: peralte)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
class AddLosaMaciza1 extends _$AddLosaMaciza1 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza2 extends _$AddLosaMaciza2 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza3 extends _$AddLosaMaciza3 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza4 extends _$AddLosaMaciza4 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza5 extends _$AddLosaMaciza5 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza6 extends _$AddLosaMaciza6 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}

@riverpod
class AddLosaMaciza7 extends _$AddLosaMaciza7 {
  @override
  bool build() => true;

  void toggleAddLosaMaciza() {
    state = !state;
  }
}
