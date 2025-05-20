import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../data/models/models.dart';
import '../../../../../providers/providers.dart';
import '../../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultLadrilloScreen extends ConsumerWidget {
  const ResultLadrilloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
          context.hideLoader();
      });
    });

    return WillPopScope(
      onWillPop: () async {
        ref.read(ladrilloResultProvider.notifier).clearList();
        ref.read(bloquetaResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado'),
        body: const _ResultLadrilloScreenView(),
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
              heroTag: 'save_button_wall',
              onPressed: () {
                final listaLadrillo = ref.watch(ladrilloResultProvider);
                final listaBloqueta = ref.watch(bloquetaResultProvider);
                if (listaLadrillo.isNotEmpty) {
                  context.pushNamed('save-ladrillo');
                } else {
                  context.pushNamed('save-bloqueta');
                }
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_wall',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            final listaLadrillo = ref.watch(ladrilloResultProvider);
            final listaBloqueta = ref.watch(bloquetaResultProvider);
            if (listaLadrillo.isNotEmpty) {
              context.pushNamed('map-screen-2');
            } else {
              context.pushNamed('map-screen-1');
            }
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
                final pdfFile = await generatePdf(ref);
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
    final listaLadrillo = ref.watch(ladrilloResultProvider);
    final listaBloqueta = ref.watch(bloquetaResultProvider);

    String cantidadPruebaLadToString = calcularCantidadMaterial(listaLadrillo, calcularLadrillos).toStringAsFixed(2);
    String cantidadPruebaAreToString = calcularCantidadMaterial(listaLadrillo, calcularArena).toStringAsFixed(2);
    String cantidadPruebaCemToString = calcularCantidadMaterial(listaLadrillo, calcularCemento).ceilToDouble().toString();

    String cantidadBloquetasToString = cantidadBloquetas(listaBloqueta).toStringAsFixed(2);
    String cantidadArenaToString = cantidadArena(listaBloqueta).toStringAsFixed(2);
    String cantidadCementoToString = cantidadCemento(listaBloqueta).ceilToDouble().toString();

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    if (listaLadrillo.isNotEmpty) {
      final datosLadrillo = ref.watch(datosShareLadrilloProvider);
      final shareText = '$datosMetrado \n$datosLadrillo \n-------------\n$listaMateriales \n*Arena gruesa: $cantidadPruebaAreToString m3 \n*Cemento: $cantidadPruebaCemToString bls \n*Ladrillo: $cantidadPruebaLadToString und';
      return shareText;
    } else if (listaBloqueta.isNotEmpty) {
      final datosBloqueta = ref.watch(datosShareBloquetaProvider);
      final shareText = '$datosMetrado \n$datosBloqueta \n-------------\n$listaMateriales \n*Arena gruesa: $cantidadArenaToString m3 \n*Cemento: $cantidadCementoToString bls \n*Bloqueta: $cantidadBloquetasToString und';
      return shareText;
    } else {
      return 'Error';
    }
  }
}

class _ResultLadrilloScreenView extends ConsumerWidget {
  const _ResultLadrilloScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaLadrillo = ref.watch(ladrilloResultProvider);
    final listaBloqueta = ref.watch(bloquetaResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10,),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10,),
          if (listaLadrillo.isNotEmpty || listaBloqueta.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              listaLadrillo.isNotEmpty
                  ? const _LadrilloContainer()
                  : const _BloquetaContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              listaLadrillo.isNotEmpty
                  ? _buildMaterialList(ref)
                  : _buildMaterialList(ref),
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
    final listaLadrillo = ref.watch(ladrilloResultProvider);

    // Calcular cantidades totales usando las funciones actualizadas
    final cantidadLadrillos = calcularCantidadMaterial(listaLadrillo, calcularLadrillos).toStringAsFixed(0);
    final cantidadArenaTotal = calcularCantidadMaterial(listaLadrillo, calcularArena).toStringAsFixed(2);
    final cantidadCementoTotal = calcularCantidadMaterial(listaLadrillo, calcularCemento).ceilToDouble().toString();
    final cantidadAguaTotal = calcularCantidadMaterial(listaLadrillo, calcularAgua).toStringAsFixed(2);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadCementoTotal),
        _buildMaterialRow('Arena gruesa', 'm3', cantidadArenaTotal),
        _buildMaterialRow('Agua', 'm3', cantidadAguaTotal),
        _buildMaterialRow('Ladrillo', 'Und', cantidadLadrillos),
      ],
    );
  }

  /*Widget _buildMaterialList({
    required String cantidadPruebaLadToString,
    required String cantidadPruebaAreToString,
    required String cantidadPruebaCemToString,
  }) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadPruebaCemToString),
        _buildMaterialRow('Arena fina', 'm3', cantidadPruebaAreToString),
        _buildMaterialRow('Ladrillo', 'Und', cantidadPruebaLadToString),
      ],
    );
  }*/

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

class _BloquetaContainer extends ConsumerWidget {
  const _BloquetaContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(bloquetaResultProvider);

    return _buildBloquetaContainer(context, results);
  }

  Widget _buildBloquetaContainer(BuildContext context, List<Bloqueta> results) {

    double calcularArea(Bloqueta bloqueta) {
      if (bloqueta.area != null && bloqueta.area!.isNotEmpty) {
        return double.tryParse(bloqueta.area!) ?? 0.0; // Si es área
      } else {
        final largo = double.tryParse(bloqueta.largo ?? '') ?? 0.0;
        final altura = double.tryParse(bloqueta.altura ?? '') ?? 0.0;
        return largo * altura; // Si es largo y altura
      }
    }

    double calcularSumaTotalDeAreas(List<Bloqueta> results) {
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
          2: FlexColumnWidth(2), // Ancho fijo para la tercera columna
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

class _LadrilloContainer extends ConsumerWidget {
  const _LadrilloContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(ladrilloResultProvider);

    return _buildLadrilloContainer(context, results);
  }

  Widget _buildLadrilloContainer(BuildContext context, List<Ladrillo> results) {
    double calcularArea(Ladrillo ladrillo) {
      if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
        return double.tryParse(ladrillo.area!) ?? 0.0; // Si es área
      } else {
        final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
        final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
        return largo * altura; // Si es largo y altura
      }
    }

    // Calcular la suma total de todas las áreas
    double calcularSumaTotalDeAreas(List<Ladrillo> results) {
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
          2: FlexColumnWidth(2), // Ancho fijo para la tercera columna
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
                    calcularArea(result).toStringAsFixed(2), // Mostrar el área calculada
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


Future<File> generatePdf(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaLadrillo = ref.watch(ladrilloResultProvider);
  final listaBloqueta = ref.watch(bloquetaResultProvider);

  String title = listaLadrillo.isNotEmpty ? 'Resultados de Ladrillo' : 'Resultados de Bloqueta';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            if (listaLadrillo.isNotEmpty) ...[
              pw.Text('Ladrillos: ${calcularCantidadMaterial(listaLadrillo, calcularLadrillos).toStringAsFixed(2)}'),
              pw.Text('Arena: ${calcularCantidadMaterial(listaLadrillo, calcularArena).toStringAsFixed(2)} m3'),
              pw.Text('Cemento: ${calcularCantidadMaterial(listaLadrillo, calcularCemento).ceilToDouble()} bls'),
            ] else if (listaBloqueta.isNotEmpty) ...[
              pw.Text('Bloquetas: ${cantidadBloquetas(listaBloqueta).toStringAsFixed(2)}'),
              pw.Text('Arena: ${cantidadArena(listaBloqueta).toStringAsFixed(2)} m3'),
              pw.Text('Cemento: ${cantidadCemento(listaBloqueta).ceilToDouble()} bls'),
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

// Función para obtener el área de un muro
double obtenerAreaLadrillo(Ladrillo ladrillo) {
  if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
    return double.tryParse(ladrillo.area!) ?? 0.0;
  } else {
    double largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
    double altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
    return largo * altura;
  }
}

// Función para calcular la cantidad de material basado en una función específica
double calcularCantidadMaterial(List<Ladrillo> results, double Function(Ladrillo) calcular) {
  return results.fold(0.0, (suma, ladrillo) => suma + calcular(ladrillo));
}

// FUNCIÓN ACTUALIZADA: Calcular ladrillos según el Excel analizado
double calcularLadrillos(Ladrillo ladrillo) {
  double area = obtenerAreaLadrillo(ladrillo);
  double factorDesperdicio = (double.tryParse(ladrillo.factorDesperdicio ?? '') ?? 0.0) / 100;

  // Ancho de juntas estándar (1.5 cm)
  const juntaHorizontal = 0.015; // metros
  const juntaVertical = 0.015; // metros

  // Calcular la cantidad de ladrillos según el tipo y forma de asentado
  double ladrillosPorM2;

  switch (ladrillo.tipoLadrillo) {
    case 'Kingkong':
    // Dimensiones King Kong: 24 x 13 x 9 cm
      if (ladrillo.tipoAsentado == 'soga') {
        // Longitud: 24cm, Altura: 9cm
        ladrillosPorM2 = 1 / ((0.24 + juntaVertical) * (0.09 + juntaHorizontal));
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        // Longitud: 13cm, Altura: 9cm
        ladrillosPorM2 = 1 / ((0.13 + juntaVertical) * (0.09 + juntaHorizontal));
      } else { // canto
        // Longitud: 24cm, Altura: 13cm
        ladrillosPorM2 = 1 / ((0.24 + juntaVertical) * (0.13 + juntaHorizontal));
      }
      break;

    case 'Pandereta':
    // Dimensiones Pandereta: 23 x 12 x 9 cm
      if (ladrillo.tipoAsentado == 'soga') {
        // Longitud: 23cm, Altura: 9cm
        ladrillosPorM2 = 1 / ((0.23 + juntaVertical) * (0.09 + juntaHorizontal));
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        // Longitud: 12cm, Altura: 9cm
        ladrillosPorM2 = 1 / ((0.12 + juntaVertical) * (0.09 + juntaHorizontal));
      } else { // canto
        // Longitud: 23cm, Altura: 12cm
        ladrillosPorM2 = 1 / ((0.23 + juntaVertical) * (0.12 + juntaHorizontal));
      }
      break;

    case 'Artesanal':
    // Dimensiones Artesanal: 22 x 12.5 x 7.5 cm
      if (ladrillo.tipoAsentado == 'soga') {
        // Longitud: 22cm, Altura: 7.5cm
        ladrillosPorM2 = 1 / ((0.22 + juntaVertical) * (0.075 + juntaHorizontal));
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        // Longitud: 12.5cm, Altura: 7.5cm
        ladrillosPorM2 = 1 / ((0.125 + juntaVertical) * (0.075 + juntaHorizontal));
      } else { // canto
        // Longitud: 22cm, Altura: 12.5cm
        ladrillosPorM2 = 1 / ((0.22 + juntaVertical) * (0.125 + juntaHorizontal));
      }
      break;

    default:
    // Usar valores de King Kong por defecto
      if (ladrillo.tipoAsentado == 'soga') {
        ladrillosPorM2 = 1 / ((0.24 + juntaVertical) * (0.09 + juntaHorizontal));
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        ladrillosPorM2 = 1 / ((0.13 + juntaVertical) * (0.09 + juntaHorizontal));
      } else { // canto
        ladrillosPorM2 = 1 / ((0.24 + juntaVertical) * (0.13 + juntaHorizontal));
      }
  }

  // Aplicar factor de desperdicio y multiplicar por área
  return ladrillosPorM2 * (1 + factorDesperdicio) * area;
}

// Función auxiliar para calcular el volumen de mortero por muro
double calcularVolumenMortero(Ladrillo ladrillo) {
  double area = obtenerAreaLadrillo(ladrillo);

  // Determinar espesor de muro según tipo de ladrillo y tipo de asentado
  double espesor = 0.0;

  switch (ladrillo.tipoLadrillo) {
    case 'Kingkong':
    // Dimensiones King Kong: 24 x 13 x 9 cm
      if (ladrillo.tipoAsentado == 'soga') {
        espesor = 0.13; // ancho
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        espesor = 0.24; // largo
      } else { // canto
        espesor = 0.09; // alto
      }
      break;

    case 'Pandereta':
    // Dimensiones Pandereta: 23 x 12 x 9 cm
      if (ladrillo.tipoAsentado == 'soga') {
        espesor = 0.12; // ancho
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        espesor = 0.23; // largo
      } else { // canto
        espesor = 0.09; // alto
      }
      break;

    case 'Artesanal':
    // Dimensiones Artesanal: 22 x 12.5 x 7.5 cm
      if (ladrillo.tipoAsentado == 'soga') {
        espesor = 0.125; // ancho
      } else if (ladrillo.tipoAsentado == 'cabeza') {
        espesor = 0.22; // largo
      } else { // canto
        espesor = 0.075; // alto
      }
      break;

    default:
    // Usar valores por defecto (King Kong soga)
      espesor = 0.13;
  }

  // Calcular volumen bruto del muro (m³)
  double volumenBruto = area * espesor;

  // Calcular volumen ocupado por ladrillos
  double volumenLadrillo;

  switch (ladrillo.tipoLadrillo) {
    case 'Kingkong':
      volumenLadrillo = 0.24 * 0.13 * 0.09; // largo * ancho * alto
      break;
    case 'Pandereta':
      volumenLadrillo = 0.23 * 0.12 * 0.09; // largo * ancho * alto
      break;
    case 'Artesanal':
      volumenLadrillo = 0.22 * 0.125 * 0.075; // largo * ancho * alto
      break;
    default:
      volumenLadrillo = 0.24 * 0.13 * 0.09; // Usar King Kong por defecto
  }

  // Sin considerar el factor de desperdicio para número base de ladrillos
  double ladrillosSinDesperdicio = calcularLadrillos(ladrillo) / (1 + (double.tryParse(ladrillo.factorDesperdicio ?? '') ?? 0.0) / 100);

  // Volumen ocupado por los ladrillos
  double volumenLadrillos = ladrillosSinDesperdicio * volumenLadrillo;

  // Volumen de mortero = Volumen bruto - Volumen ladrillos
  return volumenBruto - volumenLadrillos;
}

// FUNCIÓN ACTUALIZADA: Calcular cemento según Excel analizado
double calcularCemento(Ladrillo ladrillo) {
  // Obtener volumen de mortero para el muro
  double volumenMortero = calcularVolumenMortero(ladrillo);

  // Factor de desperdicio
  double factorDesperdicio = (double.tryParse(ladrillo.factorDesperdicio ?? '') ?? 0.0) / 100;

  // Cantidad de cemento según proporción de mortero
  double cementoPorM3; // Bolsas por m³ de mortero

  switch (ladrillo.proporcionMortero) {
    case '3': // 1:3
      cementoPorM3 = 454 / 42.5; // 454 kg / 42.5 kg por bolsa
      break;
    case '4': // 1:4
      cementoPorM3 = 364 / 42.5; // 364 kg / 42.5 kg por bolsa
      break;
    case '5': // 1:5
      cementoPorM3 = 302 / 42.5; // 302 kg / 42.5 kg por bolsa
      break;
    case '6': // 1:6
      cementoPorM3 = 261 / 42.5; // 261 kg / 42.5 kg por bolsa
      break;
    default:  // Usar 1:4 por defecto
      cementoPorM3 = 364 / 42.5;
  }

  // Calcular cantidad de cemento para el volumen de mortero
  double cemento = cementoPorM3 * volumenMortero;

  // Aplicar factor de desperdicio
  return cemento * (1 + factorDesperdicio);
}

// FUNCIÓN ACTUALIZADA: Calcular arena según Excel analizado
double calcularArena(Ladrillo ladrillo) {
  // Obtener volumen de mortero para el muro
  double volumenMortero = calcularVolumenMortero(ladrillo);

  // Factor de desperdicio
  double factorDesperdicio = (double.tryParse(ladrillo.factorDesperdicio ?? '') ?? 0.0) / 100;

  // Cantidad de arena según proporción de mortero
  double arenaPorM3; // m³ de arena por m³ de mortero

  switch (ladrillo.proporcionMortero) {
    case '3': // 1:3
      arenaPorM3 = 1.10;
      break;
    case '4': // 1:4
      arenaPorM3 = 1.16;
      break;
    case '5': // 1:5
      arenaPorM3 = 1.20;
      break;
    case '6': // 1:6
      arenaPorM3 = 1.20;
      break;
    default:  // Usar 1:4 por defecto
      arenaPorM3 = 1.16;
  }

  // Calcular cantidad de arena para el volumen de mortero
  double arena = arenaPorM3 * volumenMortero;

  // Aplicar factor de desperdicio
  return arena * (1 + factorDesperdicio);
}

// NUEVA FUNCIÓN: Calcular agua según Excel analizado
double calcularAgua(Ladrillo ladrillo) {
  // Obtener volumen de mortero para el muro
  double volumenMortero = calcularVolumenMortero(ladrillo);

  // Factor de desperdicio
  double factorDesperdicio = (double.tryParse(ladrillo.factorDesperdicio ?? '') ?? 0.0) / 100;

  // Cantidad de agua según proporción de mortero
  double aguaPorM3; // Litros por m³ de mortero

  switch (ladrillo.proporcionMortero) {
    case '3': // 1:3
      aguaPorM3 = 250;
      break;
    case '4': // 1:4
      aguaPorM3 = 240;
      break;
    case '5': // 1:5
      aguaPorM3 = 240;
      break;
    case '6': // 1:6
      aguaPorM3 = 235;
      break;
    default:  // Usar 1:4 por defecto
      aguaPorM3 = 240;
  }

  // Convertir litros a m³ y calcular para el volumen de mortero
  double agua = (aguaPorM3 / 1000) * volumenMortero;

  // Aplicar factor de desperdicio
  return agua * (1 + factorDesperdicio);
}

double calcularAsentado(String tipoAsentado, double area, double soga, double canto, [double cabeza = 0]) {
  switch (tipoAsentado) {
    case 'soga':
      return area * soga;
    case 'canto':
      return area * canto;
    case 'cabeza':
      return area * cabeza;
    default:
      return 0;
  }
}

double calcularCantidadBloquetas(String tipoBloqueta, double area) {
  switch (tipoBloqueta) {
    case 'P7':
    case 'P10':
    case 'P12':
      return area * 8 * (1 + 0.07);
    default:
      return 0;
  }
}

double calcularCantidadArena(String tipoBloqueta, double area) {
  switch (tipoBloqueta) {
    case 'P7':
      return area * 0.0059;
    case 'P10':
      return area * 0.0085;
    case 'P12':
      return area * 0.0102;
    default:
      return 0;
  }
}

double calcularCantidadCemento(String tipoBloqueta, double area) {
  switch (tipoBloqueta) {
    case 'P7':
      return area * 0.052;
    case 'P10':
      return area * 0.075;
    case 'P12':
      return area * 0.0901;
    default:
      return 0;
  }
}

double cantidadBloquetas(List<Bloqueta> results) {
  double sumaDeBloquetas = 0.0;
  for (Bloqueta bloqueta in results) {
    double area = obtenerAreaBloqueta(bloqueta); // Obtener el área (ya sea ingresada o calculada)

    sumaDeBloquetas += calcularCantidadBloquetas(bloqueta.tipoBloqueta, area);
  }
  return sumaDeBloquetas;
}

double cantidadArena(List<Bloqueta> results) {
  double sumaDeArena = 0.0;
  for (Bloqueta bloqueta in results) {
    double area = obtenerAreaBloqueta(bloqueta); // Obtener el área (ya sea ingresada o calculada)

    sumaDeArena += calcularCantidadArena(bloqueta.tipoBloqueta, area);
  }
  return sumaDeArena;
}

double cantidadCemento(List<Bloqueta> results) {
  double sumaDeCemento = 0.0;
  for (Bloqueta bloqueta in results) {
    double area = obtenerAreaBloqueta(bloqueta); // Obtener el área (ya sea ingresada o calculada)

    sumaDeCemento += calcularCantidadCemento(bloqueta.tipoBloqueta, area);
  }
  return sumaDeCemento;
}

double obtenerAreaBloqueta(Bloqueta bloqueta) {
  if (bloqueta.area != null && bloqueta.area!.isNotEmpty) {
    return double.tryParse(bloqueta.area!) ?? 0.0; // Usar área si está disponible
  } else {
    double largo = double.tryParse(bloqueta.largo ?? '') ?? 0.0;
    double altura = double.tryParse(bloqueta.altura ?? '') ?? 0.0;
    return largo * altura; // Calcular área usando largo y altura
  }
}
