import '../entities/entities.dart';

class PisoService {
  double? calcularArea(Piso piso) {
    if (piso.area != null) {
      return double.tryParse(piso.area!);
    }
    if (piso.largo != null && piso.ancho != null) {
      final largo = double.tryParse(piso.largo!);
      final ancho = double.tryParse(piso.ancho!);
      if (largo != null && ancho != null) {
        return largo * ancho;
      }
    }
    return null;
  }

  double? calcularVolumen(Piso piso) {
    final area = calcularArea(piso);
    if (area != null) {
      final espesor = double.tryParse(piso.espesor);
      if (espesor != null) {
        return area * (espesor / 100);
      }
    }
    return null;
  }

  bool esValido(Piso piso) {
    return (piso.largo != null && piso.ancho != null) || piso.area != null;
  }
}