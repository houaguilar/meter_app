import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../../domain/entities/entities.dart';
import '../../../../assets/icons.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultTarrajeoScreen extends ConsumerWidget {
  const ResultTarrajeoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(tarrajeoResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado',),
        body: const _ResultTarrajeoScreenView(),
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
              heroTag: 'savee_button_coating',
              onPressed: () {
                context.pushNamed('save-tarrajeo');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_coating',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed('map-screen-tarrajeo');
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
                final pdfFile = await generatePdfTarrajeo(ref);
                final xFile = XFile(pdfFile.path);
                Share.shareXFiles([xFile], text: 'Resultados del metrado de tarrajeo.');
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
    final listaTarrajeo = ref.watch(tarrajeoResultProvider);
    if (listaTarrajeo.isEmpty) return 'Error: No hay datos disponibles.';

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';
    final datosShare = ref.watch(datosShareTarrajeoProvider);

    String cantidadArenaToString = calcularCantidadArena(listaTarrajeo).toStringAsFixed(2);
    String cantidadCementoToString = calcularCantidadCemento(listaTarrajeo).ceilToDouble().toString();
    String cantidadAguaToString = calcularCantidadAgua(listaTarrajeo).toStringAsFixed(2);

    return '$datosMetrado\n$datosShare\n-------------\n$listaMateriales\n'
        '*Arena fina: $cantidadArenaToString m3\n'
        '*Cemento: $cantidadCementoToString bls\n'
        '*Agua: $cantidadAguaToString m3';
  }
}

class _ResultTarrajeoScreenView extends ConsumerWidget {
  const _ResultTarrajeoScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaTarrajeo = ref.watch(tarrajeoResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10,),
          if (listaTarrajeo.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _TarrajeoContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialList(context, listaTarrajeo),
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

  Widget _buildMaterialList(BuildContext context, List<Tarrajeo> tarrajeos) {
    if (tarrajeos.isEmpty) return const SizedBox.shrink();

    final List<TableRow> rows = [
      _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
      _buildMaterialRow('Cemento', 'bls', calcularCantidadCemento(tarrajeos).ceil().toString()),
      _buildMaterialRow('Arena fina', 'm³', calcularCantidadArena(tarrajeos).toStringAsFixed(2)),
      _buildMaterialRow('Agua', 'm³', calcularCantidadAgua(tarrajeos).toStringAsFixed(2)),
    ];

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

class _TarrajeoContainer extends ConsumerWidget {
  const _TarrajeoContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(tarrajeoResultProvider);
    return _buildTarrajeoContainer(context, results);
  }

  Widget _buildTarrajeoContainer(BuildContext context, List<Tarrajeo> results) {
    double calcularVolumen(Tarrajeo tarrajeo) {
      if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
        final espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
        final area = double.tryParse(tarrajeo.area!) ?? 0.0;
        return area * (espesor / 100); // Convertir espesor de cm a m
      } else {
        final espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
        final longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
        final ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
        return longitud * ancho * (espesor / 100); // Convertir espesor de cm a m
      }
    }

    double calcularSumaTotalDeVolumenes(List<Tarrajeo> results) {
      double sumaTotal = 0.0;
      for (final tarrajeo in results) {
        sumaTotal += calcularVolumen(tarrajeo);
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

Future<File> generatePdfTarrajeo(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaTarrajeo = ref.watch(tarrajeoResultProvider);
  if (listaTarrajeo.isEmpty) {
    throw Exception("No hay datos disponibles para generar el PDF");
  }

  String title = 'Resultados de Tarrajeo';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Cemento: ${calcularCantidadCemento(listaTarrajeo).ceil()} bls'),
            pw.Text('Arena fina: ${calcularCantidadArena(listaTarrajeo).toStringAsFixed(2)} m³'),
            pw.Text('Agua: ${calcularCantidadAgua(listaTarrajeo).toStringAsFixed(2)} m³'),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_tarrajeo.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

// Función auxiliar para obtener el área
double obtenerAreaTarrajeo(Tarrajeo tarrajeo) {
  if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
    return double.tryParse(tarrajeo.area!) ?? 0.0; // Usar área si está disponible
  } else {
    double longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
    double ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
    return longitud * ancho; // Calcular área usando longitud y ancho
  }
}

// Función para calcular el volumen
double calcularVolumenTarrajeo(Tarrajeo tarrajeo) {
  double area = obtenerAreaTarrajeo(tarrajeo);
  double espesor = double.tryParse(tarrajeo.espesor) ?? 0.0;
  return area * (espesor / 100); // Convertir espesor de cm a m
}

// CÁLCULOS PARA TARRAJEO
double calcularCantidadCemento(List<Tarrajeo> tarrajeos) {
  double totalCemento = 0.0;
  for (var tarrajeo in tarrajeos) {
    double volumen = calcularVolumenTarrajeo(tarrajeo);
    double factorDesperdicio = double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero
    String proporcionStr = tarrajeo.proporcionMortero;
    int proporcion = int.tryParse(proporcionStr) ?? 4;

    // Factor de cemento según proporción (bolsas/m³)
    double factorCemento;
    switch (proporcion) {
      case 4: factorCemento = 8.50; break; // Aproximadamente 8.5 bolsas por m³ para 1:4
      case 5: factorCemento = 7.40; break; // Aproximadamente 7.4 bolsas por m³ para 1:5
      default: factorCemento = 8.50;      // Usar 1:4 como valor predeterminado
    }

    // Cantidad de cemento con desperdicio
    totalCemento += volumen * factorCemento * (1 + factorDesperdicio);
  }

  return totalCemento;
}

double calcularCantidadArena(List<Tarrajeo> tarrajeos) {
  double totalArena = 0.0;
  for (var tarrajeo in tarrajeos) {
    double volumen = calcularVolumenTarrajeo(tarrajeo);
    double factorDesperdicio = double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero
    String proporcionStr = tarrajeo.proporcionMortero;
    int proporcion = int.tryParse(proporcionStr) ?? 4;

    // Factor de arena según proporción (m³/m³)
    double factorArena;
    switch (proporcion) {
      case 4: factorArena = 1.05; break; // Aproximadamente 1.05 m³ de arena por m³ de mortero para 1:4
      case 5: factorArena = 1.16; break; // Aproximadamente 1.16 m³ de arena por m³ de mortero para 1:5
      default: factorArena = 1.05;      // Usar 1:4 como valor predeterminado
    }

    // Cantidad de arena con desperdicio
    totalArena += volumen * factorArena * (1 + factorDesperdicio);
  }

  return totalArena;
}

double calcularCantidadAgua(List<Tarrajeo> tarrajeos) {
  double totalAgua = 0.0;
  for (var tarrajeo in tarrajeos) {
    double volumen = calcularVolumenTarrajeo(tarrajeo);
    double factorDesperdicio = double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0;
    factorDesperdicio = factorDesperdicio / 100.0;

    // Proporción del mortero
    String proporcionStr = tarrajeo.proporcionMortero;
    int proporcion = int.tryParse(proporcionStr) ?? 4;

    // Factor de agua en m³ por m³ de mortero
    double factorAgua;
    switch (proporcion) {
      case 4: factorAgua = 0.27; break; // Aproximadamente 270 litros (0.27 m³) por m³ de mortero para 1:4
      case 5: factorAgua = 0.24; break; // Aproximadamente 240 litros (0.24 m³) por m³ de mortero para 1:5
      default: factorAgua = 0.27;      // Usar 1:4 como valor predeterminado
    }

    // Cantidad de agua con desperdicio
    totalAgua += volumen * factorAgua * (1 + factorDesperdicio);
  }

  return totalAgua;
}