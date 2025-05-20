import '../entities/entities.dart';

class TarrajeoService {
  double? calcularArea(Tarrajeo tarrajeo) {
    if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
      return double.tryParse(tarrajeo.area!);
    }
    if (tarrajeo.longitud != null && tarrajeo.ancho != null) {
      final longitud = double.tryParse(tarrajeo.longitud!);
      final ancho = double.tryParse(tarrajeo.ancho!);
      if (longitud != null && ancho != null) {
        return longitud * ancho;
      }
    }
    return null;
  }

  double? calcularVolumen(Tarrajeo tarrajeo) {
    final area = calcularArea(tarrajeo);
    if (area != null) {
      final espesor = double.tryParse(tarrajeo.espesor);
      if (espesor != null) {
        return area * (espesor / 100); // Convertir espesor de cm a m
      }
    }
    return null;
  }

  bool esValido(Tarrajeo tarrajeo) {
    return (tarrajeo.longitud != null && tarrajeo.ancho != null) || tarrajeo.area != null;
  }
}