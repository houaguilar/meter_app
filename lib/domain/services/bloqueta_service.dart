import '../entities/entities.dart';

class BloquetaService {
  double? calcularArea(Bloqueta bloqueta) {
    if (bloqueta.area != null) {
      return double.tryParse(bloqueta.area!);
    }
    if (bloqueta.largo != null && bloqueta.altura != null) {
      final largo = double.tryParse(bloqueta.largo!);
      final altura = double.tryParse(bloqueta.altura!);
      if (largo != null && altura != null) {
        return largo * altura;
      }
    }
    return null;
  }

  bool esValido(Bloqueta bloqueta) {
    return (bloqueta.largo != null && bloqueta.altura != null) || bloqueta.area != null;
  }
}
