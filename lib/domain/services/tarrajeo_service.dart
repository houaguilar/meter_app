import '../entities/entities.dart';

class TarrajeoService {
  double? calcularArea(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null) {
      return double.tryParse(tarrajeo.area!);
    }
    if (tarrajeo.longitud != null && tarrajeo.ancho != null) {
      final largo = double.tryParse(tarrajeo.longitud!);
      final altura = double.tryParse(tarrajeo.ancho!);
      if (largo != null && altura != null) {
        return largo * altura;
      }
    }
    return null;
  }

  bool esValido(Tarrajeo tarrajeo) {
    return (tarrajeo.longitud != null && tarrajeo.ancho != null) || tarrajeo.area != null;
  }
}
