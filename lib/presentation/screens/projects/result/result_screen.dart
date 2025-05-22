import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../../config/constants/constants.dart';
import '../../../../config/theme/theme.dart';
import '../../../../domain/entities/entities.dart';
import '../../../../domain/entities/home/estructuras/columna/columna.dart';
import '../../../../domain/entities/home/estructuras/viga/viga.dart';
import '../../../../domain/entities/home/losas/losas.dart';
import '../../../assets/icons.dart';
import '../../../blocs/projects/metrados/result/result_bloc.dart';
import '../../../widgets/app_bar/app_bar_projects_widget.dart';

class ResultScreen extends StatefulWidget {
  final String metradoId;

  const ResultScreen({required this.metradoId, super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  void _loadResults() {
    context.read<ResultBloc>().add(LoadResultsEvent(metradoId: widget.metradoId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarProjectsWidget(titleAppBar: 'Resultados Guardados'),
      body: BlocBuilder<ResultBloc, ResultState>(
        builder: (context, state) {
          if (state is ResultLoading) {
            return const _LoadingIndicator();
          } else if (state is ResultSuccess) {
            return _ResultContent(results: state.results, metradoId: widget.metradoId);
          } else if (state is ResultFailure) {
            return _ErrorDisplay(message: state.message, onRetry: _loadResults);
          } else {
            return const _EmptyResultsMessage();
          }
        },
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueMetraShop),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando resultados guardados...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primaryMetraShop,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorDisplay({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 16),
            Text(
              'Error al cargar los resultados',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueMetraShop,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResultsMessage extends StatelessWidget {
  const _EmptyResultsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppIcons.archiveProjectIcon,
              width: 64,
              height: 64,
              colorFilter: const ColorFilter.mode(
                AppColors.yellowMetraShop,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay resultados disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryMetraShop,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este metrado no tiene cálculos guardados todavía.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blueMetraShop,
                side: const BorderSide(color: AppColors.blueMetraShop),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  final List<dynamic> results;
  final String metradoId;

  const _ResultContent({required this.results, required this.metradoId});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const _EmptyResultsMessage();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SvgPicture.asset(AppIcons.checkmarkCircleIcon, height: 48),
          const SizedBox(height: 16),

          // Detected type label
          _ResultTypeHeader(results: results),

          // Metrado details card
          _MetradoDetailsCard(results: results),

          // Materials list card
          _MaterialsListCard(results: results),

          // Action buttons
          _ActionButtons(results: results, metradoId: metradoId),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ResultTypeHeader extends StatelessWidget {
  final List<dynamic> results;

  const _ResultTypeHeader({required this.results});

  @override
  Widget build(BuildContext context) {
    String resultType = _getResultType();
    Color typeColor = _getTypeColor();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: typeColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(),
            size: 18,
            color: typeColor,
          ),
          const SizedBox(width: 8),
          Text(
            resultType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getResultType() {
    if (results.isEmpty) return "Desconocido";

    final firstResult = results.first;
    if (firstResult is Ladrillo) return "Cálculo de Ladrillo";
    if (firstResult is Bloqueta) return "Cálculo de Bloqueta";
    if (firstResult is Piso) return "Cálculo de Piso";
    if (firstResult is LosaAligerada) return "Cálculo de Losa Aligerada";
    if (firstResult is Tarrajeo) return "Cálculo de Tarrajeo";
    if (firstResult is Columna) return "Cálculo de Columna";
    if (firstResult is Viga) return "Cálculo de Viga";

    return "Cálculo";
  }

  IconData _getTypeIcon() {
    if (results.isEmpty) return Icons.help_outline;

    final firstResult = results.first;
    if (firstResult is Ladrillo) return Icons.grid_view;
    if (firstResult is Bloqueta) return Icons.view_module;
    if (firstResult is Piso) return Icons.grid_on;
    if (firstResult is LosaAligerada) return Icons.layers;
    if (firstResult is Tarrajeo) return Icons.brush;
    if (firstResult is Columna) return Icons.view_column;
    if (firstResult is Viga) return Icons.horizontal_rule;

    return Icons.calculate;
  }

  Color _getTypeColor() {
    if (results.isEmpty) return Colors.grey;

    final firstResult = results.first;
    if (firstResult is Ladrillo) return Colors.brown;
    if (firstResult is Bloqueta) return Colors.indigo;
    if (firstResult is Piso) return Colors.teal;
    if (firstResult is LosaAligerada) return Colors.deepPurple;
    if (firstResult is Tarrajeo) return Colors.amber.shade700;
    if (firstResult is Columna || firstResult is Viga) return Colors.blue.shade800;

    return AppColors.blueMetraShop;
  }
}

class _MetradoDetailsCard extends StatelessWidget {
  final List<dynamic> results;

  const _MetradoDetailsCard({required this.results});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.yellowMetraShop,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment, color: AppColors.primaryMetraShop),
                const SizedBox(width: 8),
                const Text(
                  'Datos del Metrado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
                const Spacer(),
                Text(
                  '${results.length} item${results.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildDetailsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsContent() {
    if (results.isEmpty) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    // Determine the type of content
    final firstResult = results.first;

    if (firstResult is Ladrillo || firstResult is Bloqueta) {
      return _buildAreaTable();
    } else if (firstResult is Piso) {
      return _buildVolumeTable();
    } else if (firstResult is LosaAligerada) {
      return _buildAreaTable(isSlab: true);
    } else if (firstResult is Tarrajeo) {
      return _buildAreaTable(isCoating: true);
    } else if (firstResult is Columna || firstResult is Viga) {
      return _buildVolumeTable(isStructural: true);
    } else {
      return const Center(
        child: Text('Tipo de resultado no reconocido'),
      );
    }
  }

  Widget _buildAreaTable({bool isSlab = false, bool isCoating = false}) {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            _buildTableHeader(['Descripción', 'Und.', 'Área']),
            ...results.map((result) {
              String description = _getDescription(result);
              double area = _calculateArea(result);
              return _buildTableRow([
                description,
                'm²',
                area.toStringAsFixed(2),
              ]);
            }).toList(),
            _buildTotalRow(
              label: 'Total',
              unit: 'm²',
              value: _calculateTotalArea().toStringAsFixed(2),
            ),
          ],
        ),
        if (isSlab || isCoating) _buildAdditionalInfo(isSlab, isCoating),
      ],
    );
  }

  Widget _buildVolumeTable({bool isStructural = false}) {
    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            _buildTableHeader(['Descripción', 'Und.', 'Volumen']),
            ...results.map((result) {
              String description = _getDescription(result);
              double volume = _calculateVolume(result);
              return _buildTableRow([
                description,
                'm³',
                volume.toStringAsFixed(2),
              ]);
            }).toList(),
            _buildTotalRow(
              label: 'Total',
              unit: 'm³',
              value: _calculateTotalVolume().toStringAsFixed(2),
            ),
          ],
        ),
        if (isStructural) _buildStructuralInfo(),
      ],
    );
  }

  Widget _buildAdditionalInfo(bool isSlab, bool isCoating) {
    if (isSlab) {
      return _buildInfoBox(
        'Esta losa aligerada tiene un espesor de ${_getSlabHeight()} con ${_getConcreteResistance()}.',
        icon: Icons.info_outline,
      );
    } else if (isCoating) {
      return _buildInfoBox(
        'Este tarrajeo tiene un espesor de ${_getCoatingThickness()} con proporción ${_getCoatingProportion()}.',
        icon: Icons.info_outline,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildStructuralInfo() {
    final firstResult = results.first;
    String resistanceInfo = "";

    if (firstResult is Columna) {
      resistanceInfo = "f'c = ${firstResult.resistencia}";
    } else if (firstResult is Viga) {
      resistanceInfo = "f'c = ${firstResult.resistencia}";
    }

    return _buildInfoBox(
      'Elemento estructural con resistencia $resistanceInfo',
      icon: Icons.info_outline,
    );
  }

  Widget _buildInfoBox(String text, {IconData icon = Icons.info_outline}) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blueMetraShop.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.blueMetraShop.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.blueMetraShop),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTotalRow({
    required String label,
    required String unit,
    required String value,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[300],
      ),
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Total',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            unit,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    );
  }

  String _getDescription(dynamic result) {
    if (result is Ladrillo) return result.description;
    if (result is Bloqueta) return result.description;
    if (result is Piso) return result.description;
    if (result is LosaAligerada) return result.description;
    if (result is Tarrajeo) return result.description;
    if (result is Columna) return result.description;
    if (result is Viga) return result.description;
    return "Desconocido";
  }

  double _calculateArea(dynamic result) {
    if (result is Ladrillo) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final altura = double.tryParse(result.altura ?? '') ?? 0.0;
        return largo * altura;
      }
    } else if (result is Bloqueta) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final altura = double.tryParse(result.altura ?? '') ?? 0.0;
        return largo * altura;
      }
    } else if (result is LosaAligerada) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return largo * ancho;
      }
    } else if (result is Tarrajeo) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final longitud = double.tryParse(result.longitud ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return longitud * ancho;
      }
    }
    return 0.0;
  }

  double _calculateVolume(dynamic result) {
    if (result is Piso) {
      final espesor = double.tryParse(result.espesor) ?? 0.0;
      if (result.area != null && result.area!.isNotEmpty) {
        final area = double.tryParse(result.area!) ?? 0.0;
        return area * (espesor / 100); // Convert cm to m
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return largo * ancho * (espesor / 100); // Convert cm to m
      }
    } else if (result is Columna) {
      if (result.volumen != null && result.volumen!.isNotEmpty) {
        return double.tryParse(result.volumen!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        final altura = double.tryParse(result.altura ?? '') ?? 0.0;
        return largo * ancho * altura;
      }
    } else if (result is Viga) {
      if (result.volumen != null && result.volumen!.isNotEmpty) {
        return double.tryParse(result.volumen!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        final altura = double.tryParse(result.altura ?? '') ?? 0.0;
        return largo * ancho * altura;
      }
    }
    return 0.0;
  }

  double _calculateTotalArea() {
    double total = 0.0;
    for (var result in results) {
      total += _calculateArea(result);
    }
    return total;
  }

  double _calculateTotalVolume() {
    double total = 0.0;
    for (var result in results) {
      total += _calculateVolume(result);
    }
    return total;
  }

  String _getSlabHeight() {
    if (results.isNotEmpty && results.first is LosaAligerada) {
      final losa = results.first as LosaAligerada;
      return "${losa.altura}";
    }
    return "N/A";
  }

  String _getConcreteResistance() {
    if (results.isNotEmpty && results.first is LosaAligerada) {
      final losa = results.first as LosaAligerada;
      return "resistencia ${losa.resistenciaConcreto}";
    }
    return "N/A";
  }

  String _getCoatingThickness() {
    if (results.isNotEmpty && results.first is Tarrajeo) {
      final tarrajeo = results.first as Tarrajeo;
      return "${tarrajeo.espesor} cm";
    }
    return "N/A";
  }

  String _getCoatingProportion() {
    if (results.isNotEmpty && results.first is Tarrajeo) {
      final tarrajeo = results.first as Tarrajeo;
      return "1:${tarrajeo.proporcionMortero}";
    }
    return "N/A";
  }
}

class _MaterialsListCard extends StatelessWidget {
  final List<dynamic> results;

  const _MaterialsListCard({required this.results});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.yellowMetraShop,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primaryMetraShop),
                SizedBox(width: 8),
                Text(
                  'Lista de Materiales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryMetraShop,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMaterialsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    if (results.isEmpty) {
      return const Center(
        child: Text('No hay materiales disponibles'),
      );
    }

    final MaterialsCalculator calculator = MaterialsCalculator(results);
    final materials = calculator.calculateMaterials();

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(['Material', 'Und.', 'Cantidad']),
        ...materials.map((material) {
          return _buildTableRow([
            material.description,
            material.unit,
            material.quantity,
          ]);
        }).toList(),
      ],
    );
  }

  TableRow _buildTableHeader(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: const TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final List<dynamic> results;
  final String metradoId;

  const _ActionButtons({required this.results, required this.metradoId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'Visualizar PDF',
                  icon: Icons.picture_as_pdf,
                  color: AppColors.blueMetraShop,
                  onPressed: () => _previewPdf(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'Compartir',
                  icon: Icons.share,
                  color: AppColors.primaryMetraShop,
                  onPressed: () => _showShareOptions(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            context,
            title: 'Buscar Proveedores',
            icon: Icons.map,
            color: Colors.green,
            onPressed: () => context.pushNamed('map-screen-projects'),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onPressed,
        bool isFullWidth = false,
      }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _previewPdf(BuildContext context) async {
    try {
      final pdf = await generatePdf(results);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfPreviewPage(pdfFile: pdf),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showShareOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Compartir como PDF'),
              onTap: () async {
                Navigator.pop(context);
                await _sharePdf(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.text_format),
              title: const Text('Compartir como texto'),
              onTap: () async {
                Navigator.pop(context);
                await _shareText(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdfFile = await generatePdf(results);
      final xFile = XFile(pdfFile.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Resultados de cálculo - MetraShop',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _shareText(BuildContext context) async {
    try {
      final text = _generateShareText();
      await Share.share(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al compartir texto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _generateShareText() {
    final MaterialsCalculator calculator = MaterialsCalculator(results);
    final materials = calculator.calculateMaterials();

    String resultType = _getResultTypeName();
    String itemsText = _getItemsText();
    String materialsText = _getMaterialsText(materials);

    return """METRASHOP - $resultType

DATOS DEL METRADO
$itemsText

LISTA DE MATERIALES
$materialsText

Calculado con la app MetraShop.
""";
  }

  String _getResultTypeName() {
    if (results.isEmpty) return "Resultados";

    final firstResult = results.first;
    if (firstResult is Ladrillo) return "Cálculo de Ladrillo";
    if (firstResult is Bloqueta) return "Cálculo de Bloqueta";
    if (firstResult is Piso) return "Cálculo de Piso";
    if (firstResult is LosaAligerada) return "Cálculo de Losa Aligerada";
    if (firstResult is Tarrajeo) return "Cálculo de Tarrajeo";
    if (firstResult is Columna) return "Cálculo de Columna";
    if (firstResult is Viga) return "Cálculo de Viga";

    return "Cálculo";
  }

  String _getItemsText() {
    if (results.isEmpty) return "No hay datos disponibles.";

    String text = "";
    double total = 0.0;
    bool isVolumeCalculation = false;

    final firstResult = results.first;
    // Check if it's volume or area calculation
    if (firstResult is Piso || firstResult is Columna || firstResult is Viga) {
      isVolumeCalculation = true;
    }

    for (var result in results) {
      String description = _getDescription(result);
      double value = isVolumeCalculation ? _calculateVolume(result) : _calculateArea(result);
      total += value;

      text += "* $description: ${value.toStringAsFixed(2)} ${isVolumeCalculation ? 'm³' : 'm²'}\n";
    }

    text += "\nTotal: ${total.toStringAsFixed(2)} ${isVolumeCalculation ? 'm³' : 'm²'}";
    return text;
  }

  String _getMaterialsText(List<Material> materials) {
    if (materials.isEmpty) return "No hay materiales disponibles.";

    String text = "";
    for (var material in materials) {
      text += "* ${material.description}: ${material.quantity} ${material.unit}\n";
    }

    return text;
  }

  String _getDescription(dynamic result) {
    if (result is Ladrillo) return result.description;
    if (result is Bloqueta) return result.description;
    if (result is Piso) return result.description;
    if (result is LosaAligerada) return result.description;
    if (result is Tarrajeo) return result.description;
    if (result is Columna) return result.description;
    if (result is Viga) return result.description;
    return "Desconocido";
  }

  double _calculateVolume(dynamic result) {
    if (result is Piso) {
      final espesor = double.tryParse(result.espesor) ?? 0.0;
      if (result.area != null && result.area!.isNotEmpty) {
        final area = double.tryParse(result.area!) ?? 0.0;
        return area * (espesor / 100); // Convert cm to m
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return largo * ancho * (espesor / 100); // Convert cm to m
      }
    } else if (result is Columna || result is Viga) {
      if ((result as dynamic).volumen != null && (result as dynamic).volumen!.isNotEmpty) {
        return double.tryParse((result as dynamic).volumen!) ?? 0.0;
      } else {
        final largo = double.tryParse((result as dynamic).largo ?? '') ?? 0.0;
        final ancho = double.tryParse((result as dynamic).ancho ?? '') ?? 0.0;
        final altura = double.tryParse((result as dynamic).altura ?? '') ?? 0.0;
        return largo * ancho * altura;
      }
    }
    return 0.0;
  }

  double _calculateArea(dynamic result) {
    if (result is Ladrillo || result is Bloqueta) {
      if ((result as dynamic).area != null && (result as dynamic).area!.isNotEmpty) {
        return double.tryParse((result as dynamic).area!) ?? 0.0;
      } else {
        final largo = double.tryParse((result as dynamic).largo ?? '') ?? 0.0;
        final altura = double.tryParse((result as dynamic).altura ?? '') ?? 0.0;
        return largo * altura;
      }
    } else if (result is LosaAligerada) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(result.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return largo * ancho;
      }
    } else if (result is Tarrajeo) {
      if (result.area != null && result.area!.isNotEmpty) {
        return double.tryParse(result.area!) ?? 0.0;
      } else {
        final longitud = double.tryParse(result.longitud ?? '') ?? 0.0;
        final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
        return longitud * ancho;
      }
    }
    return 0.0;
  }
}

// PDF preview page
class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;

  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final xFile = XFile(pdfFile.path);
              await Share.shareXFiles([xFile], text: 'Resultados de cálculo - MetraShop');
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfFile.readAsBytes(),
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
      ),
    );
  }
}

// Helper class to generate PDF
Future<File> generatePdf(List<dynamic> results) async {
  final pdf = pw.Document();

  final resultType = _getResultType(results);
  final materials = MaterialsCalculator(results).calculateMaterials();

  // Load logo image if available
  pw.MemoryImage? logoImage;
  try {
    final logoBytes = await rootBundle.load('assets/images/metrashop_logo.png');
    logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());
  } catch (e) {
    // Logo not available, continue without it
  }

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                logoImage != null
                    ? pw.Image(logoImage, width: 100)
                    : pw.Text('METRASHOP', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  'RESULTADOS DE CÁLCULO',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#003366'),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 16),

            // Result type
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F5C845').shade(0.3),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                resultType,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 16),

            // Date and info
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Fecha: ${_getCurrentDate()}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('ID: ${_generateId()}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 16),

            // Measurements table
            pw.Text(
              'DATOS DEL METRADO',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfMeasurementsTable(results),
            pw.SizedBox(height: 24),

            // Materials table
            pw.Text(
              'LISTA DE MATERIALES',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            _buildPdfMaterialsTable(materials),

            // Footer
            pw.Spacer(),
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
                'MetraShop App',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ),
          ],
        );
      },
    ),
  );

  // Save to temp file
  final output = await getTemporaryDirectory();
  final file = File('${output.path}/resultados_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());
  return file;
}

pw.Widget _buildPdfMeasurementsTable(List<dynamic> results) {
  final isVolumeCalculation = results.isNotEmpty &&
      (results.first is Piso || results.first is Columna || results.first is Viga);

  List<List<String>> tableData = [];
  double total = 0.0;

  // Add headers
  tableData.add([
    'Descripción',
    'Und.',
    isVolumeCalculation ? 'Volumen' : 'Área'
  ]);

  // Add data rows
  for (var result in results) {
    String description = _getResultDescription(result);
    double value = isVolumeCalculation
        ? _calculateResultVolume(result)
        : _calculateResultArea(result);
    total += value;

    tableData.add([
      description,
      isVolumeCalculation ? 'm³' : 'm²',
      value.toStringAsFixed(2),
    ]);
  }

  // Add total row
  tableData.add([
    'Total',
    isVolumeCalculation ? 'm³' : 'm²',
    total.toStringAsFixed(2),
  ]);

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
    children: tableData.map((rowData) {
      final isHeader = rowData[0] == 'Descripción';
      final isFooter = rowData[0] == 'Total';

      return pw.TableRow(
        decoration: isHeader || isFooter
            ? const pw.BoxDecoration(color: PdfColors.grey200)
            : null,
        children: rowData.map((cell) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              cell,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isHeader || isFooter
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

pw.Widget _buildPdfMaterialsTable(List<Material> materials) {
  List<List<String>> tableData = [];

  // Add headers
  tableData.add(['Descripción', 'Und.', 'Cantidad']);

  // Add material rows
  for (var material in materials) {
    tableData.add([
      material.description,
      material.unit,
      material.quantity,
    ]);
  }

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
    children: tableData.map((rowData) {
      final isHeader = rowData[0] == 'Descripción';

      return pw.TableRow(
        decoration: isHeader
            ? const pw.BoxDecoration(color: PdfColors.grey200)
            : null,
        children: rowData.map((cell) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(
              cell,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: isHeader
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

String _getResultType(List<dynamic> results) {
  if (results.isEmpty) return "Resultados del Cálculo";

  final firstResult = results.first;
  if (firstResult is Ladrillo) return "Resultados del Cálculo de Ladrillo";
  if (firstResult is Bloqueta) return "Resultados del Cálculo de Bloqueta";
  if (firstResult is Piso) return "Resultados del Cálculo de Piso";
  if (firstResult is LosaAligerada) return "Resultados del Cálculo de Losa Aligerada";
  if (firstResult is Tarrajeo) return "Resultados del Cálculo de Tarrajeo";
  if (firstResult is Columna) return "Resultados del Cálculo de Columna";
  if (firstResult is Viga) return "Resultados del Cálculo de Viga";

  return "Resultados del Cálculo";
}

String _getCurrentDate() {
  final now = DateTime.now();
  return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
}

String _generateId() {
  return DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8);
}

String _getResultDescription(dynamic result) {
  if (result is Ladrillo) return result.description;
  if (result is Bloqueta) return result.description;
  if (result is Piso) return result.description;
  if (result is LosaAligerada) return result.description;
  if (result is Tarrajeo) return result.description;
  if (result is Columna) return result.description;
  if (result is Viga) return result.description;
  return "Desconocido";
}

double _calculateResultArea(dynamic result) {
  if (result is Ladrillo || result is Bloqueta) {
    if ((result as dynamic).area != null && (result as dynamic).area!.isNotEmpty) {
      return double.tryParse((result as dynamic).area!) ?? 0.0;
    } else {
      final largo = double.tryParse((result as dynamic).largo ?? '') ?? 0.0;
      final altura = double.tryParse((result as dynamic).altura ?? '') ?? 0.0;
      return largo * altura;
    }
  } else if (result is LosaAligerada) {
    if (result.area != null && result.area!.isNotEmpty) {
      return double.tryParse(result.area!) ?? 0.0;
    } else {
      final largo = double.tryParse(result.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
      return largo * ancho;
    }
  } else if (result is Tarrajeo) {
    if (result.area != null && result.area!.isNotEmpty) {
      return double.tryParse(result.area!) ?? 0.0;
    } else {
      final longitud = double.tryParse(result.longitud ?? '') ?? 0.0;
      final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
      return longitud * ancho;
    }
  }
  return 0.0;
}

double _calculateResultVolume(dynamic result) {
  if (result is Piso) {
    final espesor = double.tryParse(result.espesor) ?? 0.0;
    if (result.area != null && result.area!.isNotEmpty) {
      final area = double.tryParse(result.area!) ?? 0.0;
      return area * (espesor / 100); // Convert cm to m
    } else {
      final largo = double.tryParse(result.largo ?? '') ?? 0.0;
      final ancho = double.tryParse(result.ancho ?? '') ?? 0.0;
      return largo * ancho * (espesor / 100); // Convert cm to m
    }
  } else if (result is Columna || result is Viga) {
    if ((result as dynamic).volumen != null && (result as dynamic).volumen!.isNotEmpty) {
      return double.tryParse((result as dynamic).volumen!) ?? 0.0;
    } else {
      final largo = double.tryParse((result as dynamic).largo ?? '') ?? 0.0;
      final ancho = double.tryParse((result as dynamic).ancho ?? '') ?? 0.0;
      final altura = double.tryParse((result as dynamic).altura ?? '') ?? 0.0;
      return largo * ancho * altura;
    }
  }
  return 0.0;
}

class Material {
  final String description;
  final String unit;
  final String quantity;

  Material({
    required this.description,
    required this.unit,
    required this.quantity,
  });
}

class MaterialsCalculator {
  final List<dynamic> results;

  MaterialsCalculator(this.results);

  List<Material> calculateMaterials() {
    if (results.isEmpty) return [];

    final firstResult = results.first;

    if (firstResult is Ladrillo) {
      return _calculateLadrilloMaterials();
    } else if (firstResult is Bloqueta) {
      return _calculateBloquetaMaterials();
    } else if (firstResult is Piso) {
      return _calculatePisoMaterials();
    } else if (firstResult is LosaAligerada) {
      return _calculateLosaAligeradaMaterials();
    } else if (firstResult is Tarrajeo) {
      return _calculateTarrajeoMaterials();
    } else if (firstResult is Columna || firstResult is Viga) {
      return _calculateStructuralMaterials();
    }

    return [];
  }

  List<Material> _calculateLadrilloMaterials() {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalLadrillos = 0.0;
    double totalAgua = 0.0;

    for (var result in results) {
      if (result is Ladrillo) {
        // Area calculation
        double area;
        if (result.area != null && result.area!.isNotEmpty) {
          area = double.tryParse(result.area!) ?? 0.0;
        } else {
          final largo = double.tryParse(result.largo ?? '') ?? 0.0;
          final altura = double.tryParse(result.altura ?? '') ?? 0.0;
          area = largo * altura;
        }

        // Material factors based on asentado type
        double factorLadrillos;
        switch (result.tipoAsentado) {
          case 'soga':
            factorLadrillos = 40; // Aproximadamente 40 ladrillos por m²
            break;
          case 'cabeza':
            factorLadrillos = 65; // Aproximadamente 65 ladrillos por m²
            break;
          case 'canto':
            factorLadrillos = 32; // Aproximadamente 32 ladrillos por m²
            break;
          default:
            factorLadrillos = 40;
        }

        // Apply desperdicio factor
        double factorDesperdicio = (double.tryParse(result.factorDesperdicio) ?? 5.0) / 100.0 + 1.0;

        // Proportion factor for mortero
        double factorCemento;
        double factorArena;

        switch (result.proporcionMortero) {
          case '4': // 1:4
            factorCemento = 0.018; // 0.018 bolsas por m²
            factorArena = 0.028; // 0.028 m³ por m²
            break;
          case '5': // 1:5
            factorCemento = 0.015; // 0.015 bolsas por m²
            factorArena = 0.025; // 0.025 m³ por m²
            break;
          default: // Default 1:5
            factorCemento = 0.015;
            factorArena = 0.025;
        }

        // Calculate materials
        totalLadrillos += area * factorLadrillos * factorDesperdicio;
        totalCemento += area * factorCemento * factorDesperdicio;
        totalArena += area * factorArena * factorDesperdicio;
        totalAgua += area * 0.007 * factorDesperdicio; // Approximate water factor
      }
    }

    return [
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Ladrillo',
        unit: 'und',
        quantity: totalLadrillos.ceil().toString(),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: totalAgua.toStringAsFixed(2),
      ),
    ];
  }

  List<Material> _calculateBloquetaMaterials() {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalBloquetas = 0.0;

    for (var bloqueta in results as List<Bloqueta>) {
      // Area calculation
      double area;
      if (bloqueta.area != null && bloqueta.area!.isNotEmpty) {
        area = double.tryParse(bloqueta.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(bloqueta.largo ?? '') ?? 0.0;
        final altura = double.tryParse(bloqueta.altura ?? '') ?? 0.0;
        area = largo * altura;
      }

      // Factors based on bloqueta type
      double factorBloquetas;
      double factorCemento;
      double factorArena;

      switch (bloqueta.tipoBloqueta) {
        case 'P7':
          factorBloquetas = 12.5;
          factorCemento = 0.12;
          factorArena = 0.018;
          break;
        case 'P10':
          factorBloquetas = 12.5;
          factorCemento = 0.15;
          factorArena = 0.022;
          break;
        case 'P12':
          factorBloquetas = 12.5;
          factorCemento = 0.18;
          factorArena = 0.025;
          break;
        default:
          factorBloquetas = 12.5;
          factorCemento = 0.15;
          factorArena = 0.022;
      }

      // Apply desperdicio factor
      double factorDesperdicio = (double.tryParse(bloqueta.factorDesperdicio) ?? 5.0) / 100.0 + 1.0;

      // Calculate materials
      totalBloquetas += area * factorBloquetas * factorDesperdicio;
      totalCemento += area * factorCemento * factorDesperdicio;
      totalArena += area * factorArena * factorDesperdicio;
    }

    return [
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Bloqueta',
        unit: 'und',
        quantity: totalBloquetas.ceil().toString(),
      ),
    ];
  }

  List<Material> _calculatePisoMaterials() {
    final firstPiso = results.first as Piso;
    bool isContrapiso = firstPiso.tipo == 'contrapiso';

    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalPiedra = 0.0;
    double totalAgua = 0.0;

    for (var piso in results as List<Piso>) {
      // Calculate volume
      double espesor = double.tryParse(piso.espesor) ?? 0.0;
      espesor = espesor / 100; // Convert cm to m

      double area;
      if (piso.area != null && piso.area!.isNotEmpty) {
        area = double.tryParse(piso.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(piso.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(piso.ancho ?? '') ?? 0.0;
        area = largo * ancho;
      }

      double volumen = area * espesor;

      // Apply desperdicio factor
      double factorDesperdicio = (double.tryParse(piso.factorDesperdicio) ?? 5.0) / 100.0 + 1.0;

      // Calculate materials based on piso type
      if (isContrapiso) {
        // Contrapiso uses mortero
        String proporcion = piso.proporcionMortero ?? '5';
        proporcion = proporcion.replaceAll("1 : ", "");
        int propValue = int.tryParse(proporcion) ?? 5;

        double factorCemento;
        double factorArena;

        switch (propValue) {
          case 4: // 1:4
            factorCemento = 8.0; // bolsas por m³
            factorArena = 1.05; // m³ por m³
            break;
          case 5: // 1:5
            factorCemento = 7.0; // bolsas por m³
            factorArena = 1.15; // m³ por m³
            break;
          case 6: // 1:6
            factorCemento = 6.0; // bolsas por m³
            factorArena = 1.20; // m³ por m³
            break;
          default: // Default 1:5
            factorCemento = 7.0;
            factorArena = 1.15;
        }

        totalCemento += volumen * factorCemento * factorDesperdicio;
        totalArena += volumen * factorArena * factorDesperdicio;
        totalAgua += volumen * 0.20 * factorDesperdicio; // Aproximado 0.20 m³ por m³
      } else {
        // Falso piso uses concreto
        String resistencia = piso.resistencia ?? 'fc140';
        resistencia = resistencia.replaceAll(" kg/cm²", "");

        double factorCemento;
        double factorArena;
        double factorPiedra;

        switch (resistencia) {
          case 'fc175':
            factorCemento = 8.0; // bolsas por m³
            factorArena = 0.50; // m³ por m³
            factorPiedra = 0.80; // m³ por m³
            break;
          case 'fc210':
            factorCemento = 9.0; // bolsas por m³
            factorArena = 0.45; // m³ por m³
            factorPiedra = 0.75; // m³ por m³
            break;
          default: // Default fc140
            factorCemento = 7.0; // bolsas por m³
            factorArena = 0.55; // m³ por m³
            factorPiedra = 0.85; // m³ por m³
        }

        totalCemento += volumen * factorCemento * factorDesperdicio;
        totalArena += volumen * factorArena * factorDesperdicio;
        totalPiedra += volumen * factorPiedra * factorDesperdicio;
        totalAgua += volumen * 0.18 * factorDesperdicio; // Aproximado 0.18 m³ por m³
      }
    }

    List<Material> materials = [
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: totalAgua.toStringAsFixed(2),
      ),
    ];

    // Only add piedra for falso piso
    if (!isContrapiso && totalPiedra > 0) {
      materials.add(
        Material(
          description: 'Piedra chancada',
          unit: 'm³',
          quantity: totalPiedra.toStringAsFixed(2),
        ),
      );
    }

    return materials;
  }

  List<Material> _calculateLosaAligeradaMaterials() {
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalPiedra = 0.0;
    double totalAgua = 0.0;
    double totalLadrillos = 0.0;
    double totalAcero = 0.0;
    double totalMadera = 0.0;
    double totalAlambre8 = 0.0;
    double totalAlambre16 = 0.0;
    double totalClavos = 0.0;

    for (var losa in results as List<LosaAligerada>) {
      // Calculate area
      double area;
      if (losa.area != null && losa.area!.isNotEmpty) {
        area = double.tryParse(losa.area!) ?? 0.0;
      } else {
        final largo = double.tryParse(losa.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(losa.ancho ?? '') ?? 0.0;
        area = largo * ancho;
      }

      // Get height in cm and convert to m
      double altura = double.tryParse(losa.altura.replaceAll(" cm", "")) ?? 17.0;
      altura = altura / 100;

      // Calculate volume of concrete (approximately 40% of total volume due to bricks)
      double volumen = area * altura * 0.40;

      // Apply desperdicio factors
      double factorDesperdicioLadrillo = (double.tryParse(losa.desperdicioLadrillo) ?? 5.0) / 100.0 + 1.0;
      double factorDesperdicioConcreto = (double.tryParse(losa.desperdicioConcreto) ?? 5.0) / 100.0 + 1.0;

      // Material factors based on slab height
      double factorLadrillos;
      double factorAcero;
      double factorMadera;

      switch (losa.altura) {
        case "20 cm":
          factorLadrillos = 8.5; // Unidades por m²
          factorAcero = 4.5; // kg por m²
          factorMadera = 1.8; // p² por m²
          break;
        case "25 cm":
          factorLadrillos = 8.0; // Unidades por m²
          factorAcero = 5.0; // kg por m²
          factorMadera = 2.0; // p² por m²
          break;
        default: // "17 cm"
          factorLadrillos = 9.0; // Unidades por m²
          factorAcero = 4.0; // kg por m²
          factorMadera = 1.6; // p² por m²
      }

      // Concrete factors based on resistance
      String resistencia = losa.resistenciaConcreto.replaceAll(" kg/cm²", "");
      double factorCemento;
      double factorArena;
      double factorPiedra;

      switch (resistencia) {
        case "175":
          factorCemento = 8.0; // bolsas por m³
          factorArena = 0.50; // m³ por m³
          factorPiedra = 0.80; // m³ por m³
          break;
        case "210":
          factorCemento = 9.0; // bolsas por m³
          factorArena = 0.45; // m³ por m³
          factorPiedra = 0.75; // m³ por m³
          break;
        case "245":
          factorCemento = 10.0; // bolsas por m³
          factorArena = 0.40; // m³ por m³
          factorPiedra = 0.70; // m³ por m³
          break;
        case "280":
          factorCemento = 11.0; // bolsas por m³
          factorArena = 0.35; // m³ por m³
          factorPiedra = 0.65; // m³ por m³
          break;
        default: // "140"
          factorCemento = 7.0; // bolsas por m³
          factorArena = 0.55; // m³ por m³
          factorPiedra = 0.85; // m³ por m³
      }

      // Calculate material quantities
      totalCemento += volumen * factorCemento * factorDesperdicioConcreto;
      totalArena += volumen * factorArena * factorDesperdicioConcreto;
      totalPiedra += volumen * factorPiedra * factorDesperdicioConcreto;
      totalAgua += volumen * 0.18 * factorDesperdicioConcreto; // Approximate water factor
      totalLadrillos += area * factorLadrillos * factorDesperdicioLadrillo;
      totalAcero += area * factorAcero;
      totalMadera += area * factorMadera;
      totalAlambre8 += area * 0.10; // Approximate 0.10 kg per m²
      totalAlambre16 += area * 0.25; // Approximate 0.25 kg per m²
      totalClavos += area * 0.15; // Approximate 0.15 kg per m²
    }

    return [
      Material(
        description: 'Ladrillo',
        unit: 'und',
        quantity: totalLadrillos.ceil().toString(),
      ),
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Piedra chancada',
        unit: 'm³',
        quantity: totalPiedra.toStringAsFixed(2),
      ),
      Material(
        description: 'Agua',
        unit: 'L',
        quantity: (totalAgua * 1000).toStringAsFixed(0), // Convert to liters
      ),
      Material(
        description: 'Acero',
        unit: 'kg',
        quantity: totalAcero.toStringAsFixed(2),
      ),
      Material(
        description: 'Madera',
        unit: 'p²',
        quantity: totalMadera.toStringAsFixed(2),
      ),
      Material(
        description: 'Alambre #8',
        unit: 'kg',
        quantity: totalAlambre8.toStringAsFixed(2),
      ),
      Material(
        description: 'Alambre #16',
        unit: 'kg',
        quantity: totalAlambre16.toStringAsFixed(2),
      ),
      Material(
        description: 'Clavos',
        unit: 'kg',
        quantity: totalClavos.toStringAsFixed(2),
      ),
    ];
  }

  List<Material> _calculateTarrajeoMaterials() {
    double totalCemento = 0.0;
    double totalArenaFina = 0.0;
    double totalAgua = 0.0;

    for (var tarrajeo in results as List<Tarrajeo>) {
      // Calculate area
      double area;
      if (tarrajeo.area != null && tarrajeo.area!.isNotEmpty) {
        area = double.tryParse(tarrajeo.area!) ?? 0.0;
      } else {
        final longitud = double.tryParse(tarrajeo.longitud ?? '') ?? 0.0;
        final ancho = double.tryParse(tarrajeo.ancho ?? '') ?? 0.0;
        area = longitud * ancho;
      }

      // Get thickness in cm and convert to m
      double espesor = double.tryParse(tarrajeo.espesor) ?? 1.5;
      espesor = espesor / 100; // Convert cm to m

      // Calculate volume
      double volumen = area * espesor;

      // Apply desperdicio factor
      double factorDesperdicio = (double.tryParse(tarrajeo.factorDesperdicio) ?? 5.0) / 100.0 + 1.0;

      // Mortero factors based on proportion
      String proporcion = tarrajeo.proporcionMortero;
      double factorCemento;
      double factorArenaFina;

      switch (proporcion) {
        case "3":
          factorCemento = 9.0; // bolsas por m³
          factorArenaFina = 1.02; // m³ por m³
          break;
        case "4":
          factorCemento = 7.5; // bolsas por m³
          factorArenaFina = 1.07; // m³ por m³
          break;
        case "6":
          factorCemento = 5.5; // bolsas por m³
          factorArenaFina = 1.15; // m³ por m³
          break;
        default: // "5"
          factorCemento = 6.5; // bolsas por m³
          factorArenaFina = 1.10; // m³ por m³
      }

      // Calculate material quantities
      totalCemento += volumen * factorCemento * factorDesperdicio;
      totalArenaFina += volumen * factorArenaFina * factorDesperdicio;
      totalAgua += volumen * 0.23 * factorDesperdicio; // Approximate water factor
    }

    return [
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena fina',
        unit: 'm³',
        quantity: totalArenaFina.toStringAsFixed(2),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: totalAgua.toStringAsFixed(2),
      ),
    ];
  }

  List<Material> _calculateStructuralMaterials() {
    bool isColumn = results.first is Columna;
    double totalCemento = 0.0;
    double totalArena = 0.0;
    double totalPiedra = 0.0;
    double totalAgua = 0.0;
    double totalAcero = 0.0;
    double totalAlambre16 = 0.0;
    double totalMadera = 0.0;
    double totalClavos = 0.0;

    for (var element in results) {
      // Calculate volume
      var structural = element as dynamic; // Either Columna or Viga
      double volumen;

      if (structural.volumen != null && structural.volumen!.isNotEmpty) {
        volumen = double.tryParse(structural.volumen!) ?? 0.0;
      } else {
        final largo = double.tryParse(structural.largo ?? '') ?? 0.0;
        final ancho = double.tryParse(structural.ancho ?? '') ?? 0.0;
        final altura = double.tryParse(structural.altura ?? '') ?? 0.0;
        volumen = largo * ancho * altura;
      }

      // Apply desperdicio factor
      double factorDesperdicio = (double.tryParse(structural.factorDesperdicio) ?? 5.0) / 100.0 + 1.0;

      // Resistance determination
      String resistencia = structural.resistencia;
      double factorCemento;
      double factorArena;
      double factorPiedra;
      double factorAcero;
      double factorMadera;

      // Set material factors based on resistance
      switch (resistencia) {
        case "175 kg/cm²":
          factorCemento = 8.0; // bolsas por m³
          factorArena = 0.50; // m³ por m³
          factorPiedra = 0.80; // m³ por m³
          factorAcero = isColumn ? 120.0 : 100.0; // kg por m³
          factorMadera = 12.0; // p² por m³
          break;
        case "210 kg/cm²":
          factorCemento = 9.0; // bolsas por m³
          factorArena = 0.45; // m³ por m³
          factorPiedra = 0.75; // m³ por m³
          factorAcero = isColumn ? 130.0 : 110.0; // kg por m³
          factorMadera = 12.0; // p² por m³
          break;
        case "280 kg/cm²":
          factorCemento = 11.0; // bolsas por m³
          factorArena = 0.35; // m³ por m³
          factorPiedra = 0.65; // m³ por m³
          factorAcero = isColumn ? 140.0 : 120.0; // kg por m³
          factorMadera = 13.0; // p² por m³
          break;
        default: // "140 kg/cm²"
          factorCemento = 7.0; // bolsas por m³
          factorArena = 0.55; // m³ por m³
          factorPiedra = 0.85; // m³ por m³
          factorAcero = isColumn ? 110.0 : 90.0; // kg por m³
          factorMadera = 11.0; // p² por m³
      }

      // Calculate material quantities
      totalCemento += volumen * factorCemento * factorDesperdicio;
      totalArena += volumen * factorArena * factorDesperdicio;
      totalPiedra += volumen * factorPiedra * factorDesperdicio;
      totalAgua += volumen * 0.18 * factorDesperdicio; // Approximate water factor
      totalAcero += volumen * factorAcero;
      totalAlambre16 += volumen * factorAcero * 0.03; // Approximate 3% of steel
      totalMadera += volumen * factorMadera;
      totalClavos += volumen * factorMadera * 0.05; // Approximate 5% of wood area
    }

    String elementType = isColumn ? 'Columna' : 'Viga';

    return [
      Material(
        description: 'Cemento',
        unit: 'bls',
        quantity: totalCemento.ceil().toString(),
      ),
      Material(
        description: 'Arena gruesa',
        unit: 'm³',
        quantity: totalArena.toStringAsFixed(2),
      ),
      Material(
        description: 'Piedra chancada',
        unit: 'm³',
        quantity: totalPiedra.toStringAsFixed(2),
      ),
      Material(
        description: 'Agua',
        unit: 'm³',
        quantity: totalAgua.toStringAsFixed(2),
      ),
      Material(
        description: 'Acero',
        unit: 'kg',
        quantity: totalAcero.toStringAsFixed(2),
      ),
      Material(
        description: 'Alambre #16',
        unit: 'kg',
        quantity: totalAlambre16.toStringAsFixed(2),
      ),
      Material(
        description: 'Madera',
        unit: 'p²',
        quantity: totalMadera.toStringAsFixed(2),
      ),
      Material(
        description: 'Clavos',
        unit: 'kg',
        quantity: totalClavos.toStringAsFixed(2),
      ),
    ];
  }
}