import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/router/app_router.dart';
import 'package:meter_app/presentation/screens/home/muro/ladrillo/pdf_muro/pdf_muro_screen.dart';
import 'dart:io';
import 'package:printing/printing.dart';

class PreviewScreen extends StatelessWidget {
  final File pdfFile;

  PreviewScreen({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vista previa del PDF'),
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
      ),
    );
  }
}

class MaterialListScreen extends StatelessWidget {
  final PdfGenerator pdfGenerator = PdfGenerator();

  MaterialListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generador de PDF")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Ejemplo de datos de materiales
            List<Map<String, String>> materials = [
              {"description": "Cemento MARCA", "unit": "bolsas", "quantity": "1"},
              {"description": "Barra de construcción 3/8\" - MARCA", "unit": "varillas", "quantity": "3"},
              {"description": "Ladrillos - MARCA", "unit": "unidades", "quantity": "1"},
              {"description": "Aditivo plastificante - MARCA", "unit": "litros", "quantity": "5"},
            ];

            final pdfFile = await pdfGenerator.generatePdf(
              date: "31 de Septiembre 2024",
              quotationNumber: "2024-0001",
              projectName: "Casa de campo",
              professionalName: "Ronal Romero",
              workPart: "Muro",
              materials: materials,
            );

            context.pushNamed('testpdf', extra: pdfFile);

          },
          child: Text("Generar PDF"),
        ),
      ),
    );
  }
}
