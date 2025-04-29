
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../../data/models/models.dart';
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

  Widget _buildActionButton(BuildContext context, WidgetRef ref, {required String label, required IconData icon, required VoidCallback onPressed}) {
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

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text('Se guardó exitosamente'),
        action: SnackBarAction(label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  String _shareContent(WidgetRef ref) {
    final listaPisos = ref.watch(pisosResultProvider);

    String cantidadPiedraChancadaToString = cantidadPiedraChancada(listaPisos).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(listaPisos).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(listaPisos).ceilToDouble().toString();

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    if (listaPisos.isNotEmpty) {
      final datosLadrillo = ref.watch(datosSharePisosProvider);
      final shareText = '$datosMetrado \n$datosLadrillo \n-------------\n$listaMateriales \n*Arena gruesa: $cantidadArenaToString m3 \n*Cemento: $cantidadCementoToString bls \n${listaPisos.first.tipo == 'contrapiso' ? '*Piedra chancada: $cantidadPiedraChancadaToString m3' : ''}';
      return shareText;
    } else {
      return 'Error';
    }
  }
}

class _ResultPisosScreenView extends ConsumerWidget {
  const _ResultPisosScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final listaPisos = ref.watch(pisosResultProvider);
    print(listaPisos);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 6,),
          const Text('Resumen del metrado', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryMetraShop),),
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
              _buildMaterialList(
                cantidadPruebaLadToString: cantidadPiedraChancada(listaPisos)
                    .toStringAsFixed(2),
                cantidadPruebaAreToString: cantidadArenaGruesa(listaPisos)
                    .toStringAsFixed(2),
                cantidadPruebaCemToString: cantidadCementoPisos(listaPisos)
                    .ceilToDouble()
                    .toString(),
                lista: listaPisos,
              ),
            ),
          ],
          /*Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: AppColors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              ),
              icon: const Icon(Icons.search_rounded),
              label: const Text(
                "Buscar Ferreterías",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.goNamed('mapa');
              },
            ),
          ),*/
          const SizedBox(height: 200,)
        ],
      ),
    );

    /*String cantidadPiedraChancadaToString = cantidadPiedraChancada(listaPisos).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(listaPisos).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(listaPisos).ceilToDouble().toString();

    return Column(
      children: [
        const Expanded(
          child: _PisosContainer(),
        ),
        MaterialButton(
          onPressed: () {
            ref.watch(cantidadArenaPisosProvider);
            ref.watch(cantidadCementoPisosProvider);
            ref.watch(cantidadPiedraChancadaProvider);

            if (listaPisos.first.tipo == 'contrapiso') {
              ref.read(cantidadArenaPisosProvider.notifier).arena(cantidadArenaToString);
              ref.read(cantidadCementoPisosProvider.notifier).cemento(cantidadCementoToString);
            } else {
              ref.read(cantidadArenaPisosProvider.notifier).arena(cantidadArenaToString);
              ref.read(cantidadCementoPisosProvider.notifier).cemento(cantidadCementoToString);
              ref.read(cantidadPiedraChancadaProvider.notifier).piedra(cantidadPiedraChancadaToString);
            }
            context.goNamed('pisos-pdf');
          },
          color: AppColors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          height: 50,
          minWidth: 200,
          child: const Text("Generar PDF",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );*/
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

  Widget _buildMaterialList({
    required String cantidadPruebaLadToString,
    required String cantidadPruebaAreToString,
    required String cantidadPruebaCemToString,
    required List<Piso> lista,
  }) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'm2', cantidadPruebaCemToString),
        _buildMaterialRow('Arena gruesa', 'm3 / Bls.', cantidadPruebaAreToString),
        if (lista.first.tipo != 'contrapiso')
          _buildMaterialRow('Piedra chancada', 'Und', cantidadPruebaLadToString),
      ],
    );
  }

  TableRow _buildMaterialRow(String description, String unit, String amount,
      {bool isHeader = false}) {
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
    print(results);
    return _buildPisosContainer(context, results);
  }

  Widget _buildPisosContainer(BuildContext context, List<Piso> results) {
    double calcularVolumen(Piso piso) {
      if (piso.area != null && piso.area!.isNotEmpty) {
        final espesor = double.tryParse(piso.espesor) ?? 0.0;
        final area = double.tryParse(piso.area!) ?? 0.0;
        return area * espesor; // Si es área
      } else {
        final espesor = double.tryParse(piso.espesor) ?? 0.0;
        final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
        return largo * ancho * espesor; // Si es largo y altura
      }
    }

    double calcularSumaTotalDeVolumenes(List<Piso> results) {
      double sumaTotal = 0.0;
      for (int i = 0; i < results.length; i++) {
        sumaTotal += calcularVolumen(results[i]);
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
                    'm3',
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
                  'm3',
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

    /*String cantidadPiedraChancadaToString = cantidadPiedraChancada(results).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArenaGruesa(results).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCementoPisos(results).ceilToDouble().toString();

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          const Text('Datos del Metrado', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const CommonContentResults(descripcion: '', unidad: 'UNIDAD', cantidad: 'CANTIDAD', sizeText: 16, weightText: FontWeight.w500),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return CommonContentResults(descripcion: results[index].description, unidad: 'm3', cantidad: volume(index).toString(), sizeText: 14, weightText: FontWeight.normal);
            },
            itemCount: results.length,
          ),
          const SizedBox(height: 20,),
          const Text('Lista de Materiales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const CommonContentResults(descripcion: '', unidad: 'UNIDAD', cantidad: 'CANTIDAD', sizeText: 16, weightText: FontWeight.w500),
          CommonContentResults(descripcion: 'ARENA GRUESA', unidad: 'm3', cantidad: cantidadArenaToString, sizeText: 14, weightText: FontWeight.normal),
          CommonContentResults(descripcion: 'CEMENTO', unidad: 'bls', cantidad: cantidadCementoToString, sizeText: 14, weightText: FontWeight.normal),
          Visibility(
            visible: results.first.tipo != 'contrapiso',
              child: CommonContentResults(descripcion: 'PIEDRA CHANCADA', unidad: 'm3', cantidad: cantidadPiedraChancadaToString, sizeText: 14, weightText: FontWeight.normal)
          ),
        ],
      ),
    );*/
  }
}

Future<File> generatePdfPiso(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaPiso = ref.watch(pisosResultProvider);

  String title = 'Resultados de Piso';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            if (listaPiso.first.tipo != 'contrapiso') ...[
              pw.Text('Piedra Chancada: ${cantidadPiedraChancada(listaPiso).toStringAsFixed(2)} m3'),
              pw.Text('Arena: ${cantidadArenaGruesa(listaPiso).toStringAsFixed(2)} m3'),
              pw.Text('Cemento: ${cantidadCementoPisos(listaPiso).ceilToDouble()} bls'),
            ] else ...[
              pw.Text('Arena: ${cantidadArenaGruesa(listaPiso).toStringAsFixed(2)} m3'),
              pw.Text('Cemento: ${cantidadCementoPisos(listaPiso).ceilToDouble()} bls'),
            ],
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

double obtenerAreaPisos(Piso piso) {
  if (piso.area != null && piso.area!.isNotEmpty) {
    return double.tryParse(piso.area!) ?? 0.0; // Usar área si está disponible
  } else {
    double largo = double.tryParse(piso.largo ?? '') ?? 0.0;
    double ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
    return largo * ancho; // Calcular área usando largo y altura
  }
}

double calcularCantidadPiedraChancada(String tipoPiso, double espesor, double area){
  switch (tipoPiso) {
    case 'falso':
      return espesor * area * 0.72 * 0.05;
    default:
      return 0;
  }
}

double calcularCantidadArenaGruesa(String tipoPiso, double espesor, double area) {
  switch (tipoPiso) {
    case 'falso':
      return espesor * area * 0.72 * 0.05;
    case 'contrapiso':
      return espesor * area * 1 * 0.05;
    default:
      return 0;
  }
}

double calcularCantidadCementoPisos(String tipoPiso, double espesor, double area) {
  switch (tipoPiso) {
    case 'falso':
      return espesor * area * 7.06 * 0.05;
    case 'contrapiso':
      return espesor * area * 7.4 * 0.05;
    default:
      return 0;
  }
}

double cantidadPiedraChancada(List<Piso> results) {
  double sumaDePiedras = 0.0;
  for (Piso piso in results) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor ?? '') ?? 0.0;

    sumaDePiedras += calcularCantidadPiedraChancada(piso.tipo, espesor, area);
  }
  return sumaDePiedras;
}

double cantidadArenaGruesa(List<Piso> results) {
  double sumaDeArena = 0.0;
  for (Piso piso in results) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor ?? '') ?? 0.0;

    sumaDeArena += calcularCantidadArenaGruesa(piso.tipo, espesor, area);
  }
  return sumaDeArena;
}

double cantidadCementoPisos(List<Piso> results) {
  double sumaDeCemento = 0.0;
  for (Piso piso in results) {
    double area = obtenerAreaPisos(piso);
    double espesor = double.tryParse(piso.espesor ?? '') ?? 0.0;

    sumaDeCemento += calcularCantidadCementoPisos(piso.tipo, espesor, area);
  }
  return sumaDeCemento;
}