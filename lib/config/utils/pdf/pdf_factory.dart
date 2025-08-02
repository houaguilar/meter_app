// lib/config/utils/pdf_factory.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/home/estructuras/structural_element_providers.dart';
import '../../../presentation/providers/ladrillo/ladrillo_providers.dart';
import '../../../presentation/providers/losas/losas_aligeradas_providers.dart';
import '../../../presentation/providers/pisos/contrapiso_providers.dart';
import '../../../presentation/providers/pisos/falso_piso_providers.dart';
import '../../../presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'pdf_generator.dart';

/// Factory para crear PDFs específicos de cada módulo
class PDFFactory {

  /// Genera PDF para resultados de ladrillos
  static Future<File> generateLadrilloPDF(WidgetRef ref) async {
    final ladrillos = ref.read(ladrilloResultProvider);
    final materials = ref.read(ladrilloMaterialsProvider);

    if (ladrillos.isEmpty) {
      throw Exception("No hay datos de ladrillos para generar el PDF");
    }

    final pdfData = PDFData(
      titulo: 'Lista de Materiales',
      fecha: _getCurrentDate(),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: 'Proyecto de Construcción',
      obra: 'Casa de campo',
      partida: 'Muro',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento',
          unidad: 'bls',
          cantidad: materials.cemento.ceil().toString(),
        ),
        MaterialItem(
          descripcion: 'Arena gruesa',
          unidad: 'm³',
          cantidad: materials.arena.toStringAsFixed(2),
        ),
        MaterialItem(
          descripcion: 'Ladrillos',
          unidad: 'und',
          cantidad: materials.ladrillos.toStringAsFixed(0),
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: materials.agua.toStringAsFixed(2),
        ),
      ],
      metrado: ladrillos.map<MetradoItem>((ladrillo) => MetradoItem(
        elemento: ladrillo.description,
        unidad: 'm²',
        medida: _calcularAreaLadrillo(ladrillo).toStringAsFixed(2),
      )).toList(),
      observaciones: [
        'Incluye juntas de mortero de 1.5 cm horizontales y verticales',
        'Factores de desperdicio aplicados de forma independiente',
        'Tipo de ladrillo: ${ladrillos.first.tipoLadrillo}',
        'Tipo de asentado: ${ladrillos.first.tipoAsentado}',
        'Proporción mortero: 1:${ladrillos.first.proporcionMortero}',
      ],
    );

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_ladrillos_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Genera PDF para resultados de losas aligeradas
  static Future<File> generateLosaAligeradaPDF(WidgetRef ref) async {
    final losas = ref.read(losaAligeradaResultProvider);

    if (losas.isEmpty) {
      throw Exception("No hay datos de losas para generar el PDF");
    }

    final cantidadCemento = ref.read(cantidadCementoLosaAligeradaProvider);
    final cantidadArena = ref.read(cantidadArenaGruesaLosaAligeradaProvider);
    final cantidadPiedra = ref.read(cantidadPiedraChancadaLosaAligeradaProvider);
    final cantidadAgua = ref.read(cantidadAguaLosaAligeradaProvider);
    final volumenConcreto = ref.read(volumenConcretoLosaAligeradaProvider);

    final pdfData = PDFData(
      titulo: 'Lista de Materiales',
      fecha: _getCurrentDate(),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: 'Proyecto de Construcción',
      obra: 'Casa de campo',
      partida: 'Losa Aligerada',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento',
          unidad: 'bls',
          cantidad: cantidadCemento.ceil().toString(),
        ),
        MaterialItem(
          descripcion: 'Arena gruesa',
          unidad: 'm³',
          cantidad: cantidadArena.toStringAsFixed(2),
        ),
        MaterialItem(
          descripcion: 'Piedra chancada',
          unidad: 'm³',
          cantidad: cantidadPiedra.toStringAsFixed(2),
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: cantidadAgua.toStringAsFixed(2),
        ),
      ],
      metrado: losas.map<MetradoItem>((losa) => MetradoItem(
        elemento: losa.description,
        unidad: 'm²',
        medida: _calcularAreaLosa(losa).toStringAsFixed(2),
      )).toList(),
      observaciones: [
        'Los desperdicios están incluidos en las cantidades mostradas',
        'Altura de losa: ${losas.first.altura}',
        'Material aligerado: ${losas.first.materialAligerado}',
        'Resistencia concreto: ${losas.first.resistenciaConcreto}',
        'Desperdicio concreto: ${losas.first.desperdicioConcreto}%',
        'Volumen total concreto: ${volumenConcreto.toStringAsFixed(2)} m³',
      ],
    );

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_losa_aligerada_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Genera PDF para resultados de falso piso
  static Future<File> generateFalsoPisoPDF(WidgetRef ref) async {
    final falsosPisos = ref.read(falsoPisoResultProvider);
    final materials = ref.read(falsoPisoMaterialsProvider);  // ✅ Usar provider correcto
    final areas = ref.read(areaFalsoPisoProvider);  // ✅ Nuevo provider para áreas

    if (falsosPisos.isEmpty) {
      throw Exception("No hay datos de falso piso para generar el PDF");
    }

    final pdfData = PDFData(
      titulo: 'Lista de Materiales',
      fecha: _getCurrentDate(),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: 'Proyecto de Construcción',
      obra: 'Casa de campo',
      partida: 'Falso Piso',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento',
          unidad: 'bls',
          cantidad: materials.cementoBolsas.toString(),  // ✅ Usar método formateado
        ),
        MaterialItem(
          descripcion: 'Arena gruesa',
          unidad: 'm³',
          cantidad: materials.arenaFormateada,  // ✅ Usar método formateado
        ),
        MaterialItem(
          descripcion: 'Piedra chancada',
          unidad: 'm³',
          cantidad: materials.piedraFormateada,  // ✅ Usar método formateado
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: materials.aguaFormateada,  // ✅ Usar método formateado
        ),
      ],
      metrado: falsosPisos.asMap().entries.map<MetradoItem>((entry) {
        final index = entry.key;
        final piso = entry.value;
        final area = index < areas.length ? areas[index] : 0.0;  // ✅ Usar área del provider

        return MetradoItem(
          elemento: piso.description,
          unidad: 'm²',  // ✅ Cambio: m³ → m²
          medida: area.toStringAsFixed(2),  // ✅ Mostrar área en lugar de volumen
        );
      }).toList(),
      observaciones: [
        'Área total: ${materials.areaTotalFormateada} m²',  // ✅ Cambio: Volumen → Área
        'Espesor: ${falsosPisos.first.espesor} cm',
        'Resistencia concreto: ${falsosPisos.first.resistencia ?? "175 kg/cm²"}',
        'Factor de desperdicio: ${falsosPisos.first.factorDesperdicio}%',
      ],
    );

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_falso_piso_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
  /// Genera PDF para resultados de contrapiso
  static Future<File> generateContrapisoPDF(WidgetRef ref) async {
    final contrapisos = ref.read(contrapisoResultProvider);
    final materials = ref.read(contrapisoMaterialsProvider);  // ✅ Usar el provider correcto
    final areas = ref.read(areaContrapisoProvider);  // ✅ Nuevo provider para áreas

    if (contrapisos.isEmpty) {
      throw Exception("No hay datos de contrapiso para generar el PDF");
    }

    final pdfData = PDFData(
      titulo: 'Lista de Materiales',
      fecha: _getCurrentDate(),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: 'Proyecto de Construcción',
      obra: 'Casa de campo',
      partida: 'Contrapiso',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento',
          unidad: 'bls',
          cantidad: materials.cementoBolsas.toString(),  // ✅ Usar método formateado
        ),
        MaterialItem(
          descripcion: 'Arena gruesa',
          unidad: 'm³',
          cantidad: materials.arenaFormateada,  // ✅ Usar método formateado
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: materials.aguaFormateada,  // ✅ Usar método formateado
        ),
      ],
      metrado: contrapisos.asMap().entries.map<MetradoItem>((entry) {
        final index = entry.key;
        final piso = entry.value;
        final area = index < areas.length ? areas[index] : 0.0;  // ✅ Usar área del provider

        return MetradoItem(
          elemento: piso.description,
          unidad: 'm²',  // ✅ Cambio: m³ → m²
          medida: area.toStringAsFixed(2),  // ✅ Mostrar área en lugar de volumen
        );
      }).toList(),
      observaciones: [
        'Área total: ${materials.areaTotalFormateada} m²',  // ✅ Cambio: Volumen → Área
        'Espesor: ${contrapisos.first.espesor} cm',
        'Proporción mortero: 1:${contrapisos.first.proporcionMortero ?? "5"}',
        'Factor de desperdicio: ${contrapisos.first.factorDesperdicio}%',
      ],
    );

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_contrapiso_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Genera PDF para resultados de tarrajeo
  static Future<File> generateTarrajeoPDF(WidgetRef ref) async {
    final tarrajeos = ref.read(tarrajeoResultProvider);
    final materiales = ref.read(tarrajeoMaterialesProvider);
    final metrados = ref.read(tarrajeoMetradosProvider);

    if (tarrajeos.isEmpty) {
      throw Exception("No hay datos de tarrajeo para generar el PDF");
    }

    final pdfData = PDFData(
      titulo: 'Lista de Materiales',
      fecha: _getCurrentDate(),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: 'Proyecto de Construcción',
      obra: 'Casa de campo',
      partida: 'Tarrajeo',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento',
          unidad: 'bls',
          cantidad: materiales.cementoFormateado,
        ),
        MaterialItem(
          descripcion: 'Arena fina',
          unidad: 'm³',
          cantidad: materiales.arenaFormateada,
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: materiales.aguaFormateada,
        ),
      ],
      metrado: metrados.map<MetradoItem>((metrado) => MetradoItem(
        elemento: metrado.descripcion,
        unidad: 'm³',
        medida: metrado.volumenFormateado,
      )).toList(),
      observaciones: [
        'Volumen total: ${materiales.volumenFormateado} m³',
        'Tipo de tarrajeo: ${tarrajeos.first.tipo}',
        'Espesor: ${tarrajeos.first.espesor} cm',
        'Proporción mortero: 1:${tarrajeos.first.proporcionMortero}',
        'Factor de desperdicio: ${tarrajeos.first.factorDesperdicio}%',
      ],
    );

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_tarrajeo_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Genera PDF para resultados de elementos estructurales
  static Future<File> generateStructuralElementPDF(WidgetRef ref) async {
    final tipoElemento = ref.read(tipoStructuralElementProvider);

    if (tipoElemento.isEmpty) {
      throw Exception("No se ha definido el tipo de elemento estructural");
    }

    PDFData pdfData;

    if (tipoElemento == 'columna') {
      final columnas = ref.read(columnaResultProvider);
      if (columnas.isEmpty) {
        throw Exception("No hay datos de columnas para generar el PDF");
      }

      final cantidadCemento = ref.read(cantidadCementoColumnaProvider);
      final cantidadArena = ref.read(cantidadArenaColumnaProvider);
      final cantidadPiedra = ref.read(cantidadPiedraColumnaProvider);
      final cantidadAgua = ref.read(cantidadAguaColumnaProvider);

      pdfData = PDFData(
        titulo: 'Lista de Materiales',
        fecha: _getCurrentDate(),
        numeroCotizacion: _generateCotizationNumber(),
        proyecto: 'Proyecto de Construcción',
        obra: 'Casa de campo',
        partida: 'Columna',
        materiales: [
          MaterialItem(
            descripcion: 'Cemento',
            unidad: 'bls',
            cantidad: cantidadCemento.ceil().toString(),
          ),
          MaterialItem(
            descripcion: 'Arena gruesa',
            unidad: 'm³',
            cantidad: cantidadArena.toStringAsFixed(2),
          ),
          MaterialItem(
            descripcion: 'Piedra para concreto',
            unidad: 'm³',
            cantidad: cantidadPiedra.toStringAsFixed(2),
          ),
          MaterialItem(
            descripcion: 'Agua',
            unidad: 'm³',
            cantidad: cantidadAgua.toStringAsFixed(2),
          ),
        ],
        metrado: columnas.map<MetradoItem>((columna) => MetradoItem(
          elemento: columna.description,
          unidad: 'm³',
          medida: _calcularVolumenElemento(columna).toStringAsFixed(2),
        )).toList(),
        observaciones: [
          'Cálculos basados en factores de concreto según resistencia',
          'Resistencia del concreto: ${columnas.first.resistencia}',
          'Factor de desperdicio: ${columnas.first.factorDesperdicio}%',
        ],
      );
    } else if (tipoElemento == 'viga') {
      final vigas = ref.read(vigaResultProvider);
      if (vigas.isEmpty) {
        throw Exception("No hay datos de vigas para generar el PDF");
      }

      final cantidadCemento = ref.read(cantidadCementoVigaProvider);
      final cantidadArena = ref.read(cantidadArenaVigaProvider);
      final cantidadPiedra = ref.read(cantidadPiedraVigaProvider);
      final cantidadAgua = ref.read(cantidadAguaVigaProvider);

      pdfData = PDFData(
        titulo: 'Lista de Materiales',
        fecha: _getCurrentDate(),
        numeroCotizacion: _generateCotizationNumber(),
        proyecto: 'Proyecto de Construcción',
        obra: 'Casa de campo',
        partida: 'Viga',
        materiales: [
          MaterialItem(
            descripcion: 'Cemento ',
            unidad: 'bls',
            cantidad: cantidadCemento.ceil().toString(),
          ),
          MaterialItem(
            descripcion: 'Arena gruesa',
            unidad: 'm³',
            cantidad: cantidadArena.toStringAsFixed(2),
          ),
          MaterialItem(
            descripcion: 'Piedra para concreto',
            unidad: 'm³',
            cantidad: cantidadPiedra.toStringAsFixed(2),
          ),
          MaterialItem(
            descripcion: 'Agua',
            unidad: 'm³',
            cantidad: cantidadAgua.toStringAsFixed(2),
          ),
        ],
        metrado: vigas.map<MetradoItem>((viga) => MetradoItem(
          elemento: viga.description,
          unidad: 'm³',
          medida: _calcularVolumenElemento(viga).toStringAsFixed(2),
        )).toList(),
        observaciones: [
          'Cálculos basados en factores de concreto según resistencia',
          'Resistencia del concreto: ${vigas.first.resistencia}',
          'Factor de desperdicio: ${vigas.first.factorDesperdicio}%',
        ],
      );
    } else {
      throw Exception("Tipo de elemento estructural no válido: $tipoElemento");
    }

    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'lista_materiales_${tipoElemento}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  // Funciones auxiliares para cálculos

  static double _calcularAreaLadrillo(dynamic ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
      final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
      return largo * altura;
    }
  }

  static double _calcularAreaLosa(dynamic losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }

  static double _calcularVolumenElemento(dynamic elemento) {
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

  // Funciones utilitarias

  static String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} de ${_getMonthName(now.month)} ${now.year}';
  }

  static String _getMonthName(int month) {
    const months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month];
  }

  static String _generateCotizationNumber() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }
}