// lib/presentation/screens/home/estructuras/result/result_structural_elements_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../assets/icons.dart';
import '../../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultStructuralElementsScreen extends ConsumerStatefulWidget {
  const ResultStructuralElementsScreen({super.key});

  @override
  ConsumerState<ResultStructuralElementsScreen> createState() => _ResultStructuralElementsScreenState();
}

class _ResultStructuralElementsScreenState extends ConsumerState<ResultStructuralElementsScreen> {

  @override
  void initState() {
    super.initState();

    // FIX: Verificar el estado al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tipoElemento = ref.read(tipoStructuralElementProvider);
      final columnas = ref.read(columnaResultProvider);
      final vigas = ref.read(vigaResultProvider);

      print('🔍 Estado en ResultScreen:');
      print('- Tipo: $tipoElemento');
      print('- Columnas: ${columnas.length}');
      print('- Vigas: ${vigas.length}');

      // Si no hay datos válidos, regresar
      if (tipoElemento.isEmpty ||
          (tipoElemento == 'columna' && columnas.isEmpty) ||
          (tipoElemento == 'viga' && vigas.isEmpty)) {
        print('❌ No hay datos válidos, regresando...');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay datos para mostrar. Vuelve a intentar.')),
        );
        context.pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    return WillPopScope(
      onWillPop: () async {
        _clearDataOnExit();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado'),
        body: tipoElemento.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : const _ResultStructuralElementsScreenView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: tipoElemento.isNotEmpty
            ? _buildFloatingActionButtons(context, ref)
            : null,
      ),
    );
  }

  void _clearDataOnExit() {
    final tipoElemento = ref.read(tipoStructuralElementProvider);
    if (tipoElemento == 'columna') {
      ref.read(columnaResultProvider.notifier).clearList();
    } else if (tipoElemento == 'viga') {
      ref.read(vigaResultProvider.notifier).clearList();
    }
    print('🧹 Datos limpiados al salir');
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
                try {
                  final pdfFile = await generatePdf(ref);
                  final xFile = XFile(pdfFile.path);
                  await Share.shareXFiles([xFile], text: 'Resultados del metrado.');
                } catch (e) {
                  print('❌ Error generando PDF: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al generar PDF')),
                  );
                }
              },
            ),
            DialogOption(
              icon: Icons.text_fields,
              text: 'TEXTO',
              onTap: () async {
                Navigator.of(context).pop();
                try {
                  await Share.share(_shareContent(ref));
                } catch (e) {
                  print('❌ Error compartiendo texto: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al compartir texto')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _shareContent(WidgetRef ref) {
    final tipoElemento = ref.watch(tipoStructuralElementProvider);

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';
    String shareText = '';

    try {
      if (tipoElemento == 'columna') {
        final listaColumnas = ref.watch(columnaResultProvider);

        if (listaColumnas.isEmpty) return 'Error: No hay datos de columnas para compartir';

        final cantidadCemento = ref.watch(cantidadCementoColumnaProvider).ceilToDouble().toString();
        final cantidadArena = ref.watch(cantidadArenaColumnaProvider).toStringAsFixed(2);
        final cantidadPiedra = ref.watch(cantidadPiedraColumnaProvider).toStringAsFixed(2);
        final cantidadAgua = ref.watch(cantidadAguaColumnaProvider).toStringAsFixed(2);

        final datosColumna = ref.watch(datosShareColumnaProvider);

        shareText = '$datosMetrado\n$datosColumna\n-------------\n$listaMateriales\n'
            '*Cemento: $cantidadCemento bls\n'
            '*Arena gruesa: $cantidadArena m3\n'
            '*Piedra para concreto: $cantidadPiedra m3\n'
            '*Agua: $cantidadAgua m3';
      } else if (tipoElemento == 'viga') {
        final listaVigas = ref.watch(vigaResultProvider);

        if (listaVigas.isEmpty) return 'Error: No hay datos de vigas para compartir';

        final cantidadCemento = ref.watch(cantidadCementoVigaProvider).ceilToDouble().toString();
        final cantidadArena = ref.watch(cantidadArenaVigaProvider).toStringAsFixed(2);
        final cantidadPiedra = ref.watch(cantidadPiedraVigaProvider).toStringAsFixed(2);
        final cantidadAgua = ref.watch(cantidadAguaVigaProvider).toStringAsFixed(2);

        final datosViga = ref.watch(datosShareVigaProvider);

        shareText = '$datosMetrado\n$datosViga\n-------------\n$listaMateriales\n'
            '*Cemento: $cantidadCemento bls\n'
            '*Arena gruesa: $cantidadArena m3\n'
            '*Piedra para concreto: $cantidadPiedra m3\n'
            '*Agua: $cantidadAgua m3';
      } else {
        return 'Error: Tipo de elemento no válido';
      }
    } catch (e) {
      print('❌ Error generando contenido para compartir: $e');
      return 'Error al generar contenido para compartir';
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

          // FIX: Verificar datos antes de mostrar
          if (tipoElemento == 'columna') ...[
            Consumer(
              builder: (context, ref, child) {
                final columnas = ref.watch(columnaResultProvider);
                if (columnas.isEmpty) {
                  return const Center(
                    child: Text('No hay datos de columnas disponibles'),
                  );
                }
                return Column(
                  children: [
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
                  ],
                );
              },
            ),
          ] else if (tipoElemento == 'viga') ...[
            Consumer(
              builder: (context, ref, child) {
                final vigas = ref.watch(vigaResultProvider);
                if (vigas.isEmpty) {
                  return const Center(
                    child: Text('No hay datos de vigas disponibles'),
                  );
                }
                return Column(
                  children: [
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
                );
              },
            ),
          ] else ...[
            const Center(
              child: Text('No se ha seleccionado un tipo de elemento válido'),
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
    try {
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
          _buildMaterialRow('Arena gruesa', 'm³', cantidadArena),
          _buildMaterialRow('Piedra para concreto', 'm³', cantidadPiedra),
          _buildMaterialRow('Agua', 'm³', cantidadAgua),
        ],
      );
    } catch (e) {
      print('❌ Error calculando materiales de columna: $e');
      return const Text('Error al calcular materiales');
    }
  }

  Widget _buildMaterialListViga(WidgetRef ref) {
    try {
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
          _buildMaterialRow('Arena gruesa', 'm³', cantidadArena),
          _buildMaterialRow('Piedra para concreto', 'm³', cantidadPiedra),
          _buildMaterialRow('Agua', 'm³', cantidadAgua),
        ],
      );
    } catch (e) {
      print('❌ Error calculando materiales de viga: $e');
      return const Text('Error al calcular materiales');
    }
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
    try {
      final results = ref.watch(columnaResultProvider);
      final volumenes = ref.watch(volumenColumnaProvider);
      return _buildElementContainer(context, results, volumenes, 'Columna');
    } catch (e) {
      print('❌ Error en _ColumnaContainer: $e');
      return const Text('Error al cargar datos de columnas');
    }
  }
}

class _VigaContainer extends ConsumerWidget {
  const _VigaContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final results = ref.watch(vigaResultProvider);
      final volumenes = ref.watch(volumenVigaProvider);
      return _buildElementContainer(context, results, volumenes, 'Viga');
    } catch (e) {
      print('❌ Error en _VigaContainer: $e');
      return const Text('Error al cargar datos de vigas');
    }
  }
}

Widget _buildElementContainer(BuildContext context, List<dynamic> results, List<double> volumenes, String tipo) {
  try {
    if (results.isEmpty || volumenes.isEmpty) {
      return Text('No hay datos de $tipo disponibles');
    }

    // Calcular suma total de volúmenes
    double sumaTotalDeVolumenes = volumenes.fold(0.0, (sum, volumen) => sum + volumen);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Ancho para descripción
          1: FlexColumnWidth(1), // Ancho para unidad
          2: FlexColumnWidth(1), // Ancho para volumen
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
          for (int i = 0; i < results.length && i < volumenes.length; i++)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    results[i].description ?? 'Sin descripción',
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
                  sumaTotalDeVolumenes.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  } catch (e) {
    print('❌ Error en _buildElementContainer: $e');
    return Text('Error al mostrar datos de $tipo');
  }
}

// Implementación para generar PDF
Future<File> generatePdf(WidgetRef ref) async {
  try {
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
              pw.Text('Lista de Materiales:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (tipoElemento == 'columna') ...[
                pw.Text('• Cemento: ${ref.watch(cantidadCementoColumnaProvider).ceilToDouble()} bls'),
                pw.Text('• Arena gruesa: ${ref.watch(cantidadArenaColumnaProvider).toStringAsFixed(2)} m³'),
                pw.Text('• Piedra para concreto: ${ref.watch(cantidadPiedraColumnaProvider).toStringAsFixed(2)} m³'),
                pw.Text('• Agua: ${ref.watch(cantidadAguaColumnaProvider).toStringAsFixed(2)} m³'),
              ] else ...[
                pw.Text('• Cemento: ${ref.watch(cantidadCementoVigaProvider).ceilToDouble()} bls'),
                pw.Text('• Arena gruesa: ${ref.watch(cantidadArenaVigaProvider).toStringAsFixed(2)} m³'),
                pw.Text('• Piedra para concreto: ${ref.watch(cantidadPiedraVigaProvider).toStringAsFixed(2)} m³'),
                pw.Text('• Agua: ${ref.watch(cantidadAguaVigaProvider).toStringAsFixed(2)} m³'),
              ],
              pw.SizedBox(height: 20),
              pw.Text('Datos del Metrado:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              if (tipoElemento == 'columna')
                pw.Text(ref.watch(datosShareColumnaProvider))
              else
                pw.Text(ref.watch(datosShareVigaProvider)),
            ],
          ),
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/resultados_${tipoElemento}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  } catch (e) {
    print('❌ Error generando PDF: $e');
    throw Exception('Error al generar PDF: $e');
  }
}