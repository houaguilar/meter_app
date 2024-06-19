import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../providers/providers.dart';
import 'pdf_pisos_screen.dart';

class PreviewPisosScreen extends ConsumerWidget {
  const PreviewPisosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final pisos = ref.watch(pisosResultProvider);

    final arenaPisos = ref.watch(cantidadArenaPisosProvider);
    final cementoPisos = ref.watch(cantidadCementoPisosProvider);
    final piedraPisos = ref.watch(cantidadPiedraChancadaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Preview'),
      ),
      body: PdfPreview(
        build: (context) => makePdfPisos(
          pisos,
          arenaPisos,
          cementoPisos,
          piedraPisos
        ),
      ),
    );
  }
}
