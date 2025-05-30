import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/utils/calculation_loader_extensions.dart';
import 'package:meter_app/presentation/assets/icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../config/theme/theme.dart';
import '../../../../../../data/models/models.dart';
import '../../../../../providers/providers.dart';
import '../../../../../widgets/widgets.dart';
import 'package:pdf/widgets.dart' as pw;

class ResultLadrilloScreen extends ConsumerWidget {
  const ResultLadrilloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        context.hideLoader();
      });
    });

    return WillPopScope(
      onWillPop: () async {
        ref.read(ladrilloResultProvider.notifier).clearList();
        return true;
      },
      child: Scaffold(
        appBar: AppBarWidget(titleAppBar: 'Resultado'),
        body: const _ResultLadrilloScreenView(),
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
              heroTag: 'save_button_wall',
              onPressed: () {
                final listaLadrillo = ref.watch(ladrilloResultProvider);
                if (listaLadrillo.isNotEmpty) {
                  context.pushNamed('save-ladrillo');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No hay datos para guardar')),
                  );
                }
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              context,
              ref,
              label: 'Compartir',
              icon: Icons.share_rounded,
              heroTag: 'share_button_wall',
              onPressed: () => _showOptionsDialog(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () {
            final listaLadrillo = ref.watch(ladrilloResultProvider);
            if (listaLadrillo.isNotEmpty) {
              context.pushNamed('map-screen-2');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No hay datos de ladrillos')),
              );
            }
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
                try {
                  Navigator.of(context).pop(); // Cerrar dialog
                  final pdfFile = await generatePdfNuevo(ref);
                  final xFile = XFile(pdfFile.path);
                  Share.shareXFiles([xFile], text: 'Resultados del metrado de ladrillos.');
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
                Navigator.of(context).pop(); // Cerrar dialog
                await Share.share(_shareContent(ref));
              },
            ),
          ],
        );
      },
    );
  }

  String _shareContent(WidgetRef ref) {
    final listaLadrillo = ref.watch(ladrilloResultProvider);

    if (listaLadrillo.isEmpty) {
      return 'Error: No hay datos de ladrillos';
    }

    String cantidadPruebaLadToString = calcularCantidadMaterialNuevo(listaLadrillo, calcularLadrillosNuevo).toStringAsFixed(0);
    String cantidadPruebaAreToString = calcularCantidadMaterialNuevo(listaLadrillo, calcularArenaNueva).toStringAsFixed(2);
    String cantidadPruebaCemToString = calcularCantidadMaterialNuevo(listaLadrillo, calcularCementoNuevo).ceilToDouble().toString();
    String cantidadPruebaAguaToString = calcularCantidadMaterialNuevo(listaLadrillo, calcularAguaNueva).toStringAsFixed(2);

    // Obtener factores de desperdicio del primer ladrillo (todos deberían tener los mismos)
    final primerLadrillo = listaLadrillo.first;
    final desperdicioLadrillo = double.tryParse(primerLadrillo.factorDesperdicio) ?? 5.0;
    final desperdicioMortero = double.tryParse(primerLadrillo.factorDesperdicioMortero) ?? 10.0;

    String datosMetrado = 'DATOS METRADO';
    String listaMateriales = 'LISTA DE MATERIALES';

    final datosLadrillo = ref.watch(datosShareLadrilloProvider);
    final shareText = '$datosMetrado \n$datosLadrillo \n-------------\n$listaMateriales \n*Arena gruesa: $cantidadPruebaAreToString m³ \n*Cemento: $cantidadPruebaCemToString bls \n*Agua: $cantidadPruebaAguaToString m³ \n*Ladrillo: $cantidadPruebaLadToString und \n\n*Desperdicio Ladrillo: ${desperdicioLadrillo.toStringAsFixed(1)}% \n*Desperdicio Mortero: ${desperdicioMortero.toStringAsFixed(1)}%';

    return shareText;
  }
}

class _ResultLadrilloScreenView extends ConsumerWidget {
  const _ResultLadrilloScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listaLadrillo = ref.watch(ladrilloResultProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(right: 24, left: 24, top: 10, bottom: 24),
      child: Column(
        children: [
          const SizedBox(height: 10),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon),
          const SizedBox(height: 10),
          if (listaLadrillo.isNotEmpty) ...[
            _buildSummaryCard(
              context,
              'Datos del Metrado',
              const _LadrilloContainer(),
            ),
            const SizedBox(height: 20),
            _buildSummaryCard(
              context,
              'Lista de Materiales',
              _buildMaterialList(ref),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 64,
                    color: Colors.orange[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay datos de ladrillos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Regresa y completa los datos para ver los resultados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
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
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryMetraShop
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

  Widget _buildMaterialList(WidgetRef ref) {
    final listaLadrillo = ref.watch(ladrilloResultProvider);

    if (listaLadrillo.isEmpty) {
      return const Text('No hay datos de ladrillos para calcular');
    }

    // Calcular cantidades totales usando las funciones actualizadas
    final cantidadLadrillos = calcularCantidadMaterialNuevo(listaLadrillo, calcularLadrillosNuevo).toStringAsFixed(0);
    final cantidadArenaTotal = calcularCantidadMaterialNuevo(listaLadrillo, calcularArenaNueva).toStringAsFixed(2);
    final cantidadCementoTotal = calcularCantidadMaterialNuevo(listaLadrillo, calcularCementoNuevo).ceilToDouble().toString();
    final cantidadAguaTotal = calcularCantidadMaterialNuevo(listaLadrillo, calcularAguaNueva).toStringAsFixed(2);

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2), // Ancho para la descripción
        1: FlexColumnWidth(1), // Ancho para la unidad
        2: FlexColumnWidth(2), // Ancho para la cantidad
      },
      children: [
        _buildMaterialRow('Descripción', 'Und.', 'Cantidad', isHeader: true),
        _buildMaterialRow('Cemento', 'Bls', cantidadCementoTotal),
        _buildMaterialRow('Arena gruesa', 'm³', cantidadArenaTotal),
        _buildMaterialRow('Agua', 'm³', cantidadAguaTotal),
        _buildMaterialRow('Ladrillo', 'Und', cantidadLadrillos),
      ],
    );
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

class _LadrilloContainer extends ConsumerWidget {
  const _LadrilloContainer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(ladrilloResultProvider);

    return _buildLadrilloContainer(context, results);
  }

  Widget _buildLadrilloContainer(BuildContext context, List<Ladrillo> results) {
    if (results.isEmpty) {
      return const Text('No hay datos de ladrillos');
    }

    double calcularArea(Ladrillo ladrillo) {
      if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
        return double.tryParse(ladrillo.area!) ?? 0.0; // Si es área
      } else {
        final largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
        final altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
        return largo * altura; // Si es largo y altura
      }
    }

    // Calcular la suma total de todas las áreas
    double calcularSumaTotalDeAreas(List<Ladrillo> results) {
      double sumaTotal = 0.0;
      for (int i = 0; i < results.length; i++) {
        sumaTotal += calcularArea(results[i]);
      }
      return sumaTotal;
    }

    double sumaTotalDeAreas = calcularSumaTotalDeAreas(results);

    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2), // Ancho fijo para la primera columna
          1: FlexColumnWidth(1), // Ancho fijo para la segunda columna
          2: FlexColumnWidth(2), // Ancho fijo para la tercera columna
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
                  'Área',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          // Filas de datos
          for (var result in results)
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    result.description,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'm²',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    calcularArea(result).toStringAsFixed(2), // Mostrar el área calculada
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
                  'm²',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  sumaTotalDeAreas.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FUNCIONES DE CÁLCULO ACTUALIZADAS BASADAS EN EL EXCEL
// ============================================================================

// Datos de tipos de ladrillos con sus dimensiones (en cm)
Map<String, Map<String, double>> get tiposLadrillo => {
  'Pandereta': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
  'Pandereta1': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
  'Pandereta2': {'largo': 23.0, 'ancho': 12.0, 'alto': 9.0},
  'Kingkong': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
  'Kingkong1': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
  'Kingkong2': {'largo': 24.0, 'ancho': 13.0, 'alto': 9.0},
  'Común': {'largo': 24.0, 'ancho': 12.0, 'alto': 8.0},
};

// Proporciones de mortero con sus factores
Map<String, Map<String, double>> get proporcionesMortero => {
  '3': {'cemento': 454.0, 'arena': 1.1, 'agua': 250.0},
  '4': {'cemento': 364.0, 'arena': 1.16, 'agua': 240.0},
  '5': {'cemento': 302.0, 'arena': 1.2, 'agua': 240.0},
  '6': {'cemento': 261.0, 'arena': 1.2, 'agua': 235.0},
};

// Función para obtener el área de un muro
double obtenerAreaLadrillo(Ladrillo ladrillo) {
  if (ladrillo.area != null && ladrillo.area!.isNotEmpty) {
    return double.tryParse(ladrillo.area!) ?? 0.0;
  } else {
    double largo = double.tryParse(ladrillo.largo ?? '') ?? 0.0;
    double altura = double.tryParse(ladrillo.altura ?? '') ?? 0.0;
    return largo * altura;
  }
}

// Función para calcular cantidad total de material
double calcularCantidadMaterialNuevo(List<Ladrillo> ladrillos, double Function(Ladrillo) calcularFuncion) {
  return ladrillos.fold(0.0, (suma, ladrillo) => suma + calcularFuncion(ladrillo));
}

// Función principal para calcular ladrillos actualizada
double calcularLadrillosNuevo(Ladrillo ladrillo) {
  double area = obtenerAreaLadrillo(ladrillo);
  double factorDesperdicioLadrillo = (double.tryParse(ladrillo.factorDesperdicio) ?? 5.0) / 100;

  String tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
  Map<String, double>? dimensiones = tiposLadrillo[tipoLadrilloKey];

  if (dimensiones == null) {
    // Usar Pandereta por defecto
    dimensiones = tiposLadrillo['Pandereta']!;
  }

  double largo = dimensiones['largo']!;
  double ancho = dimensiones['ancho']!;
  double alto = dimensiones['alto']!;

  // Cálculo de ladrillos por m² según forma de asentado
  double ladrillosPorM2;

  if (ladrillo.tipoAsentado == 'soga') {
    // Usar largo y alto, considerando juntas de 1.5 cm
    ladrillosPorM2 = 1 / ((((largo + 1.5) / 100) * ((alto + 1.5) / 100)));
  } else if (ladrillo.tipoAsentado == 'cabeza') {
    // Usar ancho y alto, considerando juntas de 1.5 cm
    ladrillosPorM2 = 1 / ((((ancho + 1.5) / 100) * ((alto + 1.5) / 100)));
  } else { // canto
    // Usar largo y ancho, considerando juntas de 1.5 cm
    ladrillosPorM2 = 1 / ((((largo + 1.5) / 100) * ((ancho + 1.5) / 100)));
  }

  // Aplicar factor de desperdicio de ladrillo
  double ladrillosPorM2ConDesperdicio = ladrillosPorM2 * (1 + factorDesperdicioLadrillo);

  return ladrillosPorM2ConDesperdicio * area;
}

// Función para calcular el volumen de mortero
double calcularVolumenMorteroNuevo(Ladrillo ladrillo) {
  double area = obtenerAreaLadrillo(ladrillo);

  String tipoLadrilloKey = _normalizarTipoLadrillo(ladrillo.tipoLadrillo);
  Map<String, double>? dimensiones = tiposLadrillo[tipoLadrilloKey];

  if (dimensiones == null) {
    dimensiones = tiposLadrillo['Pandereta']!;
  }

  double largo = dimensiones['largo']! / 100; // convertir a metros
  double ancho = dimensiones['ancho']! / 100; // convertir a metros
  double alto = dimensiones['alto']! / 100; // convertir a metros

  // Calcular ladrillos por m² sin desperdicio para el cálculo de volumen
  double ladrillosPorM2Sin;
  if (ladrillo.tipoAsentado == 'soga') {
    ladrillosPorM2Sin = 1 / ((((dimensiones['largo']! + 1.5) / 100) * ((dimensiones['alto']! + 1.5) / 100)));
  } else if (ladrillo.tipoAsentado == 'cabeza') {
    ladrillosPorM2Sin = 1 / ((((dimensiones['ancho']! + 1.5) / 100) * ((dimensiones['alto']! + 1.5) / 100)));
  } else { // canto
    ladrillosPorM2Sin = 1 / ((((dimensiones['largo']! + 1.5) / 100) * ((dimensiones['ancho']! + 1.5) / 100)));
  }

  // Volumen del ladrillo individual
  double volumenLadrillo = largo * ancho * alto;

  // Espesor del muro según el tipo de asentado
  double espesorMuro;
  if (ladrillo.tipoAsentado == 'soga') {
    espesorMuro = ancho; // ancho del ladrillo
  } else if (ladrillo.tipoAsentado == 'cabeza') {
    espesorMuro = largo; // largo del ladrillo
  } else { // canto
    espesorMuro = alto; // alto del ladrillo
  }

  // Volumen de mortero por m² = Volumen bruto - Volumen ocupado por ladrillos
  double morteroM3PorM2 = (1.0 * 1.0 * espesorMuro) - (ladrillosPorM2Sin * volumenLadrillo);

  return morteroM3PorM2 * area;
}

// Función para calcular cemento
double calcularCementoNuevo(Ladrillo ladrillo) {
  double volumenMortero = calcularVolumenMorteroNuevo(ladrillo);

  // Obtener factor de desperdicio de mortero directamente del ladrillo
  double factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

  String proporcionStr = ladrillo.proporcionMortero;
  Map<String, double>? datosProporcion = proporcionesMortero[proporcionStr];

  if (datosProporcion == null) {
    // Usar 1:4 por defecto
    datosProporcion = proporcionesMortero['4']!;
  }

  // Factor cemento (bolsas por m³ de mortero)
  double factorCemento = datosProporcion['cemento']! / 42.5; // 42.5 kg por bolsa

  // Cálculo de cemento sin desperdicio
  double cementoSinDesperdicio = factorCemento * volumenMortero;

  // Aplicar factor de desperdicio de mortero
  return cementoSinDesperdicio * (1 + factorDesperdicioMortero);
}

// Función para calcular arena
double calcularArenaNueva(Ladrillo ladrillo) {
  double volumenMortero = calcularVolumenMorteroNuevo(ladrillo);

  // Obtener factor de desperdicio de mortero directamente del ladrillo
  double factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

  String proporcionStr = ladrillo.proporcionMortero;
  Map<String, double>? datosProporcion = proporcionesMortero[proporcionStr];

  if (datosProporcion == null) {
    // Usar 1:4 por defecto
    datosProporcion = proporcionesMortero['4']!;
  }

  // Cálculo de arena sin desperdicio
  double arenaSinDesperdicio = datosProporcion['arena']! * volumenMortero;

  // Aplicar factor de desperdicio de mortero
  return arenaSinDesperdicio * (1 + factorDesperdicioMortero);
}

// Función para calcular agua
double calcularAguaNueva(Ladrillo ladrillo) {
  double volumenMortero = calcularVolumenMorteroNuevo(ladrillo);

  // Obtener factor de desperdicio de mortero directamente del ladrillo
  double factorDesperdicioMortero = (double.tryParse(ladrillo.factorDesperdicioMortero) ?? 10.0) / 100;

  String proporcionStr = ladrillo.proporcionMortero;
  Map<String, double>? datosProporcion = proporcionesMortero[proporcionStr];

  if (datosProporcion == null) {
    // Usar 1:4 por defecto
    datosProporcion = proporcionesMortero['4']!;
  }

  // Cálculo de agua basado en la fórmula del Excel
  // Factor cemento para calcular el agua correctamente
  double factorCemento = datosProporcion['cemento']! / 42.5;
  double aguaSinDesperdicio = ((factorCemento * (42.5 * 0.8)) / 1000) * volumenMortero;

  // Aplicar factor de desperdicio de mortero
  return aguaSinDesperdicio * (1 + factorDesperdicioMortero);
}

// Función auxiliar para normalizar el tipo de ladrillo
String _normalizarTipoLadrillo(String tipo) {
  switch (tipo.toLowerCase()) {
    case 'pandereta':
    case 'pandereta1':
    case 'pandereta2':
      return 'Pandereta';
    case 'kingkong':
    case 'kingkong1':
    case 'kingkong2':
    case 'king kong':
      return 'Kingkong';
    case 'común':
    case 'comun':
      return 'Común';
    default:
      return 'Pandereta'; // Por defecto
  }
}

// Función para generar PDF actualizada
Future<File> generatePdfNuevo(WidgetRef ref) async {
  final pdf = pw.Document();
  final listaLadrillo = ref.watch(ladrilloResultProvider);

  if (listaLadrillo.isEmpty) {
    throw Exception('No hay datos de ladrillos para generar PDF');
  }

  String title = 'Resultados de Muros de Ladrillos';

  // Calcular totales con las nuevas funciones
  final cantidadLadrillos = calcularCantidadMaterialNuevo(listaLadrillo, calcularLadrillosNuevo);
  final cantidadArena = calcularCantidadMaterialNuevo(listaLadrillo, calcularArenaNueva);
  final cantidadCemento = calcularCantidadMaterialNuevo(listaLadrillo, calcularCementoNuevo);
  final cantidadAgua = calcularCantidadMaterialNuevo(listaLadrillo, calcularAguaNueva);

  // Obtener factores de desperdicio del primer ladrillo
  final primerLadrillo = listaLadrillo.first;
  final desperdicioLadrillo = double.tryParse(primerLadrillo.factorDesperdicio) ?? 5.0;
  final desperdicioMortero = double.tryParse(primerLadrillo.factorDesperdicioMortero) ?? 10.0;

  // Calcular área total
  final areaTotal = listaLadrillo.fold(0.0, (sum, l) => sum + obtenerAreaLadrillo(l));

  pdf.addPage(
    pw.Page(
      build: (context) => pw.Center(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),

            // Información del proyecto
            pw.Text('INFORMACIÓN DEL PROYECTO:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('• Tipo de Ladrillo: ${primerLadrillo.tipoLadrillo}'),
            pw.Text('• Tipo de Asentado: ${primerLadrillo.tipoAsentado}'),
            pw.Text('• Proporción Mortero: 1:${primerLadrillo.proporcionMortero}'),
            pw.Text('• Área total: ${areaTotal.toStringAsFixed(2)} m²'),
            pw.Text('• Total de muros: ${listaLadrillo.length}'),
            pw.SizedBox(height: 20),

            // Materiales calculados
            pw.Text('MATERIALES CALCULADOS:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('• Ladrillos: ${cantidadLadrillos.toStringAsFixed(0)} unidades'),
            pw.Text('• Arena gruesa: ${cantidadArena.toStringAsFixed(2)} m³'),
            pw.Text('• Cemento: ${cantidadCemento.ceilToDouble()} bolsas'),
            pw.Text('• Agua: ${cantidadAgua.toStringAsFixed(2)} m³'),
            pw.SizedBox(height: 20),

            // Configuración aplicada
            pw.Text('CONFIGURACIÓN APLICADA:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('• Desperdicio de Ladrillo: ${desperdicioLadrillo.toStringAsFixed(1)}%'),
            pw.Text('• Desperdicio de Mortero: ${desperdicioMortero.toStringAsFixed(1)}%'),
            pw.SizedBox(height: 20),

            // Detalle de muros
            pw.Text('DETALLE DE MUROS:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            ...listaLadrillo.map((ladrillo) => pw.Text(
              '• ${ladrillo.description}: ${obtenerAreaLadrillo(ladrillo).toStringAsFixed(2)} m²',
              style: pw.TextStyle(fontSize: 12),
            )),
            pw.SizedBox(height: 20),

            // Información adicional
            pw.Text('INFORMACIÓN TÉCNICA:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('• Cálculos basados en las fórmulas del Excel "CALCULO DE MATERIALES POR PARTIDAss.xlsx"',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Incluye juntas de mortero de 1.5 cm horizontales y verticales',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Factores de desperdicio aplicados de forma independiente',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
            pw.Text('• Generado por METRASHOP - ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_ladrillos_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}