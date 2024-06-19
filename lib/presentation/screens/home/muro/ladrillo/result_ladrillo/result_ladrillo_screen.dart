import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../data/models/models.dart';
import '../../../../../providers/providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultLadrilloScreen extends ConsumerWidget {
  const ResultLadrilloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(ladrilloResultProvider.notifier).clearList();
        ref.read(bloquetaResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: const AppBarWidget(titleAppBar: 'Resultados'),
        body: const _ResultLadrilloScreenView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButton(context, ref),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: constraints.maxWidth > 450
              ? _buildLargeScreenLayout(context, ref)
              : _buildSmallScreenLayout(context, ref),
        );
      },
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              tooltip: 'Compartir',
              onPressed: () async {
                _showOptionsDialog(context, ref);
              },
              heroTag: "btnShare",
              label: const Text('Compartir'),
              icon: const Icon(Icons.share_rounded),
            ),
            const SizedBox(width: 8),
            FloatingActionButton.extended(
              tooltip: 'Guardar resultados',
              onPressed: () {
                final listaLadrillo = ref.watch(ladrilloResultProvider);
                final listaBloqueta = ref.watch(bloquetaResultProvider);
                if (listaLadrillo.isNotEmpty) {
                  context.pushNamed('save-ladrillo');
                } else {
                  context.pushNamed('save-bloqueta');
                }
              },
              heroTag: "btnSave",
              label: const Text('Guardar'),
              icon: const Icon(Icons.add_box_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          onPressed: () {
            context.goNamed('mapa');
          },
          heroTag: "btnSearch",
          label: const Text('Buscar Ferreteria'),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          tooltip: 'Compartir',
          onPressed: () async {
            _showOptionsDialog(context, ref);
          },
          heroTag: "btnShare",
          label: const Text('Compartir'),
          icon: const Icon(Icons.share_rounded),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
          onPressed: () {
            context.goNamed('mapa');
          },
          heroTag: "btnSearch",
          label: const Text('Buscar Ferreteria'),
          icon: const Icon(Icons.search_rounded),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.extended(
          tooltip: 'Guardar resultados',
          onPressed: () {
            final listaLadrillo = ref.watch(ladrilloResultProvider);
            final listaBloqueta = ref.watch(bloquetaResultProvider);
            if (listaLadrillo.isNotEmpty) {
              context.pushNamed('save-ladrillo');
            } else if (listaBloqueta.isNotEmpty) {
              context.pushNamed('save-bloqueta');
            } else {
              return;
            }
          },
          heroTag: "btnSave",
          label: const Text('Guardar'),
          icon: const Icon(Icons.add_box_rounded),
        ),

      ],
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
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          if (listaLadrillo.isNotEmpty || listaBloqueta.isNotEmpty) ...[
            _buildCard(
              context,
              'Datos del Metrado',
              listaLadrillo.isNotEmpty ? const _LadrilloContainer() : const _BloquetaContainer(),
            ),
            const SizedBox(height: 20),
            _buildCard(
              context,
              'Lista de Materiales',
              listaLadrillo.isNotEmpty
                  ? _buildMaterialList(
                cantidadPruebaLadToString: calcularCantidadMaterial(listaLadrillo, calcularLadrillos).toStringAsFixed(2),
                cantidadPruebaAreToString: calcularCantidadMaterial(listaLadrillo, calcularArena).toStringAsFixed(2),
                cantidadPruebaCemToString: calcularCantidadMaterial(listaLadrillo, calcularCemento).ceilToDouble().toString(),
              )
                  : _buildMaterialList(
                cantidadPruebaLadToString: cantidadBloquetas(listaBloqueta).toStringAsFixed(2),
                cantidadPruebaAreToString: cantidadArena(listaBloqueta).toStringAsFixed(2),
                cantidadPruebaCemToString: cantidadCemento(listaBloqueta).ceilToDouble().toString(),
              ),
            ),
          ],
          const SizedBox(height: 20),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, Widget content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList({
    required String cantidadPruebaLadToString,
    required String cantidadPruebaAreToString,
    required String cantidadPruebaCemToString,
  }) {
    return Column(
      children: [
        const CommonContentResults(
          descripcion: '',
          unidad: 'UNIDAD',
          cantidad: 'CANTIDAD',
          sizeText: 16,
          weightText: FontWeight.w500,
        ),
        CommonContentResults(
          descripcion: 'ARENA GRUESA',
          unidad: 'm3',
          cantidad: cantidadPruebaAreToString,
          sizeText: 14,
          weightText: FontWeight.normal,
        ),
        CommonContentResults(
          descripcion: 'CEMENTO',
          unidad: 'bls',
          cantidad: cantidadPruebaCemToString,
          sizeText: 14,
          weightText: FontWeight.normal,
        ),
        CommonContentResults(
          descripcion: 'LADRILLO',
          unidad: 'und',
          cantidad: cantidadPruebaLadToString,
          sizeText: 14,
          weightText: FontWeight.normal,
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
    double areaMuro(int index) {
      return double.parse(results[index].largo) * double.parse(results[index].altura);
    }

    return Column(
      children: [
        const CommonContentResults(
          descripcion: '',
          unidad: 'UNIDAD',
          cantidad: 'CANTIDAD',
          sizeText: 16,
          weightText: FontWeight.w500,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return CommonContentResults(
              descripcion: results[index].description,
              unidad: 'm2',
              cantidad: areaMuro(index).toString(),
              sizeText: 14,
              weightText: FontWeight.normal,
            );
          },
          itemCount: results.length,
        ),
      ],
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
    double areaMuro(int index) {
      return double.parse(results[index].largo) * double.parse(results[index].altura);
    }

    return Column(
      children: [
        const CommonContentResults(
          descripcion: '',
          unidad: 'UNIDAD',
          cantidad: 'CANTIDAD',
          sizeText: 16,
          weightText: FontWeight.w500,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return CommonContentResults(
              descripcion: results[index].description,
              unidad: 'm2',
              cantidad: areaMuro(index).toString(),
              sizeText: 14,
              weightText: FontWeight.normal,
            );
          },
          itemCount: results.length,
        ),
      ],
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


double calcularCantidadMaterial(List<Ladrillo> results, double Function(Ladrillo) calcular) {
  return results.fold(0.0, (suma, ladrillo) => suma + calcular(ladrillo));
}

double calcularLadrillos(Ladrillo ladrillo) {
  double largo = double.parse(ladrillo.largo);
  double altura = double.parse(ladrillo.altura);

  switch (ladrillo.tipoLadrillo) {
    case 'Pandereta':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 36 * (1 + 0.07), 30 * (1 + 0.07));
    case 'Kingkong':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 39 * (1 + 0.07), 29 * (1 + 0.07), 68 * (1 + 0.07));
    default:
    //  return 0;
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.024, 0.014, 0.054);
  }
}

double calcularCemento(Ladrillo ladrillo) {
  double largo = double.parse(ladrillo.largo);
  double altura = double.parse(ladrillo.altura);

  switch (ladrillo.tipoLadrillo) {
    case 'Pandereta':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.19, 0.15);
    case 'Kingkong':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.21, 0.123, 0.48);
    default:
    //  return 0;
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.024, 0.014, 0.054);
  }
}

double calcularArena(Ladrillo ladrillo) {
  double largo = double.parse(ladrillo.largo);
  double altura = double.parse(ladrillo.altura);

  switch (ladrillo.tipoLadrillo) {
    case 'Pandereta':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.021, 0.017);
    case 'Kingkong':
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.024, 0.014, 0.054);
    default:
  //    return 0;
      return calcularAsentado(ladrillo.tipoAsentado, largo, altura, 0.024, 0.014, 0.054);
  }
}

double calcularAsentado(String tipoAsentado, double largo, double altura, double soga, double canto, [double cabeza = 0]) {
  switch (tipoAsentado) {
    case 'soga':
      return largo * altura * soga;
    case 'canto':
      return largo * altura * canto;
    case 'cabeza':
      return largo * altura * cabeza;
    default:
      return 0;
  }
}




double calcularCantidadBloquetas(String tipoBloqueta, double largo, double altura) {
  switch (tipoBloqueta) {
    case 'P7':
    case 'P10':
    case 'P12':
      return largo * altura * 8 * (1 + 0.07);
    default:
      return 0;
  }
}

double calcularCantidadArena(String tipoBloqueta, double largo, double altura) {
  switch (tipoBloqueta) {
    case 'P7':
      return largo * altura * 0.0059;
    case 'P10':
      return largo * altura * 0.0085;
    case 'P12':
      return largo * altura * 0.0102;
    default:
      return 0;
  }
}

double calcularCantidadCemento(String tipoBloqueta, double largo, double altura) {
  switch (tipoBloqueta) {
    case 'P7':
      return largo * altura * 0.052;
    case 'P10':
      return largo * altura * 0.075;
    case 'P12':
      return largo * altura * 0.0901;
    default:
      return 0;
  }
}

double cantidadBloquetas(List<Bloqueta> results) {
  double sumaDeBloquetas = 0.0;
  for (Bloqueta bloqueta in results) {
    double largo = double.parse(bloqueta.largo);
    double altura = double.parse(bloqueta.altura);
    sumaDeBloquetas += calcularCantidadBloquetas(bloqueta.tipoBloqueta, largo, altura);
  }
  return sumaDeBloquetas;
}

double cantidadArena(List<Bloqueta> results) {
  double sumaDeArena = 0.0;
  for (Bloqueta bloqueta in results) {
    double largo = double.parse(bloqueta.largo);
    double altura = double.parse(bloqueta.altura);
    sumaDeArena += calcularCantidadArena(bloqueta.tipoBloqueta, largo, altura);
  }
  return sumaDeArena;
}

double cantidadCemento(List<Bloqueta> results) {
  double sumaDeCemento = 0.0;
  for (Bloqueta bloqueta in results) {
    double largo = double.parse(bloqueta.largo);
    double altura = double.parse(bloqueta.altura);
    sumaDeCemento += calcularCantidadCemento(bloqueta.tipoBloqueta, largo, altura);
  }
  return sumaDeCemento;
}


