import 'package:meter_app/domain/entities/home/estructuras/solado/solado.dart';

// Factores de materiales según resistencia del concreto (columna, viga, zapata)
const Map<String, Map<String, double>> factoresConcreto = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.54,
    "piedraConcreto": 0.55,
    "agua": 0.185,
  },
  "210 kg/cm²": {
    "cemento": 9.73,
    "arenaGruesa": 0.52,
    "piedraConcreto": 0.53,
    "agua": 0.186,
  },
  "245 kg/cm²": {
    "cemento": 11.5,
    "arenaGruesa": 0.5,
    "piedraConcreto": 0.51,
    "agua": 0.187,
  },
  "280 kg/cm²": {
    "cemento": 13.34,
    "arenaGruesa": 0.45,
    "piedraConcreto": 0.51,
    "agua": 0.189,
  },
};

// Factores específicos para Sobrecimiento
const Map<String, Map<String, double>> factoresSobrecimiento = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.45,
    "piedraChancada": 0.40,
    "piedraGrande": 0.25,
    "agua": 0.139,
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.50,
    "piedraChancada": 0.45,
    "piedraGrande": 0.30,
    "agua": 0.145,
  },
  "210 kg/cm²": {
    "cemento": 9.20,
    "arenaGruesa": 0.42,
    "piedraChancada": 0.38,
    "piedraGrande": 0.23,
    "agua": 0.135,
  },
  "280 kg/cm²": {
    "cemento": 10.80,
    "arenaGruesa": 0.38,
    "piedraChancada": 0.35,
    "piedraGrande": 0.20,
    "agua": 0.125,
  },
};

// Factores específicos para Cimiento Corrido
const Map<String, Map<String, double>> factoresCimientoCorrido = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.45,
    "piedraChancada": 0.35,
    "piedraZanja": 0.30,
    "agua": 0.139,
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.50,
    "piedraChancada": 0.40,
    "piedraZanja": 0.35,
    "agua": 0.145,
  },
  "210 kg/cm²": {
    "cemento": 9.20,
    "arenaGruesa": 0.42,
    "piedraChancada": 0.33,
    "piedraZanja": 0.28,
    "agua": 0.135,
  },
  "280 kg/cm²": {
    "cemento": 10.80,
    "arenaGruesa": 0.38,
    "piedraChancada": 0.30,
    "piedraZanja": 0.25,
    "agua": 0.125,
  },
};

// Factores específicos para Solado
const Map<String, Map<String, double>> factoresSolado = {
  "175 kg/cm²": {
    "cemento": 8.43,
    "arenaGruesa": 0.54,
    "piedraChancada": 0.55,
    "agua": 0.185,
  },
  "140 kg/cm²": {
    "cemento": 7.50,
    "arenaGruesa": 0.59,
    "piedraChancada": 0.60,
    "agua": 0.190,
  },
  "210 kg/cm²": {
    "cemento": 9.20,
    "arenaGruesa": 0.51,
    "piedraChancada": 0.52,
    "agua": 0.180,
  },
  "280 kg/cm²": {
    "cemento": 10.80,
    "arenaGruesa": 0.48,
    "piedraChancada": 0.49,
    "agua": 0.175,
  },
};

/// Calcula el volumen de un elemento estructural genérico (columna, viga, zapata, etc.)
double calcularVolumenElemento(dynamic elemento) {
  if (elemento is Solado) {
    return calcularVolumenSolado(elemento);
  }

  if (elemento.volumen != null && elemento.volumen!.isNotEmpty) {
    return double.tryParse(elemento.volumen!) ?? 0.0;
  }

  if (elemento.largo != null && elemento.largo!.isNotEmpty &&
      elemento.ancho != null && elemento.ancho!.isNotEmpty &&
      elemento.altura != null && elemento.altura!.isNotEmpty) {
    final largo = double.tryParse(elemento.largo!) ?? 0.0;
    final ancho = double.tryParse(elemento.ancho!) ?? 0.0;
    final altura = double.tryParse(elemento.altura!) ?? 0.0;
    return largo * ancho * altura;
  }

  return 0.0;
}

/// Calcula el volumen de un solado (área × espesor fijo)
double calcularVolumenSolado(Solado solado) {
  if (solado.area != null && solado.area!.isNotEmpty) {
    final area = double.tryParse(solado.area!) ?? 0.0;
    return area * solado.espesorFijo;
  }

  if (solado.largo != null && solado.largo!.isNotEmpty &&
      solado.ancho != null && solado.ancho!.isNotEmpty) {
    final largo = double.tryParse(solado.largo!) ?? 0.0;
    final ancho = double.tryParse(solado.ancho!) ?? 0.0;
    return largo * ancho * solado.espesorFijo;
  }

  return 0.0;
}

/// Aplica el factor de desperdicio a un valor
double aplicarDesperdicio(double valor, String factorDesperdicio) {
  final desperdicio = double.tryParse(factorDesperdicio) ?? 5.0;
  return valor * (1 + (desperdicio / 100));
}
