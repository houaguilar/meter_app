import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:meter_app/core/constants/constants.dart';
import 'package:meter_app/core/utils/number_formatter.dart';
import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/features/tarrajeo/domain/services/tarrajeo_derrame_calculator.dart';
import 'package:meter_app/features/tarrajeo/domain/services/tarrajeo_service.dart';

class TipoTarrajeoDerrrame extends Notifier<String> {
  @override
  String build() => 'Tarrajeo Derrame';

  void selectTarrajeoDerrrame(String name) {
    state = name;
  }
}

final tipoTarrajeoDerrrameProvider =
    NotifierProvider<TipoTarrajeoDerrrame, String>(TipoTarrajeoDerrrame.new);

class TarrajeoDerrameResult extends Notifier<List<Tarrajeo>> {
  final TarrajeoService _tarrajeoService = TarrajeoService();

  @override
  List<Tarrajeo> build() => [];

  void createTarrajeoDerrrame(
      String tipo,
      String description,
      String factor,
      String proporcionMortero,
      String espesor, {
        String? longitud,
        String? ancho,
        String? area,
      }) {
    final newTarrajeo = Tarrajeo(
      idCoating: uuid.v4(),
      description: description,
      tipo: tipo,
      factorDesperdicio: factor,
      proporcionMortero: proporcionMortero,
      espesor: espesor,
      longitud: longitud,
      ancho: ancho,
      area: area,
    );

    if (!_tarrajeoService.esValido(newTarrajeo)) {
      throw Exception("El tarrajeo derrame debe tener longitud y ancho o área definida.");
    }

    state = [newTarrajeo];
  }

  void clearList() {
    state = [];
  }
}

final tarrajeoDerrameResultProvider =
    NotifierProvider<TarrajeoDerrameResult, List<Tarrajeo>>(
        TarrajeoDerrameResult.new);

// ===== PROVIDERS PARA CÁLCULOS ESPECÍFICOS DE DERRAME =====

/// Provider para materiales calculados de tarrajeo derrame
final tarrajeoDerrrameMaterialesProvider =
    Provider<TarrajeoDerrrameMaterialesData>((ref) {
  final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);
  if (tarrajeos.isEmpty) {
    return TarrajeoDerrrameMaterialesData.empty();
  }

  final materialesCalculados =
      TarrajeoDerrameCalculator.calcularMaterialesTotalesDerrrame(tarrajeos);

  return TarrajeoDerrrameMaterialesData(
    cemento: materialesCalculados['cemento']!,
    arena: materialesCalculados['arena']!,
    agua: materialesCalculados['agua']!,
    volumen: materialesCalculados['volumen']!,
  );
});

/// Provider para metrados de tarrajeo derrame
final tarrajeoDerrameMetradosProvider =
    Provider<List<TarrajeoDerrameMetradoData>>((ref) {
  final tarrajeos = ref.watch(tarrajeoDerrameResultProvider);

  return tarrajeos.map((tarrajeo) {
    final area = TarrajeoDerrameCalculator.calcularAreaTarrajeoDerrrame(tarrajeo);
    final volumen = TarrajeoDerrameCalculator.calcularVolumenMorteroDerrrame(tarrajeo);

    return TarrajeoDerrameMetradoData(
      descripcion: tarrajeo.description,
      area: area,
      volumen: volumen,
      espesor: double.tryParse(tarrajeo.espesor) ?? 0.0,
    );
  }).toList();
});

// ===== CLASES DE DATOS =====

/// Clase para almacenar datos de materiales calculados de tarrajeo derrame
class TarrajeoDerrrameMaterialesData {
  final double cemento;
  final double arena;
  final double agua;
  final double volumen;

  TarrajeoDerrrameMaterialesData({
    required this.cemento,
    required this.arena,
    required this.agua,
    required this.volumen,
  });

  factory TarrajeoDerrrameMaterialesData.empty() {
    return TarrajeoDerrrameMaterialesData(
      cemento: 0.0,
      arena: 0.0,
      agua: 0.0,
      volumen: 0.0,
    );
  }

  // Getters formateados para UI
  String get cementoFormateado => formatResultValue(cemento);
  String get arenaFormateada => formatResultValue(arena);
  String get aguaFormateada => formatResultValue(agua);
  String get volumenFormateado => formatResultValue(volumen);
  String get areaTotalFormateada => "Calculada en metrados";
}

/// Clase para almacenar datos de metrado de tarrajeo derrame
class TarrajeoDerrameMetradoData {
  final String descripcion;
  final double area;
  final double volumen;
  final double espesor;

  TarrajeoDerrameMetradoData({
    required this.descripcion,
    required this.area,
    required this.volumen,
    required this.espesor,
  });

  // Getters formateados para UI
  String get areaFormateada => area.toStringAsFixed(2);
  String get volumenFormateado => formatResultValue(volumen);
  String get espesorFormateado => espesor.toStringAsFixed(1);
}
