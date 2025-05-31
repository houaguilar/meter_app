// lib/presentation/screens/projects/result/services/pdf_generation_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';


/// Servicio para generar PDFs de resultados de cálculos
class PdfGenerationService {

  /// Genera un PDF con los resultados del cálculo
  static Future<File> generatePdf(CalculationResult result) async {
    try {
      final pdf = pw.Document();

      // Cargar logo si está disponible
      pw.MemoryImage? logoImage;
      try {
        final logoBytes = await rootBundle.load('assets/images/metrashop.png');
        logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
      } catch (e) {
        // Logo no disponible, continuar sin él
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(logoImage, result),
                pw.SizedBox(height: 16),
                _buildProjectInfo(result),
                pw.SizedBox(height: 20),
                _buildMeasurementsSection(result),
                pw.SizedBox(height: 24),
                _buildMaterialsSection(result),
                pw.Spacer(),
                _buildFooter(),
              ],
            );
          },
        ),
      );

      // Guardar archivo temporal
      final output = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${output.path}/resultados_${result.type.name}_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  /// Construye el encabezado del PDF
  static pw.Widget _buildHeader(pw.MemoryImage? logoImage, CalculationResult result) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        logoImage != null
            ? pw.Image(logoImage, width: 100)
            : pw.Text(
          'METRASHOP',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'RESULTADOS DE CÁLCULO',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#0A1E27'),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F5C845').shade(0.3),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                result.type.displayName,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye la información del proyecto
  static pw.Widget _buildProjectInfo(CalculationResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Fecha: ${_getCurrentDate()}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'ID: ${_generateId()}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
        pw.Divider(),
        if (result.additionalInfo.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            'INFORMACIÓN DEL PROYECTO',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          ...result.additionalInfo.entries.map((entry) {
            return pw.Text(
              '• ${_formatInfoKey(entry.key)}: ${entry.value}',
              style: const pw.TextStyle(fontSize: 12),
            );
          }),
        ],
      ],
    );
  }

  /// Construye la sección de mediciones
  static pw.Widget _buildMeasurementsSection(CalculationResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DATOS DEL METRADO',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildMeasurementsTable(result),
      ],
    );
  }

  /// Construye la tabla de mediciones
  static pw.Widget _buildMeasurementsTable(CalculationResult result) {
    if (result.measurements.isEmpty) {
      return pw.Text('No hay datos de medición disponibles');
    }

    List<List<String>> tableData = [
      ['Descripción', 'Und.', result.totalUnit],
    ];

    // Agregar filas de datos
    for (var measurement in result.measurements) {
      tableData.add([
        measurement.description,
        measurement.unit,
        measurement.value.toStringAsFixed(2),
      ]);
    }

    // Agregar fila del total
    tableData.add([
      'Total',
      result.totalUnit,
      result.totalValue.toStringAsFixed(2),
    ]);

    return _buildTable(tableData, hasHeader: true, hasFooter: true);
  }

  /// Construye la sección de materiales
  static pw.Widget _buildMaterialsSection(CalculationResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'LISTA DE MATERIALES',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildMaterialsTable(result),
      ],
    );
  }

  /// Construye la tabla de materiales
  static pw.Widget _buildMaterialsTable(CalculationResult result) {
    if (result.materials.isEmpty) {
      return pw.Text('No hay materiales disponibles');
    }

    List<List<String>> tableData = [
      ['Material', 'Und.', 'Cantidad'],
    ];

    for (var material in result.materials) {
      tableData.add([
        material.description,
        material.unit,
        material.quantity,
      ]);
    }

    return _buildTable(tableData, hasHeader: true);
  }

  /// Construye una tabla genérica
  static pw.Widget _buildTable(
      List<List<String>> data, {
        bool hasHeader = false,
        bool hasFooter = false,
      }) {
    return pw.Table(
      border: const pw.TableBorder(
        horizontalInside: pw.BorderSide(width: 1, color: PdfColors.grey300),
        verticalInside: pw.BorderSide(width: 1, color: PdfColors.grey300),
        bottom: pw.BorderSide(width: 1, color: PdfColors.grey300),
        left: pw.BorderSide(width: 1, color: PdfColors.grey300),
        right: pw.BorderSide(width: 1, color: PdfColors.grey300),
        top: pw.BorderSide(width: 1, color: PdfColors.grey300),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(2),
      },
      children: data.asMap().entries.map((entry) {
        final index = entry.key;
        final rowData = entry.value;
        final isHeaderRow = hasHeader && index == 0;
        final isFooterRow = hasFooter && index == data.length - 1;

        return pw.TableRow(
          decoration: (isHeaderRow || isFooterRow)
              ? const pw.BoxDecoration(color: PdfColors.grey200)
              : null,
          children: rowData.map((cell) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                cell,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: (isHeaderRow || isFooterRow)
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  /// Construye el pie de página
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Center(
          child: pw.Text(
            '"CALCULA Y COMPRA SIN PARAR DE CONSTRUIR"',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            'MetraShop App - ${_getCurrentDate()}',
            style: const pw.TextStyle(fontSize: 8),
          ),
        ),
      ],
    );
  }

  // Métodos auxiliares

  static String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8);
  }

  static String _formatInfoKey(String key) {
    switch (key) {
      case 'tipoLadrillo':
        return 'Tipo de ladrillo';
      case 'tipoAsentado':
        return 'Tipo de asentado';
      case 'proporcionMortero':
        return 'Proporción mortero';
      case 'desperdicioLadrillo':
        return 'Desperdicio ladrillo';
      case 'desperdicioMortero':
        return 'Desperdicio mortero';
      default:
        return key.replaceAllMapped(
          RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)!.toLowerCase()}',
        ).trim();
    }
  }
}