import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/presentation/providers/tarrajeo/tarrajeo_providers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../assets/icons.dart';
import '../../../../widgets/app_bar/app_bar_widget.dart';
import '../../../../widgets/shared/options_dialog.dart';
import 'package:pdf/pdf.dart'; // Importa el paquete de colores
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
        appBar: AppBarWidget(titleAppBar: 'Resultado'),
        body: const _ResultTarrajeoScreenView(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _buildFloatingActionButtons(context, ref),
      ),
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context, WidgetRef ref) {
    // Validar que hay datos antes de mostrar botones
    final hayDatos = ref.watch(hayDatosValidosProvider);

    if (!hayDatos) {
      return const SizedBox.shrink();
    }

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
              heroTag: 'save_button_coating',
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
      heroTag: heroTag,
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
                Navigator.of(context).pop();
                try {
                  final pdfFile = await generatePdfTarrajeo(ref);
                  final xFile = XFile(pdfFile.path);
                  await Share.shareXFiles([xFile], text: 'Resultados del metrado de tarrajeo.');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al generar PDF: $e')),
                  );
                }
              },
            ),
            DialogOption(
              icon: Icons.text_fields,
              text: 'TEXTO',
              onTap: () async {
                Navigator.of(context).pop();
                final resumen = ref.read(resumenCompletoProvider);
                await Share.share(resumen);
              },
            ),
          ],
        );
      },
    );
  }
}

class _ResultTarrajeoScreenView extends ConsumerWidget {
  const _ResultTarrajeoScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hayDatos = ref.watch(hayDatosValidosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),
          if (hayDatos) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _TarrajeoMetradoTable(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              const _TarrajeoMaterialesList(),
            ),
            const SizedBox(height: 20),
            const _EstadisticasCard(),
          ] else ...[
            _buildEmptyState(),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
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

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos de tarrajeo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Agrega medidas para ver los resultados de materiales',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar la tabla de metrados
class _TarrajeoMetradoTable extends ConsumerWidget {
  const _TarrajeoMetradoTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrados = ref.watch(tarrajeoMetradosProvider);

    if (metrados.isEmpty) {
      return const Text('No hay datos de metrado disponibles');
    }

    double volumenTotal = metrados.fold(0.0, (sum, m) => sum + m.volumen);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        // Encabezados
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
        // Datos
        ...metrados.map((metrado) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                metrado.descripcion,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'm³',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                metrado.volumenFormateado,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        )).toList(),
        // Total
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
                volumenTotal.toStringAsFixed(3),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget para mostrar la lista de materiales
class _TarrajeoMaterialesList extends ConsumerWidget {
  const _TarrajeoMaterialesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materiales = ref.watch(tarrajeoMaterialesProvider);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        // Encabezados
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
                'Cantidad',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Materiales
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Cemento', style: TextStyle(fontSize: 12)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('bls', style: TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                materiales.cementoFormateado,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Arena fina', style: TextStyle(fontSize: 12)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('m³', style: TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                materiales.arenaFormateada,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Agua', style: TextStyle(fontSize: 12)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('m³', style: TextStyle(fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                materiales.aguaFormateada,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget para mostrar estadísticas adicionales
class _EstadisticasCard extends ConsumerWidget {
  const _EstadisticasCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadisticas = ref.watch(estadisticasTarrajeoProvider);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: AppColors.blueMetraShop,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Resumen del Proyecto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildEstadisticaRow(
                'Cantidad de medidas:',
                '${estadisticas['cantidad_medidas']}'
            ),
            _buildEstadisticaRow(
                'Área total:',
                '${estadisticas['area_total'].toStringAsFixed(2)} m²'
            ),
            _buildEstadisticaRow(
                'Espesor promedio:',
                '${estadisticas['espesor_promedio'].toStringAsFixed(1)} cm'
            ),
            _buildEstadisticaRow(
                'Proporción más usada:',
                '1:${estadisticas['proporcion_mas_usada']}'
            ),
            _buildEstadisticaRow(
                'Volumen total de mortero:',
                '${estadisticas['volumen_total'].toStringAsFixed(3)} m³'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaRow(String label, String value) {
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
}

Future<File> generatePdfTarrajeo(WidgetRef ref) async {
  final pdf = pw.Document();
  final materiales = ref.read(tarrajeoMaterialesProvider);
  final estadisticas = ref.read(estadisticasTarrajeoProvider);
  final metrados = ref.read(tarrajeoMetradosProvider);

  if (metrados.isEmpty) {
    throw Exception("No hay datos disponibles para generar el PDF");
  }

  String title = 'Resultados de Tarrajeo';

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Título
          pw.Text(
              title,
              style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold
              )
          ),
          pw.SizedBox(height: 20),

          // Lista de materiales
          pw.Text(
              'LISTA DE MATERIALES',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold
              )
          ),
          pw.SizedBox(height: 10),
          pw.Text('• Cemento: ${materiales.cementoFormateado} bls'),
          pw.Text('• Arena fina: ${materiales.arenaFormateada} m³'),
          pw.Text('• Agua: ${materiales.aguaFormateada} m³'),
          pw.SizedBox(height: 20),

          // Datos del metrado
          pw.Text(
              'DATOS DEL METRADO',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold
              )
          ),
          pw.SizedBox(height: 10),

          // Tabla de metrados
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              // Encabezados
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Descripción',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Volumen (m³)',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              // Datos
              ...metrados.map((metrado) => pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(metrado.descripcion),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(metrado.volumenFormateado),
                  ),
                ],
              )).toList(),
              // Total
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      materiales.volumenFormateado,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Resumen del proyecto
          pw.Text(
              'RESUMEN DEL PROYECTO',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold
              )
          ),
          pw.SizedBox(height: 10),
          pw.Text('• Cantidad de medidas: ${estadisticas['cantidad_medidas']}'),
          pw.Text('• Área total: ${estadisticas['area_total'].toStringAsFixed(2)} m²'),
          pw.Text('• Espesor promedio: ${estadisticas['espesor_promedio'].toStringAsFixed(1)} cm'),
          pw.Text('• Proporción más usada: 1:${estadisticas['proporcion_mas_usada']}'),
          pw.Text('• Volumen total de mortero: ${materiales.volumenFormateado} m³'),

          pw.SizedBox(height: 30),
          pw.Text(
            'Documento generado automáticamente por MetraShop',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_tarrajeo.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}