import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/constants/colors.dart';
import '../../../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../../../domain/services/structural_element_service.dart';
import '../../../../assets/icons.dart';
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../providers/home/estructuras/structural_providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultStructuralElementsScreen extends ConsumerWidget {
  const ResultStructuralElementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    return WillPopScope(
      onWillPop: () async {
        if (tipoElemento == 'columna') {
          ref.read(columnaResultProvider.notifier).clearList();
        } else {
          ref.read(vigaResultProvider.notifier).clearList();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado'),
        body: const _ResultStructuralElementsScreenView(),
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
              heroTag: 'save_button_structural',
              onPressed: () {
                context.pushNamed('save-structural-element');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_structural',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            context.pushNamed('map-screen-structural');
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
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

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

  // lib/presentation/screens/home/structural/result/result_structural_elements_screen.dart (continued)
  String _shareContent(WidgetRef ref) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';
    String shareText = '';

    if (tipoElemento == 'columna') {
      final listaColumnas = ref.watch(columnaResultProvider);

      if (listaColumnas.isEmpty) return 'Error: No hay datos para compartir';

      final cantidadCemento = ref.watch(cantidadCementoColumnaProvider).ceilToDouble().toString();
      final cantidadArena = ref.watch(cantidadArenaColumnaProvider).toStringAsFixed(2);
      final cantidadPiedra = ref.watch(cantidadPiedraColumnaProvider).toStringAsFixed(2);
      final cantidadAgua = ref.watch(cantidadAguaColumnaProvider).toStringAsFixed(2);

      final datosColumna = ref.watch(datosShareColumnaProvider);

      shareText = '$datosMetrado \n$datosColumna \n-------------\n$listaMateriales \n'
          '*Cemento: $cantidadCemento bls \n'
          '*Arena gruesa: $cantidadArena m3 \n'
          '*Piedra chancada: $cantidadPiedra m3 \n'
          '*Agua: $cantidadAgua m3';
    } else {
      final listaVigas = ref.watch(vigaResultProvider);

      if (listaVigas.isEmpty) return 'Error: No hay datos para compartir';

      final cantidadCemento = ref.watch(cantidadCementoVigaProvider).ceilToDouble().toString();
      final cantidadArena = ref.watch(cantidadArenaVigaProvider).toStringAsFixed(2);
      final cantidadPiedra = ref.watch(cantidadPiedraVigaProvider).toStringAsFixed(2);
      final cantidadAgua = ref.watch(cantidadAguaVigaProvider).toStringAsFixed(2);

      final datosViga = ref.watch(datosShareVigaProvider);

      shareText = '$datosMetrado \n$datosViga \n-------------\n$listaMateriales \n'
          '*Cemento: $cantidadCemento bls \n'
          '*Arena gruesa: $cantidadArena m3 \n'
          '*Piedra chancada: $cantidadPiedra m3 \n'
          '*Agua: $cantidadAgua m3';
    }

    return shareText;
  }
}

class _ResultStructuralElementsScreenView extends ConsumerWidget {
  const _ResultStructuralElementsScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),

          if (tipoElemento == 'columna' && ref.watch(columnaResultProvider).isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _ColumnaContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialListColumna(ref),
            ),
          ] else if (tipoElemento == 'viga' && ref.watch(vigaResultProvider).isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _VigaContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialListViga(ref),
            ),
          ],

          const SizedBox(height: 200),
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

  Widget _buildMaterialListColumna(WidgetRef ref) {
    final cantidadCemento = ref.watch(cantidadCementoColumnaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaColumnaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraColumnaProvider).toStringAsFixed(2);
    final cantidadAgua = ref.watch(cantidadAguaColumnaProvider).toStringAsFixed(2);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para descripción
        1: FlexColumnWidth(1), // Ancho para unidad
        2: FlexColumnWidth(2), // Ancho para cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadCemento),
        _buildMaterialRow('Arena gruesa', 'm3', cantidadArena),
        _buildMaterialRow('Piedra chancada', 'm3', cantidadPiedra),
        _buildMaterialRow('Agua', 'm3', cantidadAgua),
      ],
    );
  }

  Widget _buildMaterialListViga(WidgetRef ref) {
    final cantidadCemento = ref.watch(cantidadCementoVigaProvider).ceilToDouble().toString();
    final cantidadArena = ref.watch(cantidadArenaVigaProvider).toStringAsFixed(2);
    final cantidadPiedra = ref.watch(cantidadPiedraVigaProvider).toStringAsFixed(2);
    final cantidadAgua = ref.watch(cantidadAguaVigaProvider).toStringAsFixed(2);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para descripción
        1: FlexColumnWidth(1), // Ancho para unidad
        2: FlexColumnWidth(2), // Ancho para cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadCemento),
        _buildMaterialRow('Arena gruesa', 'm3', cantidadArena),
        _buildMaterialRow('Piedra chancada', 'm3', cantidadPiedra),
        _buildMaterialRow('Agua', 'm3', cantidadAgua),
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

class _ColumnaContainer extends ConsumerWidget {
  const _ColumnaContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(columnaResultProvider);
    return _buildColumnaContainer(context, results);
  }

  Widget _buildColumnaContainer(BuildContext context, List<Columna> results) {
    final structuralElementService = StructuralElementService();

    double calcularVolumen(Columna columna) {
      return structuralElementService.calcularVolumen(columna) ?? 0.0;
    }

    double calcularSumaTotalDeVolumenes(List<Columna> results) {
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
          0: FlexColumnWidth(2), // Ancho fijo para descripción
          1: FlexColumnWidth(1), // Ancho fijo para unidad
          2: FlexColumnWidth(1), // Ancho fijo para volumen
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
  }
}

class _VigaContainer extends ConsumerWidget {
  const _VigaContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(vigaResultProvider);
    return _buildVigaContainer(context, results);
  }

  Widget _buildVigaContainer(BuildContext context, List<Viga> results) {
    final structuralElementService = StructuralElementService();

    double calcularVolumen(Viga viga) {
      return structuralElementService.calcularVolumen(viga) ?? 0.0;
    }

    double calcularSumaTotalDeVolumenes(List<Viga> results) {
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
          0: FlexColumnWidth(2), // Ancho fijo para descripción
          1: FlexColumnWidth(1), // Ancho fijo para unidad
          2: FlexColumnWidth(1), // Ancho fijo para volumen
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
  }
}

// Implementación para generar PDF
Future<File> generatePdf(WidgetRef ref) async {
  final pdf = pw.Document();
  final tipoElemento = ref.watch(tipoStructuralElementProvider);

  String title = tipoElemento == 'columna' ? 'Resultados de Columna' : 'Resultados de Viga';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            if (tipoElemento == 'columna') ...[
              pw.Text('Cemento: ${ref.watch(cantidadCementoColumnaProvider).ceilToDouble()} bls'),
              pw.Text('Arena gruesa: ${ref.watch(cantidadArenaColumnaProvider).toStringAsFixed(2)} m3'),
              pw.Text('Piedra chancada: ${ref.watch(cantidadPiedraColumnaProvider).toStringAsFixed(2)} m3'),
              pw.Text('Agua: ${ref.watch(cantidadAguaColumnaProvider).toStringAsFixed(2)} m3'),
            ] else ...[
              pw.Text('Cemento: ${ref.watch(cantidadCementoVigaProvider).ceilToDouble()} bls'),
              pw.Text('Arena gruesa: ${ref.watch(cantidadArenaVigaProvider).toStringAsFixed(2)} m3'),
              pw.Text('Piedra chancada: ${ref.watch(cantidadPiedraVigaProvider).toStringAsFixed(2)} m3'),
              pw.Text('Agua: ${ref.watch(cantidadAguaVigaProvider).toStringAsFixed(2)} m3'),
            ],
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_${tipoElemento}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}