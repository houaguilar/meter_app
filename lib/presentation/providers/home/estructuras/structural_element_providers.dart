// lib/presentation/providers/home/structural/structural_element_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../domain/entities/home/estructuras/structural_element.dart';
import '../../../../presentation/assets/images.dart';

part 'structural_element_providers.g.dart';

final List<StructuralElement> _structuralElements = [
  StructuralElement(
    id: '1',
    name: 'Columna',
    image: AppImages.concretoImg,
    details: 'Las columnas son elementos estructurales verticales que transmiten cargas de compresión a la cimentación.',
  ),
  StructuralElement(
    id: '2',
    name: 'Viga',
    image: AppImages.concretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
];

@riverpod
List<StructuralElement> structuralElements(StructuralElementsRef ref) {
  return _structuralElements;
}

@riverpod
class SelectedStructuralElement extends _$SelectedStructuralElement {
  @override
  StructuralElement? build() => null;
}

@riverpod
class TipoStructuralElement extends _$TipoStructuralElement {
  @override
  String build() => '';

  void selectStructuralElement(String name) {
    state = name;
  }
}