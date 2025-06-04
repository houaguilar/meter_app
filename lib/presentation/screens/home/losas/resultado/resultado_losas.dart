import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/losas/losas.dart';
import '../../../../assets/icons.dart';
import '../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';

import 'package:pdf/widgets.dart' as pw;

class ResultLosasScreen extends ConsumerWidget {
  const ResultLosasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(losaAligeradaResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado Losa Aligerada'),
        body: const _ResultLosasScreenView(),
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
              heroTag: 'save_button_losa',
              onPressed: () {
                context.pushNamed('save-losas');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_losa',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed('map-screen-losas');
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
                final pdfFile = await generatePdfLosa(ref);
                final xFile = XFile(pdfFile.path);
                Share.shareXFiles([xFile], text: 'Resultados del metrado de losa aligerada.');
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
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);

    // Solo los 4 materiales principales
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider).toStringAsFixed(2);

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    if (losasAligeradas.isNotEmpty) {
      final datosLosa = ref.watch(datosShareLosaAligeradaProvider);
      final shareText = '$datosMetrado\n$datosLosa\n-------------\n$listaMateriales\n'
          '* Cemento: $cantidadCemento bls\n'
          '* Arena gruesa: $cantidadArena m³\n'
          '* Piedra chancada: $cantidadPiedra m³\n'
          '* Agua: $cantidadAgua m³\n'
          '\n* Calculado con fórmulas del Excel CALCULO DE MATERIALES POR PARTIDAss.xlsx';
      return shareText;
    } else {
      return 'Error: No hay datos de losas aligeradas';
    }
  }
}

class _ResultLosasScreenView extends ConsumerWidget {
  const _ResultLosasScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),
          if (losasAligeradas.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _LosaAligeradaContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialList(ref),
            ),
            const SizedBox(height: 20),
            _buildInfoCard(context, ref),
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

  Widget _buildMaterialList(WidgetRef ref) {
    // Solo los 4 materiales principales
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider).toStringAsFixed(2);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadCemento),
        _buildMaterialRow('Arena gruesa', 'm³', cantidadArena),
        _buildMaterialRow('Piedra chancada', 'm³', cantidadPiedra),
        _buildMaterialRow('Agua', 'm³', cantidadAgua),
      ],
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
          child: Text(description, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(unit, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(amount, style: textStyle),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, WidgetRef ref) {
    final losasAligeradas = ref.watch(losaAligeradaResultProvider);
    final volumenConcreto = ref.watch(volumenConcretoLosaAligeradaProvider);

    if (losasAligeradas.isEmpty) return const SizedBox.shrink();

    final primeraLosa = losasAligeradas.first;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blueMetraShop, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Información del Cálculo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Altura de losa:', primeraLosa.altura),
            _buildInfoRow('Material aligerado:', primeraLosa.materialAligerado),
            _buildInfoRow('Resistencia concreto:', primeraLosa.resistenciaConcreto),
            _buildInfoRow('Desperdicio concreto:', '${primeraLosa.desperdicioConcreto}%'),
            _buildInfoRow('Volumen total concreto:', '${volumenConcreto.toStringAsFixed(2)} m³'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blueMetraShop.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '* Cálculos basados en fórmulas del archivo Excel "CALCULO DE MATERIALES POR PARTIDAss.xlsx"\n* El volumen de concreto se calcula como ~40% del volumen total de la losa',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryMetraShop,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryMetraShop,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LosaAligeradaContainer extends ConsumerWidget {
  const _LosaAligeradaContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(losaAligeradaResultProvider);
    return _buildLosaAligeradaContainer(context, results);
  }

  Widget _buildLosaAligeradaContainer(BuildContext context, List<LosaAligerada> results) {
    double calcularArea(LosaAligerada losaAligerada) {
      if (losaAligerada.area != null && losaAligerada.area!.isNotEmpty) {
        return double.tryParse(losaAligerada.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(losaAligerada.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(losaAligerada.ancho ?? '') ?? 0.0;
        return largo * ancho;
      }
    }

    double calcularSumaTotalDeAreas(List<LosaAligerada> results) {
      double sumaTotal = 0.0;
      for (int i = 0; i < results.length; i++) {
        sumaTotal += calcularArea(results[i]);
      }
      return sumaTotal;
    }

    double sumaTotalDeAreas = calcularSumaTotalDeAreas(results);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
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
                  'Área',
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
                    'm²',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    calcularArea(result).toStringAsFixed(2),
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
                  'm²',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sumaTotalDeAreas.toStringAsFixed(2),
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

Future<File> generatePdfLosa(WidgetRef ref) async {
  final pdf = pw.Document();
  final losasAligeradas = ref.watch(losaAligeradaResultProvider);

  // Solo los 4 materiales principales
  final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
  final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider).toStringAsFixed(2);
  final volumenConcreto = ref.watch(volumenConcretoLosaAligeradaProvider).toStringAsFixed(2);

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título
          pw.Center(
            child: pw.Text(
              "Resultados Losa Aligerada",
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 30),

          // Información del cálculo
          if (losasAligeradas.isNotEmpty) ...[
            pw.Text(
              "INFORMACIÓN DEL CÁLCULO",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text('• Altura de losa: ${losasAligeradas.first.altura}'),
            pw.Text('• Material aligerado: ${losasAligeradas.first.materialAligerado}'),
            pw.Text('• Resistencia concreto: ${losasAligeradas.first.resistenciaConcreto}'),
            pw.Text('• Desperdicio concreto: ${losasAligeradas.first.desperdicioConcreto}%'),
            pw.Text('• Volumen total concreto: $volumenConcreto m³'),
            pw.SizedBox(height: 30),
          ],

          // Lista de materiales
          pw.Text(
            "LISTA DE MATERIALES",
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('• Cemento: $cantidadCemento bls'),
          pw.Text('• Arena gruesa: $cantidadArena m³'),
          pw.Text('• Piedra chancada: $cantidadPiedra m³'),
          pw.Text('• Agua: $cantidadAgua m³'),
          pw.SizedBox(height: 30),

          // Nota pie de página
          pw.Text(
            "NOTAS:",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "• Cálculos basados en fórmulas del archivo Excel 'CALCULO DE MATERIALES POR PARTIDAss.xlsx'",
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "• El volumen de concreto se calcula como aproximadamente 40% del volumen total de la losa",
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.Text(
            "• Los desperdicios están incluidos en las cantidades mostradas",
            style: const pw.TextStyle(fontSize: 10),
          ),

          pw.Spacer(),
          pw.Center(
            child: pw.Text(
              "Generado por MetraShop - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_losa_aligerada.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}