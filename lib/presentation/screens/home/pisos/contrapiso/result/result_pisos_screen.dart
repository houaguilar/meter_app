import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../domain/entities/entities.dart';
import '../../../../../assets/icons.dart';
import '../../../../../providers/providers.dart';
import '../../../../../widgets/widgets.dart';
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
        appBar: AppBarWidget(titleAppBar: 'Resultado Contrapiso'),
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
                context.pushNamed('contrapiso-save');
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
            context.pushNamed('contrapiso-map-screen');
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
                final pdfFile = await generatePdfContrapiso(ref);
                final xFile = XFile(pdfFile.path);
                Share.shareXFiles([xFile], text: 'Resultados del metrado de contrapiso.');
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

    final datosShare = ref.watch(datosSharePisosProvider);
    final resultados = CalculadoraContrapiso.calcularMateriales(listaPisos);

    return 'DATOS METRADO\n$datosShare\n-------------\nLISTA DE MATERIALES\n'
        '*Cemento: ${resultados.cementoTotal.ceil()} bls\n'
        '*Arena gruesa: ${resultados.arenaTotal.toStringAsFixed(2)} m³\n'
        '*Agua: ${resultados.aguaTotal.toStringAsFixed(2)} m³';
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
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            _buildCalculationInfoCard(context, listaPisos),
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

  Widget _buildMaterialList(BuildContext context, List<Piso> pisos) {
    if (pisos.isEmpty) return const SizedBox.shrink();

    final resultados = CalculadoraContrapiso.calcularMateriales(pisos);

    final List<TableRow> rows = [
      _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
      _buildMaterialRow('Cemento', 'bls', resultados.cementoTotal.ceil().toString()),
      _buildMaterialRow('Arena gruesa', 'm³', resultados.arenaTotal.toStringAsFixed(2)),
      _buildMaterialRow('Agua', 'm³', resultados.aguaTotal.toStringAsFixed(2)),
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: rows,
    );
  }

  Widget _buildCalculationInfoCard(BuildContext context, List<Piso> pisos) {
    if (pisos.isEmpty) return const SizedBox.shrink();

    final primer = pisos.first;
    final proporcion = primer.proporcionMortero ?? '5';
    final espesor = double.tryParse(primer.espesor) ?? 0.0;
    final desperdicio = double.tryParse(primer.factorDesperdicio) ?? 5.0;
    final resultados = CalculadoraContrapiso.calcularMateriales(pisos);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.blueMetraShop, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Información del Cálculo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Proporción Mortero:', '1:$proporcion'),
            _buildInfoRow('Espesor promedio:', '${espesor.toStringAsFixed(1)} cm'),
            _buildInfoRow('Factor de desperdicio:', '${desperdicio.toStringAsFixed(0)}%'),
            _buildInfoRow('Volumen total:', '${resultados.volumenTotal.toStringAsFixed(2)} m³'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: AppColors.textInfo, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cálculos basados en factores técnicos del Excel líneas 15-164',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textInfo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
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

class _PisosContainer extends ConsumerWidget {
  const _PisosContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pisosResultProvider);
    return _buildPisosContainer(context, results);
  }

  Widget _buildPisosContainer(BuildContext context, List<Piso> results) {
    double calcularVolumen(Piso piso) {
      final espesor = double.tryParse(piso.espesor) ?? 0.0;
      if (piso.area != null && piso.area!.isNotEmpty) {
        final area = double.tryParse(piso.area!) ?? 0.0;
        return area * (espesor / 100);
      } else {
        final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
        return largo * ancho * (espesor / 100);
      }
    }

    double sumaTotalDeVolumenes = results.fold(0.0, (sum, piso) => sum + calcularVolumen(piso));

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        // Headers
        const TableRow(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Descripción', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Und.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Volumen', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        // Data rows
        for (var result in results)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(result.description, style: const TextStyle(fontSize: 12)),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('m³', style: TextStyle(fontSize: 12)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(calcularVolumen(result).toStringAsFixed(2), style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        // Total row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Total:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('m³', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(sumaTotalDeVolumenes.toStringAsFixed(2), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Clase principal para cálculos de contrapiso basada en el Excel
class CalculadoraContrapiso {
  // Factores de materiales según proporción del mortero (líneas 15-164 del Excel)
  static const Map<String, Map<String, double>> _factoresMortero = {
    '3': {
      'cemento': 10.5, // bolsas por m³
      'arena': 0.95,   // m³ por m³
      'agua': 0.285,   // m³ por m³
    },
    '4': {
      'cemento': 8.9,  // bolsas por m³
      'arena': 1.0,    // m³ por m³
      'agua': 0.272,   // m³ por m³
    },
    '5': {
      'cemento': 7.4,  // bolsas por m³
      'arena': 1.05,   // m³ por m³
      'agua': 0.268,   // m³ por m³
    },
    '6': {
      'cemento': 6.3,  // bolsas por m³
      'arena': 1.08,   // m³ por m³
      'agua': 0.265,   // m³ por m³
    },
  };

  static ResultadosContrapiso calcularMateriales(List<Piso> pisos) {
    if (pisos.isEmpty) {
      return const ResultadosContrapiso(
        cementoTotal: 0,
        arenaTotal: 0,
        aguaTotal: 0,
        volumenTotal: 0,
      );
    }

    double cementoTotal = 0.0;
    double arenaTotal = 0.0;
    double aguaTotal = 0.0;
    double volumenTotal = 0.0;

    for (var piso in pisos) {
      // Obtener valores del piso
      final proporcion = piso.proporcionMortero ?? '5';
      final espesor = double.tryParse(piso.espesor) ?? 5.0;
      final desperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0;

      // Obtener factores de la proporción
      final factores = _factoresMortero[proporcion] ?? _factoresMortero['5']!;

      // Calcular área
      final area = _obtenerArea(piso);

      // Calcular volumen de mortero
      final volumen = area * (espesor / 100); // convertir cm a metros

      // Calcular materiales con desperdicio
      final cemento = factores['cemento']! * volumen * (1 + desperdicio);
      final arena = factores['arena']! * volumen * (1 + desperdicio);
      final agua = factores['agua']! * volumen * (1 + desperdicio);

      // Sumar a totales
      cementoTotal += cemento;
      arenaTotal += arena;
      aguaTotal += agua;
      volumenTotal += volumen;
    }

    return ResultadosContrapiso(
      cementoTotal: cementoTotal,
      arenaTotal: arenaTotal,
      aguaTotal: aguaTotal,
      volumenTotal: volumenTotal,
    );
  }

  static double _obtenerArea(Piso piso) {
    if (piso.area != null && piso.area!.isNotEmpty) {
      return double.tryParse(piso.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }
}

/// Clase para almacenar resultados de cálculos
class ResultadosContrapiso {
  final double cementoTotal;
  final double arenaTotal;
  final double aguaTotal;
  final double volumenTotal;

  const ResultadosContrapiso({
    required this.cementoTotal,
    required this.arenaTotal,
    required this.aguaTotal,
    required this.volumenTotal,
  });
}

// Función para generar PDF
Future<File> generatePdfContrapiso(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaPiso = ref.watch(pisosResultProvider);

  if (listaPiso.isEmpty) {
    throw Exception("No hay datos disponibles para generar el PDF");
  }

  final resultados = CalculadoraContrapiso.calcularMateriales(listaPiso);

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Resultados de Contrapiso',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('Cemento: ${resultados.cementoTotal.ceil()} bls'),
            pw.Text('Arena gruesa: ${resultados.arenaTotal.toStringAsFixed(2)} m³'),
            pw.Text('Agua: ${resultados.aguaTotal.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 10),
            pw.Text('Volumen total: ${resultados.volumenTotal.toStringAsFixed(2)} m³'),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_contrapiso.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}