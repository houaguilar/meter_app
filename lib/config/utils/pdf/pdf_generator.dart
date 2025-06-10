import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Clase para generar PDFs estandarizados para MetraShop
class MetraShopPDFGenerator {
  static const String _logoPath = 'assets/images/metrashop.png';

  /// Genera un PDF con el formato estandarizado de MetraShop
  static Future<File> generatePDF({
    required PDFData data,
    String? customFileName,
  }) async {
    final pdf = pw.Document();

    // Cargar logo
    final Uint8List? logoBytes = await _loadLogo();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header con logo y título
            _buildHeader(logoBytes, data.titulo),
            pw.SizedBox(height: 30),

            // Información del proyecto
            _buildProjectInfo(data),
            pw.SizedBox(height: 25),

            // Tabla de materiales
            _buildMaterialsTable(data.materiales),
            pw.SizedBox(height: 25),

            // Tabla de metrado (si existe)
            if (data.metrado.isNotEmpty) ...[
              _buildMetradoTable(data.metrado),
              pw.SizedBox(height: 25),
            ],

            // Observaciones (si existen)
            if (data.observaciones.isNotEmpty) ...[
              _buildObservations(data.observaciones),
              pw.SizedBox(height: 25),
            ],

            // Marcas aliadas
            pw.Spacer(),
            _buildFooter(),
          ],
        ),
      ),
    );

    // Guardar archivo
    final output = await getTemporaryDirectory();
    final fileName = customFileName ??
        'lista_materiales_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Carga el logo de MetraShop
  static Future<Uint8List?> _loadLogo() async {
    try {
      final ByteData data = await rootBundle.load(_logoPath);
      return data.buffer.asUint8List();
    } catch (e) {
      print('⚠️ No se pudo cargar el logo: $e');
      return null;
    }
  }

  /// Construye el header del PDF
  static pw.Widget _buildHeader(Uint8List? logoBytes, String titulo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo
        if (logoBytes != null)
          pw.Container(
            width: 80,
            height: 80,
            child: pw.Image(pw.MemoryImage(logoBytes)),
          )
        else
          pw.Container(
            width: 80,
            height: 80,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                'M',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 32,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),

        pw.SizedBox(width: 20),

        // Título y subtítulo
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                titulo.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                height: 3,
                width: 150,
                color: PdfColors.orange,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'SOLICITA Y COMPRA TU PARA DE CONSTRUCCIÓN',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
        ),

        // QR Code placeholder
        pw.Container(
          width: 60,
          height: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Center(
            child: pw.Text(
              'QR',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Construye la información del proyecto
  static pw.Widget _buildProjectInfo(PDFData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildInfoRow('Fecha:', data.fecha),
          _buildInfoRow('Número de cotización:', data.numeroCotizacion),
          _buildInfoRow('Proyecto:', data.proyecto),
          _buildInfoRow('Obra:', data.obra),
          _buildInfoRow('Partida de trabajo:', data.partida),
        ],
      ),
    );
  }

  /// Construye una fila de información
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey800,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la tabla de materiales
  static pw.Widget _buildMaterialsTable(List<MaterialItem> materiales) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DESCRIPCIÓN',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue,
              ),
              children: [
                _buildTableCell('DESCRIPCIÓN', isHeader: true),
                _buildTableCell('UNIDAD', isHeader: true),
                _buildTableCell('CANTIDAD', isHeader: true),
              ],
            ),

            // Filas de datos
            ...materiales.map((material) => pw.TableRow(
              children: [
                _buildTableCell(material.descripcion),
                _buildTableCell(material.unidad),
                _buildTableCell(material.cantidad),
              ],
            )),
          ],
        ),
      ],
    );
  }

  /// Construye la tabla de metrado
  static pw.Widget _buildMetradoTable(List<MetradoItem> metrado) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DATOS DEL METRADO',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 10),

        pw.Table(
          border: pw.TableBorder.all(
            color: PdfColors.grey400,
            width: 0.5,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
            2: const pw.FlexColumnWidth(1),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue,
              ),
              children: [
                _buildTableCell('ELEMENTO', isHeader: true),
                _buildTableCell('UNIDAD', isHeader: true),
                _buildTableCell('MEDIDA', isHeader: true),
              ],
            ),

            // Filas de datos
            ...metrado.map((item) => pw.TableRow(
              children: [
                _buildTableCell(item.elemento),
                _buildTableCell(item.unidad),
                _buildTableCell(item.medida),
              ],
            )),

            // Fila de total si hay más de un elemento
            if (metrado.length > 1)
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey200,
                ),
                children: [
                  _buildTableCell('TOTAL:', isBold: true),
                  _buildTableCell(metrado.first.unidad, isBold: true),
                  _buildTableCell(_calculateTotal(metrado), isBold: true),
                ],
              ),
          ],
        ),
      ],
    );
  }

  /// Construye las observaciones
  static pw.Widget _buildObservations(List<String> observaciones) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Observaciones:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 8),

        ...observaciones.map((obs) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Text(
            '• $obs',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        )),
      ],
    );
  }

  /// Construye el footer con marcas aliadas
  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Text(
          'Marcas aliadas',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 8),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            _buildBrandPlaceholder('ADITIVOS'),
            _buildBrandPlaceholder('SODIMAC'),
            _buildBrandPlaceholder('LARK'),
            _buildBrandPlaceholder('SIDERPERU'),
          ],
        ),
      ],
    );
  }

  /// Construye un placeholder para las marcas
  static pw.Widget _buildBrandPlaceholder(String brand) {
    return pw.Container(
      width: 60,
      height: 25,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Text(
          brand,
          style: pw.TextStyle(
            fontSize: 8,
            color: PdfColors.grey600,
          ),
        ),
      ),
    );
  }

  /// Construye una celda de tabla
  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool isBold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.grey800,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  /// Calcula el total de un metrado
  static String _calculateTotal(List<MetradoItem> metrado) {
    double total = 0.0;
    for (var item in metrado) {
      total += double.tryParse(item.medida) ?? 0.0;
    }
    return total.toStringAsFixed(2);
  }
}

/// Clase para los datos del PDF
class PDFData {
  final String titulo;
  final String fecha;
  final String numeroCotizacion;
  final String proyecto;
  final String obra;
  final String partida;
  final List<MaterialItem> materiales;
  final List<MetradoItem> metrado;
  final List<String> observaciones;

  PDFData({
    required this.titulo,
    required this.fecha,
    required this.numeroCotizacion,
    required this.proyecto,
    required this.obra,
    required this.partida,
    required this.materiales,
    this.metrado = const [],
    this.observaciones = const [],
  });
}

/// Clase para los elementos de material
class MaterialItem {
  final String descripcion;
  final String unidad;
  final String cantidad;

  MaterialItem({
    required this.descripcion,
    required this.unidad,
    required this.cantidad,
  });
}

/// Clase para los elementos de metrado
class MetradoItem {
  final String elemento;
  final String unidad;
  final String medida;

  MetradoItem({
    required this.elemento,
    required this.unidad,
    required this.medida,
  });
}

/// Factory methods para crear PDFData desde diferentes tipos de datos

/// Para datos de ladrillos
extension LadrilloToPDF on dynamic {
  static PDFData createLadrilloPDF({
    required List<dynamic> ladrillos,
    required dynamic materials,
    required String proyecto,
  }) {
    return PDFData(
      titulo: 'Lista de Materiales',
      fecha: _formatDate(DateTime.now()),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: proyecto,
      obra: 'Casa de campo',
      partida: 'Muro',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento Andino',
          unidad: 'bolsas',
          cantidad: materials.cemento.ceil().toString(),
        ),
        MaterialItem(
          descripcion: 'Barra de construcción 3/8" - MARCA',
          unidad: 'varillas',
          cantidad: '5',
        ),
        MaterialItem(
          descripcion: 'Ladrillos - MARCA',
          unidad: 'unidades',
          cantidad: materials.ladrillos.toStringAsFixed(0),
        ),
        MaterialItem(
          descripcion: 'Arena chancada gruesa - MARCA',
          unidad: 'bolsa',
          cantidad: materials.arena.toStringAsFixed(2),
        ),
      ],
      metrado: ladrillos.map<MetradoItem>((ladrillo) => MetradoItem(
        elemento: ladrillo.description,
        unidad: 'm²',
        medida: _calcularAreaLadrillo(ladrillo).toStringAsFixed(2),
      )).toList(),
      observaciones: [
        'Los resultados presentados están basados en la especificación y en la calidad de los materiales.',
        'Las cantidades pueden variar según las condiciones del sitio.',
        'Se recomienda considerar un 5-10% adicional por desperdicios.',
      ],
    );
  }

  static double _calcularAreaLadrillo(dynamic ladrillo) {
    if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
      return double.tryParse(ladrillo.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
      final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
      return largo * altura;
    }
  }
}

/// Para datos de losas
extension LosaToPDF on dynamic {
  static PDFData createLosaPDF({
    required List<dynamic> losas,
    required dynamic materials,
    required String proyecto,
  }) {
    return PDFData(
      titulo: 'Lista de Materiales',
      fecha: _formatDate(DateTime.now()),
      numeroCotizacion: _generateCotizationNumber(),
      proyecto: proyecto,
      obra: 'Casa de campo',
      partida: 'Losa Aligerada',
      materiales: [
        MaterialItem(
          descripcion: 'Cemento Andino',
          unidad: 'bls',
          cantidad: materials.cemento.ceil().toString(),
        ),
        MaterialItem(
          descripcion: 'Arena gruesa',
          unidad: 'm³',
          cantidad: materials.arena.toStringAsFixed(2),
        ),
        MaterialItem(
          descripcion: 'Piedra chancada',
          unidad: 'm³',
          cantidad: materials.piedra.toStringAsFixed(2),
        ),
        MaterialItem(
          descripcion: 'Agua',
          unidad: 'm³',
          cantidad: materials.agua.toStringAsFixed(2),
        ),
      ],
      metrado: losas.map<MetradoItem>((losa) => MetradoItem(
        elemento: losa.description,
        unidad: 'm²',
        medida: _calcularAreaLosa(losa).toStringAsFixed(2),
      )).toList(),
      observaciones: [
        'Cálculos basados en fórmulas del archivo Excel "CALCULO DE MATERIALES POR PARTIDAss.xlsx"',
        'El volumen de concreto se calcula como aproximadamente 40% del volumen total de la losa',
        'Los desperdicios están incluidos en las cantidades mostradas',
      ],
    );
  }

  static double _calcularAreaLosa(dynamic losa) {
    if (losa.area != null && losa.area!.isNotEmpty) {
      return double.tryParse(losa.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  }
}

/// Funciones auxiliares
String _formatDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} de ${_getMonthName(date.month)} ${date.year}';
}

String _getMonthName(int month) {
  const months = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];
  return months[month];
}

String _generateCotizationNumber() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
}