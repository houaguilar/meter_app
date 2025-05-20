// lib/presentation/screens/home/losas/result_losas_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/constants/constants.dart';
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

    final cantidadLadrillos = ref.watch(cantidadLadrillosLosaAligeradaProvider).toStringAsFixed(0);
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAcero = ref.watch(cantidadAceroLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadMadera = ref.watch(cantidadMaderaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAlambre8 = ref.watch(cantidadAlambre8LosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAlambre16 = ref.watch(cantidadAlambre16LosaAligeradaProvider).toStringAsFixed(2);
    final cantidadClavos = ref.watch(cantidadClavosLosaAligeradaProvider).toStringAsFixed(2);

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    if (losasAligeradas.isNotEmpty) {
      final datosLosa = ref.watch(datosShareLosaAligeradaProvider);
      final shareText = '$datosMetrado\n$datosLosa\n-------------\n$listaMateriales\n'
          '* Ladrillos: $cantidadLadrillos und\n'
          '* Cemento: $cantidadCemento bls\n'
          '* Arena gruesa: $cantidadArena m3\n'
          '* Piedra chancada: $cantidadPiedra m3\n'
          '* Acero: $cantidadAcero kg\n'
          '* Madera: $cantidadMadera p2\n'
          '* Alambre #8: $cantidadAlambre8 kg\n'
          '* Alambre #16: $cantidadAlambre16 kg\n'
          '* Clavos: $cantidadClavos kg';
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
    final cantidadLadrillos = ref.watch(cantidadLadrillosLosaAligeradaProvider).toStringAsFixed(0);
    final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAcero = ref.watch(cantidadAceroLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadMadera = ref.watch(cantidadMaderaLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAlambre8 = ref.watch(cantidadAlambre8LosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAlambre16 = ref.watch(cantidadAlambre16LosaAligeradaProvider).toStringAsFixed(2);
    final cantidadClavos = ref.watch(cantidadClavosLosaAligeradaProvider).toStringAsFixed(2);
    final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider).toStringAsFixed(0);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Ladrillo', 'Und', cantidadLadrillos),
        _buildMaterialRow('Cemento', 'Bls', cantidadCemento),
        _buildMaterialRow('Arena gruesa', 'm3', cantidadArena),
        _buildMaterialRow('Piedra chancada', 'm3', cantidadPiedra),
        _buildMaterialRow('Agua', 'L', cantidadAgua),
        _buildMaterialRow('Acero', 'Kg', cantidadAcero),
        _buildMaterialRow('Madera', 'p2', cantidadMadera),
        _buildMaterialRow('Alambre #8', 'Kg', cantidadAlambre8),
        _buildMaterialRow('Alambre #16', 'Kg', cantidadAlambre16),
        _buildMaterialRow('Clavos', 'Kg', cantidadClavos),
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
        return double.tryParse(losaAligerada.area!) ?? 0.0; // Si es área
      } else {
        final largo = double.tryParse(losaAligerada.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(losaAligerada.ancho ?? '') ?? 0.0;
        return largo * ancho; // Si es largo y ancho
      }
    }

// lib/presentation/screens/home/losas/result_losas_screen.dart (continued)
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
                    'm2',
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
                  'm2',
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

  final cantidadLadrillos = ref.watch(cantidadLadrillosLosaAligeradaProvider).toStringAsFixed(0);
  final cantidadCemento = ref.watch(cantidadCementoLosaAligeradaProvider).ceilToDouble().toString();
  final cantidadArena = ref.watch(cantidadArenaGruesaLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadPiedra = ref.watch(cantidadPiedraChancadaLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadAcero = ref.watch(cantidadAceroLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadMadera = ref.watch(cantidadMaderaLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadAlambre8 = ref.watch(cantidadAlambre8LosaAligeradaProvider).toStringAsFixed(2);
  final cantidadAlambre16 = ref.watch(cantidadAlambre16LosaAligeradaProvider).toStringAsFixed(2);
  final cantidadClavos = ref.watch(cantidadClavosLosaAligeradaProvider).toStringAsFixed(2);
  final cantidadAgua = ref.watch(cantidadAguaLosaAligeradaProvider).toStringAsFixed(0);

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("Resultados Losa Aligerada", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Ladrillos: $cantidadLadrillos und'),
            pw.Text('Cemento: $cantidadCemento bls'),
            pw.Text('Arena gruesa: $cantidadArena m3'),
            pw.Text('Piedra chancada: $cantidadPiedra m3'),
            pw.Text('Agua: $cantidadAgua L'),
            pw.Text('Acero: $cantidadAcero kg'),
            pw.Text('Madera: $cantidadMadera p2'),
            pw.Text('Alambre #8: $cantidadAlambre8 kg'),
            pw.Text('Alambre #16: $cantidadAlambre16 kg'),
            pw.Text('Clavos: $cantidadClavos kg'),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_losa.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}