
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/constants/constants.dart';
import '../../../data/models/models.dart';

part 'losas_escaleras_providers.g.dart';

@riverpod
class LosaEscalerasResult extends _$LosaEscalerasResult {

  @override
  List<EscaleraModel> build() => [];

  void createEscalera(
      String description,
      String largo,
      String ancho,
      String espesor,
      String numeroPasos,
      String pasos,
      String contrapaso
      ) {
    state = [
      ...state, EscaleraModel(id: uuid.v4(), description: description, largo: largo, ancho: ancho, espesor: espesor, numeroPasos: numeroPasos, pasos: pasos, contrapaso: contrapaso)
    ];
  }

  void clearList() {
    state.clear();
  }
}

@riverpod
class AddEscalera1 extends _$AddEscalera1 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera2 extends _$AddEscalera2 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera3 extends _$AddEscalera3 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera4 extends _$AddEscalera4 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera5 extends _$AddEscalera5 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera6 extends _$AddEscalera6 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}

@riverpod
class AddEscalera7 extends _$AddEscalera7 {
  @override
  bool build() => true;

  void toggleAddEscalera() {
    state = !state;
  }
}
