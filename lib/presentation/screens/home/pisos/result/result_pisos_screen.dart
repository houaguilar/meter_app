import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/entities.dart';
import '../../../../assets/icons.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultPisosScreen extends ConsumerWidget {
  const ResultPisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(pisosResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado',),
        body: const _ResultPisosScreenView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButtons(context, ref),
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              context,
              ref,
              label: 'Guardar',
              icon: Icons.add_box_rounded,
              heroTag: 'save_button_floor',
              onPressed: () {
                context.pushNamed('save-piso');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_floor',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed('map-screen-piso');
          },
          icon: const Icon(Icons.search_rounded),
          label: const Text('Buscar proveedores'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context,
      WidgetRef ref, {
        required String label,
        required IconData icon,
        required Object heroTag,
        required VoidCallback onPressed
      }) {
    return FloatingActionButton.extended(
      label: Text(label),
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  void _showOptionsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionsDialog(
          options: [
            DialogOption(
              icon: Icons.picture_as_pdf,
              text: 'PDF',
              onTap: () async {
                final pdfFile = await generatePdfPiso(ref);
                final xFile = XFile(pdfFile.path);
                Share.shareXFiles([xFile], text: 'Resultados del metrado.');
              },
            ),
            DialogOption(
              icon: Icons.text_fields,
              text: 'TEXTO',
              onTap: () async {
                await Share.share(_shareContent(ref));
              },
            ),
          ],
        );
      },
    );
  }

  String _shareContent(WidgetRef ref) {
    final listaPisos = ref.watch(pisosResultProvider);
    if (listaPisos.isEmpty) return 'Error: No hay datos disponibles.';

    final tipoPiso = listaPisos.first.tipo;
    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';
    final datosShare = ref.watch(datosSharePisosProvider);

    if (tipoPiso == 'contrapiso') {
      // Cálculos para contrapiso
      String cantidadArenaToString = calcularCantidadArenaGruesa(listaPisos).toStringAsFixed(2);
      String cantidadCementoToString = calcularCantidadCementoPisos(listaPisos).ceilToDouble().toString();
      String cantidadAguaToString = calcularCantidadAguaPisos(listaPisos).toStringAsFixed(2);

      return '$datosMetrado\n$datosShare\n-------------\n$listaMateriales\n'
          '*Arena gruesa: $cantidadArenaToString m3\n'
          '*Cemento: $cantidadCementoToString bls\n'
          '*Agua: $cantidadAguaToString m3';
    } else {
      // Cálculos para falso piso
      String cantidadArenaToString = calcularCantidadArenaGruesa(listaPisos).toStringAsFixed(2);
      String cantidadCementoToString = calcularCantidadCementoPisos(listaPisos).ceilToDouble().toString();
      String cantidadPiedraToString = calcularCantidadPiedraChancada(listaPisos).toStringAsFixed(2);
      String cantidadAguaToString = calcularCantidadAguaPisos(listaPisos).toStringAsFixed(2);

      return '$datosMetrado\n$datosShare\n-------------\n$listaMateriales\n'
          '*Arena gruesa: $cantidadArenaToString m3\n'
          '*Cemento: $cantidadCementoToString bls\n'
          '*Piedra chancada: $cantidadPiedraToString m3\n'
          '*Agua: $cantidadAguaToString m3';
    }
  }
}

class _ResultPisosScreenView extends ConsumerWidget {
  const _ResultPisosScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaPisos = ref.watch(pisosResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10,),
          if (listaPisos.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _PisosContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialList(context, listaPisos),
            ),
          ],
          const SizedBox(height: 200,)
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, Widget content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.yellowMetraShop,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMetraShop),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialList(BuildContext context, List<Piso> pisos) {
    if (pisos.isEmpty) return const SizedBox.shrink();

    final tipoPiso = pisos.first.tipo;
    final List<TableRow> rows = [
      _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
      _buildMaterialRow('Cemento', 'bls', calcularCantidadCementoPisos(pisos).ceil().toString()),
      _buildMaterialRow('Arena gruesa', 'm³', calcularCantidadArenaGruesa(pisos).toStringAsFixed(2)),
      _buildMaterialRow('Agua', 'm³', calcularCantidadAguaPisos(pisos).toStringAsFixed(2)),
    ];

    // Sólo mostrar piedra chancada para falso piso
    if (tipoPiso == 'falso') {
      rows.add(_buildMaterialRow('Piedra chancada', 'm³', calcularCantidadPiedraChancada(pisos).toStringAsFixed(2)));
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: rows,
    );
  }

  TableRow _buildMaterialRow(String description, String unit, String amount, {bool isHeader = false}) {
    final textStyle = TextStyle(
      fontSize: isHeader ? 14 : 12,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            description,
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            unit,
            style: textStyle,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            amount,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

class _PisosContainer extends ConsumerWidget {
  const _PisosContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pisosResultProvider);
    return _buildPisosContainer(context, results);
  }

  Widget _buildPisosContainer(BuildContext context, List<Piso> results) {
    double calcularVolumen(Piso piso) {
      if (piso.area != null && piso.area!.isNotEmpty) {
        final espesor = double.tryParse(piso.espesor) ?? 0.0;
        final area = double.tryParse(piso.area!) ?? 0.0;
        return area * (espesor / 100); // Convertir espesor de cm a m
      } else {
        final espesor = double.tryParse(piso.espesor) ?? 0.0;
        final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
        return largo * ancho * (espesor / 100); // Convertir espesor de cm a m
      }
    }

    double calcularSumaTotalDeVolumenes(List<Piso> results) {
      double sumaTotal = 0.0;
      for (final piso in results) {
        sumaTotal += calcularVolumen(piso);
      }
      return sumaTotal;
    }

    double sumaTotalDeVolumenes = calcularSumaTotalDeVolumenes(results);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Ancho fijo para la primera columna
          1: FlexColumnWidth(1), // Ancho fijo para la segunda columna
          2: FlexColumnWidth(1), // Ancho fijo para la tercera columna
        },
        children: [
          // Encabezados de tabla
          const TableRow(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Descripción',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Und.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Volumen',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Filas de datos
          for (var result in results)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result.description,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'm³',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    calcularVolumen(result).toStringAsFixed(2),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
              ],
            ),
          // Fila del total
          TableRow(
            decoration: BoxDecoration(color: Colors.grey[300]),
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Total:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'm³',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sumaTotalDeVolumenes.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<File> generatePdfPiso(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaPiso = ref.watch(pisosResultProvider);
  if (listaPiso.isEmpty) {
    throw Exception("No hay datos disponibles para generar el PDF");
  }

  final tipoPiso = listaPiso.first.tipo;
  String title = tipoPiso == 'contrapiso' ? 'Resultados de Contrapiso' : 'Resultados de Falso Piso';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Cemento: ${calcularCantidadCementoPisos(listaPiso).ceil()} bls'),
            pw.Text('Arena gruesa: ${calcularCantidadArenaGruesa(listaPiso).toStringAsFixed(2)} m³'),
            pw.Text('Agua: ${calcularCantidadAguaPisos(listaPiso).toStringAsFixed(2)} m³'),
            if (tipoPiso == 'falso')
              pw.Text('Piedra chancada: ${calcularCantidadPiedraChancada(listaPiso).toStringAsFixed(2)} m³'),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_piso.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

// Función auxiliar para obtener el área
double obtenerAreaPisos(Piso piso) {
  if (piso.area != null && piso.area!.isNotEmpty) {
    return double.tryParse(piso.area!) ?? 0.0; // Usar área si está disponible
  } else {
    double largo = double.tryParse(piso.largo ?? '') ?? 0.0;
    double ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
    return largo * ancho; // Calcular área usando largo y ancho
  }
}

// CÁLCULOS PARA CONTRAPISO
double calcularCantidadCementoPisosContrapiso(List<Piso> pisos) {
  double totalCemento = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero (por defecto 1:5)
    String proporcionStr = piso.proporcionMortero ?? '5';
    proporcionStr = proporcionStr.replaceAll("1 : ", "");
    int proporcion = int.tryParse(proporcionStr) ?? 5;

    // Factor de cemento según proporción (bolsas/m³)
    double factorCemento;
    switch (proporcion) {
      case 4: factorCemento = 7.0; break;
      case 5: factorCemento = 6.0; break;
      default: factorCemento = 6.0; // 1:5 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de cemento con desperdicio
    totalCemento += volumen * factorCemento * (1 + factorDesperdicio);
  }

  return totalCemento;
}

double calcularCantidadArenaGruesaContrapiso(List<Piso> pisos) {
  double totalArena = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero (por defecto 1:5)
    String proporcionStr = piso.proporcionMortero ?? '5';
    proporcionStr = proporcionStr.replaceAll("1 : ", "");
    int proporcion = int.tryParse(proporcionStr) ?? 5;

    // Factor de arena según proporción (m³/m³)
    double factorArena;
    switch (proporcion) {
      case 4: factorArena = 1.10; break;
      case 5: factorArena = 1.20; break;
      default: factorArena = 1.20; // 1:5 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de arena con desperdicio
    totalArena += volumen * factorArena * (1 + factorDesperdicio);
  }

  return totalArena;
}

double calcularCantidadAguaContrapiso(List<Piso> pisos) {
  double totalAgua = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero (por defecto 1:5)
    String proporcionStr = piso.proporcionMortero ?? '5';
    proporcionStr = proporcionStr.replaceAll("1 : ", "");
    int proporcion = int.tryParse(proporcionStr) ?? 5;

    // Factor de agua según proporción (m³/m³)
    double factorAgua;
    switch (proporcion) {
      case 4: factorAgua = 0.18; break;
      case 5: factorAgua = 0.17; break;
      default: factorAgua = 0.17; // 1:5 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de agua con desperdicio
    totalAgua += volumen * factorAgua * (1 + factorDesperdicio);
  }

  return totalAgua;
}

// CÁLCULOS PARA FALSO PISO
double calcularCantidadCementoPisosFalso(List<Piso> pisos) {
  double totalCemento = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    String resistencia = piso.resistencia ?? 'fc140';
    double factorCemento;

    // Factores de cemento según resistencia (bolsas/m³)
    switch (resistencia) {
      case 'fc100': factorCemento = 5.0; break;
      case 'fc140': factorCemento = 7.0; break;
      case 'fc175': factorCemento = 8.0; break;
      case 'fc210': factorCemento = 9.0; break;
      default: factorCemento = 7.0; // fc140 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de cemento con desperdicio
    totalCemento += volumen * factorCemento * (1 + factorDesperdicio);
  }

  return totalCemento;
}

double calcularCantidadArenaGruesaFalso(List<Piso> pisos) {
  double totalArena = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    String resistencia = piso.resistencia ?? 'fc140';
    double factorArena;

    // Factores de arena según resistencia (m³/m³)
    switch (resistencia) {
      case 'fc100': factorArena = 0.55; break;
      case 'fc140': factorArena = 0.50; break;
      case 'fc175': factorArena = 0.45; break;
      case 'fc210': factorArena = 0.40; break;
      default: factorArena = 0.50; // fc140 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de arena con desperdicio
    totalArena += volumen * factorArena * (1 + factorDesperdicio);
  }

  return totalArena;
}

double calcularCantidadPiedraChancadaFalso(List<Piso> pisos) {
  double totalPiedra = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    String resistencia = piso.resistencia ?? 'fc140';
    double factorPiedra;

    // Factores de piedra según resistencia (m³/m³)
    switch (resistencia) {
      case 'fc100': factorPiedra = 0.75; break;
      case 'fc140': factorPiedra = 0.70; break;
      case 'fc175': factorPiedra = 0.65; break;
      case 'fc210': factorPiedra = 0.60; break;
      default: factorPiedra = 0.70; // fc140 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de piedra con desperdicio
    totalPiedra += volumen * factorPiedra * (1 + factorDesperdicio);
  }

  return totalPiedra;
}

double calcularCantidadAguaFalso(List<Piso> pisos) {
  double totalAgua = 0.0;
  for (var piso in pisos) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor) ?? 0.0;
    double factorDesperdicio = double.tryParse(piso.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    String resistencia = piso.resistencia ?? 'fc140';
    double factorAgua;

    // Factores de agua según resistencia (m³/m³)
    switch (resistencia) {
      case 'fc100': factorAgua = 0.185; break;
      case 'fc140': factorAgua = 0.180; break;
      case 'fc175': factorAgua = 0.175; break;
      case 'fc210': factorAgua = 0.170; break;
      default: factorAgua = 0.180; // fc140 por defecto
    }

    // Volumen = área * espesor(metros)
    double volumen = area * (espesor / 100); // convertir espesor de cm a m

    // Cantidad de agua con desperdicio
    totalAgua += volumen * factorAgua * (1 + factorDesperdicio);
  }

  return totalAgua;
}

// FUNCIONES GENERALES QUE DECIDEN QUÉ TIPO DE CÁLCULO USAR
double calcularCantidadCementoPisos(List<Piso> pisos) {
  if (pisos.isEmpty) return 0.0;

  if (pisos.first.tipo == 'contrapiso') {
    return calcularCantidadCementoPisosContrapiso(pisos);
  } else { // falso piso
    return calcularCantidadCementoPisosFalso(pisos);
  }
}

double calcularCantidadArenaGruesa(List<Piso> pisos) {
  if (pisos.isEmpty) return 0.0;

  if (pisos.first.tipo == 'contrapiso') {
    return calcularCantidadArenaGruesaContrapiso(pisos);
  } else { // falso piso
    return calcularCantidadArenaGruesaFalso(pisos);
  }
}

double calcularCantidadPiedraChancada(List<Piso> pisos) {
  if (pisos.isEmpty || pisos.first.tipo != 'falso') return 0.0;
  return calcularCantidadPiedraChancadaFalso(pisos);
}

double calcularCantidadAguaPisos(List<Piso> pisos) {
  if (pisos.isEmpty) return 0.0;

  if (pisos.first.tipo == 'contrapiso') {
    return calcularCantidadAguaContrapiso(pisos);
  } else { // falso piso
    return calcularCantidadAguaFalso(pisos);
  }
}