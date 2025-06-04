import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:pdf/widgets.dart' as pw;

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/home/piso/piso.dart';
import '../../../../../assets/icons.dart';
import '../../../../../providers/pisos/falso_piso_providers.dart';
import '../../../../../widgets/widgets.dart';

class ResultFalsoPisoScreen extends ConsumerWidget {
  const ResultFalsoPisoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(falsoPisoResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado Falso Piso'),
        body: const _ResultFalsoPisoScreenView(),
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
              heroTag: 'save_button_falso_piso',
              onPressed: () {
                context.pushNamed('falso-piso-save');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_falso_piso',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed('falso-piso-map-screen');
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
      heroTag: heroTag,
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
                Navigator.of(context).pop();
                final pdfFile = await generatePdfFalsoPiso(ref);
                final xFile = XFile(pdfFile.path);
                Share.shareXFiles([xFile], text: 'Resultados del metrado de falso piso.');
              },
            ),
            DialogOption(
              icon: Icons.text_fields,
              text: 'TEXTO',
              onTap: () async {
                Navigator.of(context).pop();
                await Share.share(_shareContent(ref));
              },
            ),
          ],
        );
      },
    );
  }

  String _shareContent(WidgetRef ref) {
    final listaFalsosPisos = ref.watch(falsoPisoResultProvider);
    final materiales = ref.watch(falsoPisoMaterialsProvider);
    final datosShare = ref.watch(datosShareFalsoPisoProvider);

    if (listaFalsosPisos.isEmpty) return 'Error: No hay datos disponibles.';

    String datosMetrado = 'DATOS METRADO - FALSO PISO';
    String listaMateriales = materiales.toShareString();

    return '$datosMetrado\n$datosShare\n-------------\n$listaMateriales';
  }
}

class _ResultFalsoPisoScreenView extends ConsumerWidget {
  const _ResultFalsoPisoScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaFalsosPisos = ref.watch(falsoPisoResultProvider);
    final materiales = ref.watch(falsoPisoMaterialsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),
          if (listaFalsosPisos.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _FalsoPisoContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialList(context, materiales),
            ),
          ],
          const SizedBox(height: 200)
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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMetraShop
              ),
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

  Widget _buildMaterialList(BuildContext context, FalsoPisoMaterials materiales) {
    final List<TableRow> rows = [
      _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
      _buildMaterialRow('Cemento', 'bls', materiales.cemento.ceil().toString()),
      _buildMaterialRow('Arena gruesa', 'm³', materiales.arena.toStringAsFixed(2)),
      _buildMaterialRow('Piedra chancada', 'm³', materiales.piedra.toStringAsFixed(2)),
      _buildMaterialRow('Agua', 'm³', materiales.agua.toStringAsFixed(2)),
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

class _FalsoPisoContainer extends ConsumerWidget {
  const _FalsoPisoContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(falsoPisoResultProvider);
    final volumenes = ref.watch(volumenFalsoPisoProvider);

    return _buildFalsoPisoContainer(context, results, volumenes);
  }

  Widget _buildFalsoPisoContainer(BuildContext context, List<Piso> results, List<double> volumenes) {
    double sumaTotal = volumenes.fold(0.0, (sum, volumen) => sum + volumen);

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
          for (int i = 0; i < results.length; i++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    results[i].description,
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
                    volumenes[i].toStringAsFixed(2),
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
                  sumaTotal.toStringAsFixed(2),
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

Future<File> generatePdfFalsoPiso(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaFalsosPisos = ref.watch(falsoPisoResultProvider);
  final materiales = ref.watch(falsoPisoMaterialsProvider);

  if (listaFalsosPisos.isEmpty) {
    throw Exception("No hay datos disponibles para generar el PDF");
  }

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
                'Resultados de Falso Piso',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)
            ),
            pw.SizedBox(height: 20),
            pw.Text('Volumen total: ${materiales.volumenTotal.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 15),
            pw.Text('LISTA DE MATERIALES:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Cemento: ${materiales.cemento.ceil()} bls'),
            pw.Text('Arena gruesa: ${materiales.arena.toStringAsFixed(2)} m³'),
            pw.Text('Piedra chancada: ${materiales.piedra.toStringAsFixed(2)} m³'),
            pw.Text('Agua: ${materiales.agua.toStringAsFixed(2)} m³'),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_falso_piso.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}