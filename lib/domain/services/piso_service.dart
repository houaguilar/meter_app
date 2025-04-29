import '../entities/entities.dart';

class PisoService {
  double? calcularArea(Piso piso) {
    if (piso.area != null) {
      return double.tryParse(piso.area!);
    }
    if (piso.largo != null && piso.ancho != null) {
      final largo = double.tryParse(piso.largo!);
      final altura = double.tryParse(piso.ancho!);
      if (largo != null && altura != null) {
        return largo * altura;
      }
    }
    return null;
  }

  bool esValido(Piso piso) {
    return (piso.largo != null && piso.ancho != null) || piso.area != null;
  }
}
