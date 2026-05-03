import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/constant.dart';
import '../../../../domain/entities/home/estructuras/cimiento_corrido/cimiento_corrido.dart';
import '../../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../../domain/entities/home/estructuras/sobrecimiento/sobrecimiento.dart';
import '../../../../domain/entities/home/estructuras/solado/solado.dart';
import '../../../../domain/entities/home/estructuras/structural_element.dart';
import '../../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../../domain/entities/home/estructuras/zapata/zapata.dart';
import 'package:meter_app/core/assets/app_images.dart';

final List<StructuralElement> _structuralElements = [
  StructuralElement(
    id: '1',
    name: 'Columna',
    image: AppImages.columnaConcretoImg,
    details: 'Las columnas son elementos estructurales verticales que transmiten cargas de compresión a la cimentación.',
  ),
  StructuralElement(
    id: '2',
    name: 'Viga',
    image: AppImages.vigaConcretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
  StructuralElement(
    id: '3',
    name: 'Zapata',
    image: AppImages.zapataConcretoImg,
    details: 'Las zapatas son elementos de cimentación que transmiten las cargas de las columnas al suelo.',
  ),
  /*StructuralElement(
    id: '4',
    name: 'Cimiento corrido',
    image: AppImages.concretoImg,
    details: 'Las vigas son elementos estructurales horizontales que soportan cargas transversales.',
  ),
  StructuralElement(
    id: '5',
    name: 'Sobrecimiento',
    image: AppImages.concretoImg,
    details: 'Elementos de concreto simple que conectan la cimentación con los muros.',
  ),
  StructuralElement(
    id: '6',
    name: 'Solado',
    image: AppImages.concretoImg,
    details: 'Capa de concreto simple que se coloca sobre el terreno como base.',
  ),*/
];

final structuralElementsProvider = Provider<List<StructuralElement>>((ref) {
  return _structuralElements;
});

class SelectedStructuralElement extends Notifier<StructuralElement?> {
  @override
  StructuralElement? build() => null;

  void selectElement(StructuralElement element) {
    state = element;
  }

  void clearSelection() {
    state = null;
  }
}

final selectedStructuralElementProvider =
    NotifierProvider<SelectedStructuralElement, StructuralElement?>(
        SelectedStructuralElement.new);

// FIX: Cambiamos a NotifierProvider para mejor manejo del estado
final tipoStructuralElementProvider = NotifierProvider<TipoStructuralElementNotifier, String>(() {
  return TipoStructuralElementNotifier();
});

class TipoStructuralElementNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void update(String value) => state = value;
}

// FIX: Agregamos un provider helper para debug
final currentStructuralElementTypeProvider = Provider<String>((ref) {
  final tipo = ref.watch(tipoStructuralElementProvider);
  return tipo;
});

// Factores de materiales según resistencia del concreto (líneas 15-80 del Excel)
const Map<String, Map<String, double>> factoresConcreto = {
  "175 kg/cm²": {
    "cemento": 8.43, // bolsas por m³
    "arenaGruesa": 0.54, // m³ por m³
    "piedraConcreto": 0.55, // m³ por m³
    "agua": 0.185, // m³ por m³
  },
  "210 kg/cm²": {
    "cemento": 9.73, // bolsas por m³
    "arenaGruesa": 0.52, // m³ por m³
    "piedraConcreto": 0.53, // m³ por m³
    "agua": 0.186, // m³ por m³
  },
  "245 kg/cm²": {
    "cemento": 11.5, // bolsas por m³
    "arenaGruesa": 0.5, // m³ por m³
    "piedraConcreto": 0.51, // m³ por m³
    "agua": 0.187, // m³ por m³
  },
  "280 kg/cm²": {
    "cemento": 13.34, // bolsas por m³
    "arenaGruesa": 0.45, // m³ por m³
    "piedraConcreto": 0.51, // m³ por m³
    "agua": 0.189, // m³ por m³
  },
};

// Helper function para calcular volumen de elementos estructurales
double calcularVolumenElemento(dynamic elemento) {
  // Caso especial para Solado
  if (elemento is Solado) {
    return calcularVolumenSolado(elemento);
  }

  // Lógica existente para otros elementos
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

// Helper function para aplicar desperdicio
double aplicarDesperdicio(double valor, String factorDesperdicio) {
  final desperdicio = double.tryParse(factorDesperdicio) ?? 5.0;
  return valor * (1 + (desperdicio / 100));
}

// Providers for Columna
class ColumnaResult extends Notifier<List<Columna>> {
  @override
  List<Columna> build() => [];

  void createColumna(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newColumna = Columna(
      idColumna: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que la columna tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newColumna);
    if (volumenCalculado <= 0) {
      throw Exception("La columna debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newColumna];
  }

  void clearList() {
    state = [];
  }
}

final columnaResultProvider =
    NotifierProvider<ColumnaResult, List<Columna>>(ColumnaResult.new);

final volumenColumnaProvider = Provider<List<double>>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  final volumenes = columnas.map((columna) => calcularVolumenElemento(columna)).toList();
  return volumenes;
});

final descriptionColumnaProvider = Provider<List<String>>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  return columnas.map((e) => e.description).toList();
});

final datosShareColumnaProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionColumnaProvider);
  final volumen = ref.watch(volumenColumnaProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(1)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// Providers para cálculos de materiales de Columna
final cantidadCementoColumnaProvider = Provider<double>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, columna.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaColumnaProvider = Provider<double>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, columna.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraColumnaProvider = Provider<double>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraConcreto']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, columna.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaColumnaProvider = Provider<double>((ref) {
  final columnas = ref.watch(columnaResultProvider);
  if (columnas.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final columna in columnas) {
    final volumen = calcularVolumenElemento(columna);
    final factores = factoresConcreto[columna.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, columna.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});

// Providers for Viga
class VigaResult extends Notifier<List<Viga>> {
  @override
  List<Viga> build() => [];

  void createViga(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newViga = Viga(
      idViga: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que la viga tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newViga);
    if (volumenCalculado <= 0) {
      throw Exception("La viga debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newViga];
  }

  void clearList() {
    state = [];
  }
}

final vigaResultProvider =
    NotifierProvider<VigaResult, List<Viga>>(VigaResult.new);

// === Provider: Zapata ===
class ZapataResult extends Notifier<List<Zapata>> {
  @override
  List<Zapata> build() => [];

  void createZapata(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newZapata = Zapata(
      idZapata: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que la zapata tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newZapata);
    if (volumenCalculado <= 0) {
      throw Exception("La zapata debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newZapata];
  }

  void clearList() {
    state = [];
  }
}

final zapataResultProvider =
    NotifierProvider<ZapataResult, List<Zapata>>(ZapataResult.new);

final volumenZapataProvider = Provider<List<double>>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  final volumenes = zapatas.map((zapata) => calcularVolumenElemento(zapata)).toList();
  return volumenes;
});

final descriptionZapataProvider = Provider<List<String>>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  final descripciones = zapatas.map((zapata) => zapata.description).toList();
  return descripciones;
});

final datosShareZapataProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionZapataProvider);
  final volumen = ref.watch(volumenZapataProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(1)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

final volumenVigaProvider = Provider<List<double>>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  final volumenes = vigas.map((viga) => calcularVolumenElemento(viga)).toList();
  return volumenes;
});

final descriptionVigaProvider = Provider<List<String>>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  return vigas.map((e) => e.description).toList();
});

final datosShareVigaProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionVigaProvider);
  final volumen = ref.watch(volumenVigaProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(1)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// Providers para cálculos de materiales de Viga
final cantidadCementoVigaProvider = Provider<double>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, viga.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaVigaProvider = Provider<double>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, viga.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraVigaProvider = Provider<double>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraConcreto']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, viga.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaVigaProvider = Provider<double>((ref) {
  final vigas = ref.watch(vigaResultProvider);
  if (vigas.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final viga in vigas) {
    final volumen = calcularVolumenElemento(viga);
    final factores = factoresConcreto[viga.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, viga.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});

// === Cálculo de materiales: Zapata ===

final cantidadCementoZapataProvider = Provider<double>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  if (zapatas.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final zapata in zapatas) {
    final volumen = calcularVolumenElemento(zapata);
    final factores = factoresConcreto[zapata.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, zapata.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaZapataProvider = Provider<double>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  if (zapatas.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final zapata in zapatas) {
    final volumen = calcularVolumenElemento(zapata);
    final factores = factoresConcreto[zapata.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, zapata.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraZapataProvider = Provider<double>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  if (zapatas.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final zapata in zapatas) {
    final volumen = calcularVolumenElemento(zapata);
    final factores = factoresConcreto[zapata.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraConcreto']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, zapata.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaZapataProvider = Provider<double>((ref) {
  final zapatas = ref.watch(zapataResultProvider);
  if (zapatas.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final zapata in zapatas) {
    final volumen = calcularVolumenElemento(zapata);
    final factores = factoresConcreto[zapata.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, zapata.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});


// Agregar al final de structural_element_providers.dart:

// Constantes específicas para Sobrecimiento (basadas en el Excel)
const Map<String, Map<String, double>> factoresSobrecimiento = {
  "175 kg/cm²": {
    "cemento": 8.43, // bolsas por m³
    "arenaGruesa": 0.45, // m³ por m³
    "piedraChancada": 0.40, // m³ por m³
    "piedraGrande": 0.25, // m³ por m³
    "agua": 0.139, // m³ por m³
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

// Providers for Sobrecimiento
class SobrecimientoResult extends Notifier<List<Sobrecimiento>> {
  @override
  List<Sobrecimiento> build() => [];

  void createSobrecimiento(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newSobrecimiento = Sobrecimiento(
      idSobrecimiento: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que el sobrecimiento tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newSobrecimiento);
    if (volumenCalculado <= 0) {
      throw Exception("El sobrecimiento debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newSobrecimiento];
  }

  void clearList() {
    state = [];
  }
}

final sobrecimientoResultProvider =
    NotifierProvider<SobrecimientoResult, List<Sobrecimiento>>(
        SobrecimientoResult.new);

final volumenSobrecimientoProvider = Provider<List<double>>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  final volumenes = sobrecimientos.map((sobrecimiento) => calcularVolumenElemento(sobrecimiento)).toList();
  return volumenes;
});

final descriptionSobrecimientoProvider = Provider<List<String>>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  return sobrecimientos.map((e) => e.description).toList();
});

final datosShareSobrecimientoProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionSobrecimientoProvider);
  final volumen = ref.watch(volumenSobrecimientoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(1)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// Providers para cálculos de materiales específicos del Sobrecimiento
final cantidadCementoSobrecimientoProvider = Provider<double>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, sobrecimiento.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaSobrecimientoProvider = Provider<double>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, sobrecimiento.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraChancadaSobrecimientoProvider = Provider<double>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, sobrecimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadPiedraGrandeSobrecimientoProvider = Provider<double>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraGrande']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, sobrecimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaSobrecimientoProvider = Provider<double>((ref) {
  final sobrecimientos = ref.watch(sobrecimientoResultProvider);
  if (sobrecimientos.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final sobrecimiento in sobrecimientos) {
    final volumen = calcularVolumenElemento(sobrecimiento);
    final factores = factoresSobrecimiento[sobrecimiento.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, sobrecimiento.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});

// Agregar en structural_element_providers.dart:

// Constantes específicas para Cimiento Corrido (basadas en el Excel)
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

// Providers for Cimiento Corrido
class CimientoCorridoResult extends Notifier<List<CimientoCorrido>> {
  @override
  List<CimientoCorrido> build() => [];

  void createCimientoCorrido(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? altura,
        String? volumen,
      }) {
    final newCimientoCorrido = CimientoCorrido(
      idCimientoCorrido: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      altura: altura,
      volumen: volumen,
    );

    // Validar que el cimiento tenga datos suficientes
    final volumenCalculado = calcularVolumenElemento(newCimientoCorrido);
    if (volumenCalculado <= 0) {
      throw Exception("El cimiento corrido debe tener largo, ancho y altura o volumen definidos.");
    }

    state = [...state, newCimientoCorrido];
  }

  void clearList() {
    state = [];
  }
}

final cimientoCorridoResultProvider =
    NotifierProvider<CimientoCorridoResult, List<CimientoCorrido>>(
        CimientoCorridoResult.new);

final volumenCimientoCorridoProvider = Provider<List<double>>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  final volumenes = cimientos.map((cimiento) => calcularVolumenElemento(cimiento)).toList();
  return volumenes;
});

final descriptionCimientoCorridoProvider = Provider<List<String>>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  return cimientos.map((e) => e.description).toList();
});

final datosShareCimientoCorridoProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionCimientoCorridoProvider);
  final volumen = ref.watch(volumenCimientoCorridoProvider);

  String datos = "";
  if (description.length == volumen.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${volumen[i].toStringAsFixed(1)} m3\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// Providers para cálculos de materiales específicos del Cimiento Corrido
final cantidadCementoCimientoCorridoProvider = Provider<double>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, cimiento.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaCimientoCorridoProvider = Provider<double>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, cimiento.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraChancadaCimientoCorridoProvider = Provider<double>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, cimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadPiedraZanjaCimientoCorridoProvider = Provider<double>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraZanja']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, cimiento.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaCimientoCorridoProvider = Provider<double>((ref) {
  final cimientos = ref.watch(cimientoCorridoResultProvider);
  if (cimientos.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final cimiento in cimientos) {
    final volumen = calcularVolumenElemento(cimiento);
    final factores = factoresCimientoCorrido[cimiento.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, cimiento.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});


// Constantes específicas para Solado (basadas en el Excel)
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

// Helper function para calcular volumen de Solado
double calcularVolumenSolado(Solado solado) {
  // Para solado, el volumen siempre se calcula como: área × espesor_fijo
  if (solado.area != null && solado.area!.isNotEmpty) {
    final area = double.tryParse(solado.area!) ?? 0.0;
    return area * solado.espesorFijo;
  }

  if (solado.largo != null && solado.largo!.isNotEmpty &&
      solado.ancho != null && solado.ancho!.isNotEmpty) {
    final largo = double.tryParse(solado.largo!) ?? 0.0;
    final ancho = double.tryParse(solado.ancho!) ?? 0.0;
    final area = largo * ancho;
    return area * solado.espesorFijo;
  }

  return 0.0;
}

// Providers for Solado
class SoladoResult extends Notifier<List<Solado>> {
  @override
  List<Solado> build() => [];

  void createSolado(
      String description,
      String resistencia,
      String factorDesperdicio, {
        String? largo,
        String? ancho,
        String? area,
      }) {
    final newSolado = Solado(
      idSolado: uuid.v4(),
      description: description,
      resistencia: resistencia,
      factorDesperdicio: factorDesperdicio,
      largo: largo,
      ancho: ancho,
      area: area,
      espesorFijo: 0.1, // Siempre 10 cm
    );

    // Validar que el solado tenga datos suficientes
    final volumenCalculado = calcularVolumenSolado(newSolado);
    if (volumenCalculado <= 0) {
      throw Exception("El solado debe tener área o largo y ancho definidos.");
    }

    state = [...state, newSolado];
  }

  void clearList() {
    state = [];
  }
}

final soladoResultProvider =
    NotifierProvider<SoladoResult, List<Solado>>(SoladoResult.new);

final volumenSoladoProvider = Provider<List<double>>((ref) {
  final solados = ref.watch(soladoResultProvider);
  final volumenes = solados.map((solado) => calcularVolumenSolado(solado)).toList();
  return volumenes;
});

final areaSoladoProvider = Provider<List<double>>((ref) {
  final solados = ref.watch(soladoResultProvider);
  final areas = solados.map((solado) {
    if (solado.area != null && solado.area!.isNotEmpty) {
      return double.tryParse(solado.area!) ?? 0.0;
    }
    if (solado.largo != null && solado.largo!.isNotEmpty &&
        solado.ancho != null && solado.ancho!.isNotEmpty) {
      final largo = double.tryParse(solado.largo!) ?? 0.0;
      final ancho = double.tryParse(solado.ancho!) ?? 0.0;
      return largo * ancho;
    }
    return 0.0;
  }).toList();
  return areas;
});

final descriptionSoladoProvider = Provider<List<String>>((ref) {
  final solados = ref.watch(soladoResultProvider);
  return solados.map((e) => e.description).toList();
});

final datosShareSoladoProvider = Provider<String>((ref) {
  final description = ref.watch(descriptionSoladoProvider);
  final areas = ref.watch(areaSoladoProvider);

  String datos = "";
  if (description.length == areas.length) {
    for (int i = 0; i < description.length; i++) {
      datos += "* ${description[i]}: ${areas[i].toStringAsFixed(1)} m2\n";
    }
    if (datos.length > 2) {
      datos = datos.substring(0, datos.length - 2);
    }
  }
  return datos;
});

// Providers para cálculos de materiales específicos del Solado
final cantidadCementoSoladoProvider = Provider<double>((ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double cementoTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final cementoPorM3 = factores['cemento']!;
      final cementoConDesperdicio = aplicarDesperdicio(cementoPorM3, solado.factorDesperdicio);
      cementoTotal += cementoConDesperdicio * volumen;
    }
  }

  return cementoTotal;
});

final cantidadArenaSoladoProvider = Provider<double>((ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double arenaTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final arenaPorM3 = factores['arenaGruesa']!;
      final arenaConDesperdicio = aplicarDesperdicio(arenaPorM3, solado.factorDesperdicio);
      arenaTotal += arenaConDesperdicio * volumen;
    }
  }

  return arenaTotal;
});

final cantidadPiedraChancadaSoladoProvider = Provider<double>((ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double piedraTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final piedraPorM3 = factores['piedraChancada']!;
      final piedraConDesperdicio = aplicarDesperdicio(piedraPorM3, solado.factorDesperdicio);
      piedraTotal += piedraConDesperdicio * volumen;
    }
  }

  return piedraTotal;
});

final cantidadAguaSoladoProvider = Provider<double>((ref) {
  final solados = ref.watch(soladoResultProvider);
  if (solados.isEmpty) return 0.0;

  double aguaTotal = 0.0;

  for (final solado in solados) {
    final volumen = calcularVolumenSolado(solado);
    final factores = factoresSolado[solado.resistencia];

    if (factores != null && volumen > 0) {
      final aguaPorM3 = factores['agua']!;
      final aguaConDesperdicio = aplicarDesperdicio(aguaPorM3, solado.factorDesperdicio);
      aguaTotal += aguaConDesperdicio * volumen;
    }
  }

  return aguaTotal;
});