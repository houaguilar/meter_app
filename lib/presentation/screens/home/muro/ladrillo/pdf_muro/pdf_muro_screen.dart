import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:meter_app/presentation/assets/images.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  Future<File> generatePdf({
    required String date,
    required String quotationNumber,
    required String projectName,
    required String professionalName,
    required String workPart,
    required List<Map<String, String>> materials,
  }) async {
    final pdf = pw.Document();

    // Cargar imágenes
    final logoImage = pw.MemoryImage((await rootBundle.load(AppImages.metrashopLogo)).buffer.asUint8List());
    final footerImage = pw.MemoryImage((await rootBundle.load(AppImages.qrintegraImg)).buffer.asUint8List());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado con logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logoImage, width: 100),
                  pw.Text(
                    'METRASHOP - LISTA DE MATERIALES',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#003366'),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Información de cotización y proyecto
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Fecha: $date', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
                  pw.Text('Número de cotización: $quotationNumber', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Proyecto: $projectName', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Profesional: $professionalName', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Text('Partida de trabajo: $workPart', style: pw.TextStyle(fontSize: 12, color: PdfColors.black)),
              pw.Divider(),
              pw.SizedBox(height: 16),

              // Tabla de materiales
              pw.Text(
                'Materiales:',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
              ),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColor.fromHex('#DDDDDD')),
                columnWidths: {
                  0: pw.FractionColumnWidth(0.5),
                  1: pw.FractionColumnWidth(0.25),
                  2: pw.FractionColumnWidth(0.25),
                },
                children: [
                  // Encabezado de la tabla
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColor.fromHex('#E0E0E0')),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Descripción',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#003366')),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Unidad',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#003366')),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Cantidad',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#003366')),
                        ),
                      ),
                    ],
                  ),
                  // Filas dinámicas de la tabla
                  ...materials.map(
                        (material) => pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.white),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(material['description'] ?? '', style: pw.TextStyle(color: PdfColors.black)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(material['unit'] ?? '', style: pw.TextStyle(color: PdfColors.black)),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(material['quantity'] ?? '', style: pw.TextStyle(color: PdfColors.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Frase de cierre y advertencia
              pw.Text(
                '“CALCULA Y COMPRA SIN PARAR DE CONSTRUIR”',
                style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic, color: PdfColors.grey),
                textAlign: pw.TextAlign.center,
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Importante:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
              ),
              pw.Text(
                'Los resultados presentados están basados en la dosificación especificada y en la calidad de los materiales mencionados en la lista de materiales.',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
              ),
              pw.Text(
                'Unidad de medida: balde (20 litros)',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.black),
              ),
              pw.SizedBox(height: 16),

              // Pie de página con imagen
              pw.Image(footerImage, width: 100, fit: pw.BoxFit.scaleDown),
            ],
          );
        },
      ),
    );

    // Guardar el archivo en almacenamiento temporal
    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/material_list.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
