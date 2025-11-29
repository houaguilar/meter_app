import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../../config/utils/pdf/pdf_generator.dart';
import 'UnifiedResultsCombiner.dart';

/// Servicio para compartir resultados combinados en diferentes formatos
class CombinedResultsShareService {
  /// Genera y comparte un PDF con los resultados combinados
  static Future<void> sharePdf(
    CombinedCalculationResult result, {
    String? nombreUsuario,
  }) async {
    try {
      final file = await _generatePdf(result, nombreUsuario: nombreUsuario);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Resultados Combinados - ${result.projectName}',
        text: 'Resultados combinados de ${result.metradoCount} metrados',
      );
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }

  /// Genera y comparte un texto con los resultados combinados
  static Future<void> shareText(CombinedCalculationResult result) async {
    try {
      final text = _generateText(result);
      await Share.share(
        text,
        subject: 'Resultados Combinados - ${result.projectName}',
      );
    } catch (e) {
      throw Exception('Error al compartir texto: $e');
    }
  }

  /// Genera un PDF con los resultados combinados usando MetraShopPDFGenerator
  static Future<File> _generatePdf(
    CombinedCalculationResult result, {
    String? nombreUsuario,
  }) async {
    // Convertir materiales combinados a MaterialItem
    final materiales = result.sortedMaterials.map((material) {
      return MaterialItem(
        descripcion: material.name,
        unidad: material.unit,
        cantidad: material.totalQuantity.toStringAsFixed(2),
      );
    }).toList();

    // Crear metrado con resumen de cada metrado combinado
    final metrado = result.metradoSummaries.map((summary) {
      return MetradoItem(
        elemento: summary.metradoName,
        unidad: 'elementos',
        medida: '${summary.itemCount}',
      );
    }).toList();

    // Crear observaciones con información adicional
    final observaciones = <String>[
      'Metrados combinados: ${result.metradoCount}',
      'Total de materiales: ${result.combinedMaterials.length}',
      'Área total: ${result.totalArea.toStringAsFixed(2)} m²',
      'Fecha de combinación: ${_formatDate(result.combinationDate)}',
    ];

    // Crear PDFData
    final pdfData = PDFData(
      titulo: 'Resultados Combinados',
      fecha: _formatDate(DateTime.now()),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: result.projectName,
      obra: 'Combinación de ${result.metradoCount} metrados',
      partida: 'Resultados Unificados',
      materiales: materiales,
      metrado: metrado,
      observaciones: observaciones,
      nombreUsuario: nombreUsuario,
    );

    // Generar PDF usando el generador estándar
    return await MetraShopPDFGenerator.generatePDF(
      data: pdfData,
      customFileName: 'resultados_combinados_${_getTimestamp()}.pdf',
    );
  }

  /// Genera un texto formateado con los resultados combinados
  static String _generateText(CombinedCalculationResult result) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('    RESULTADOS COMBINADOS');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Proyecto: ${result.projectName}');
    buffer.writeln('Fecha: ${_formatDate(result.combinationDate)}');
    buffer.writeln();

    // Resumen
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('RESUMEN GENERAL');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('Metrados combinados: ${result.metradoCount}');
    buffer.writeln('Total materiales: ${result.combinedMaterials.length}');
    buffer.writeln('Área total: ${result.totalArea.toStringAsFixed(2)} m²');
    buffer.writeln();

    // Materiales totales
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('MATERIALES TOTALES');
    buffer.writeln('───────────────────────────────────────');
    for (final material in result.sortedMaterials) {
      buffer.writeln('${material.name}:');
      buffer.writeln('  Cantidad: ${material.totalQuantity.toStringAsFixed(2)} ${material.unit}');
      buffer.writeln('  De ${material.contributions.length} metrado${material.contributions.length != 1 ? 's' : ''}');

      if (material.contributions.length > 1) {
        buffer.writeln('  Contribuciones:');
        for (final entry in material.contributions.entries) {
          final percentage = material.getContributionPercentage(entry.key);
          buffer.writeln('    • ${entry.key}: ${entry.value.toStringAsFixed(2)} ${material.unit} (${percentage.toStringAsFixed(1)}%)');
        }
      }
      buffer.writeln();
    }

    // Detalle por metrado
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('DETALLE POR METRADO');
    buffer.writeln('───────────────────────────────────────');
    for (final summary in result.metradoSummaries) {
      buffer.writeln(summary.metradoName);
      buffer.writeln('  ${summary.description}');
      buffer.writeln('  Materiales:');
      for (final entry in summary.materials.entries) {
        buffer.writeln('    • ${entry.key}: ${entry.value.toStringAsFixed(2)}');
      }
      buffer.writeln();
    }

    // Footer
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Generado con MetraShop');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// Genera un número de cotización único
  static String _generateCotizationNumber() {
    final now = DateTime.now();
    return 'COT-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  /// Genera timestamp para nombres de archivo
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  /// Formatea una fecha en formato dd/MM/yyyy HH:mm
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
