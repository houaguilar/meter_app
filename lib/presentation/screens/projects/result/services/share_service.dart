// lib/presentation/screens/projects/result/services/share_service.dart

import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';


/// Servicio para compartir resultados de cálculos
class ShareService {

  /// Comparte un archivo PDF
  static Future<void> sharePdf(File pdfFile) async {
    try {
      final xFile = XFile(pdfFile.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Resultados de cálculo - MetraShop',
        subject: 'Metrado de Construcción',
      );
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }

  /// Genera y comparte texto con los resultados
  static String generateShareText(CalculationResult result) {
    if (result.hasError) {
      return 'Error en el cálculo: ${result.errorMessage}';
    }

    if (result.isEmpty) {
      return 'No hay datos de cálculo disponibles';
    }

    final buffer = StringBuffer();

    // Encabezado
    buffer.writeln('METRASHOP - ${result.type.displayName}');
    buffer.writeln('=' * 50);
    buffer.writeln();

    // Información adicional si existe
    if (result.additionalInfo.isNotEmpty) {
      buffer.writeln('INFORMACIÓN DEL PROYECTO:');
      for (var entry in result.additionalInfo.entries) {
        buffer.writeln('• ${_formatInfoKey(entry.key)}: ${entry.value}');
      }
      buffer.writeln();
    }

    // Datos del metrado
    buffer.writeln('DATOS DEL METRADO:');
    for (var measurement in result.measurements) {
      buffer.writeln('• ${measurement.description}: ${measurement.value.toStringAsFixed(2)} ${measurement.unit}');
    }
    buffer.writeln('Total: ${result.totalValue.toStringAsFixed(2)} ${result.totalUnit}');
    buffer.writeln();

    // Lista de materiales
    buffer.writeln('LISTA DE MATERIALES:');
    for (var material in result.materials) {
      buffer.writeln('• ${material.description}: ${material.quantity} ${material.unit}');
    }
    buffer.writeln();

    // Pie de página
    buffer.writeln('Calculado con MetraShop');
    buffer.writeln('"CALCULA Y COMPRA SIN PARAR DE CONSTRUIR"');
    buffer.writeln('Fecha: ${_getCurrentDate()}');

    return buffer.toString();
  }

  /// Comparte texto directamente
  static Future<void> shareText(CalculationResult result) async {
    try {
      final text = generateShareText(result);
      await Share.share(
        text,
        subject: 'Resultados de Metrado - ${result.type.displayName}',
      );
    } catch (e) {
      throw Exception('Error al compartir texto: $e');
    }
  }

  /// Comparte resultados con opciones múltiples
  static Future<void> shareResults({
    required CalculationResult result,
    File? pdfFile,
    bool includeText = true,
  }) async {
    try {
      if (pdfFile != null) {
        await sharePdf(pdfFile);
      } else if (includeText) {
        await shareText(result);
      } else {
        throw Exception('No hay contenido para compartir');
      }
    } catch (e) {
      throw Exception('Error al compartir resultados: $e');
    }
  }

  // Métodos auxiliares

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
      case 'resistencia':
        return 'Resistencia';
      case 'espesor':
        return 'Espesor';
      case 'altura':
        return 'Altura';
      default:
      // Convierte camelCase a formato legible
        return key.replaceAllMapped(
          RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)!.toLowerCase()}',
        ).trim();
    }
  }

  static String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }
}