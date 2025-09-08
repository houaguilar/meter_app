import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../domain/entities/home/acero/steel_element.dart';
import '../../../../presentation/assets/images.dart';

part 'steel_element_providers.g.dart';

final List<SteelElement> _steelElements = [
  SteelElement(
    id: '1',
    name: 'Acero en Viga',
    image: AppImages.concretoImg,
    details: 'Cálculo de materiales de acero para vigas estructurales.',
  ),
  SteelElement(
    id: '2',
    name: 'Acero en Columna',
    image: AppImages.concretoImg,
    details: 'Cálculo de materiales de acero para columnas estructurales.',
  ),
  SteelElement(
    id: '3',
    name: 'Acero en Zapata',
    image: AppImages.concretoImg,
    details: 'Cálculo de materiales de acero para zapatas.',
  ),
];

@riverpod
Future<List<SteelElement>> steelElements(SteelElementsRef ref) async {
  await Future.delayed(const Duration(milliseconds: 100));
  return _steelElements;
}

@riverpod
class SelectedSteelElement extends _$SelectedSteelElement {
  @override
  SteelElement? build() {
    return null;
  }

  void selectElement(SteelElement? element) {
    state = element;
  }

  void clearSelection() {
    state = null;
  }
}