// lib/presentation/screens/projects/result/components/result_screen_components.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/src/consumer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/services/shared/UnifiedMaterialsCalculator.dart';
import '../../../../../presentation/assets/icons.dart';
import '../../../../widgets/widgets.dart';
import '../../../home/estructuras/result/result_structural_elements_screen.dart' as PdfGenerationService;
import '../services/share_service.dart';


/// Widget para mostrar el estado de carga
class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = 'Cargando resultados guardados...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar errores
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar los resultados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
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

/// Widget para mostrar mensaje de resultados vacíos
class EmptyResultsMessage extends StatelessWidget {
  const EmptyResultsMessage({super.key});

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
                AppColors.accent,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No hay resultados disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Este metrado no tiene cálculos guardados todavía.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header que muestra el tipo de resultado
class ResultTypeHeader extends StatelessWidget {
  final CalculationType type;

  const ResultTypeHeader({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor();

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
            type.displayName,
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

  Color _getTypeColor() {
    switch (type) {
      case CalculationType.ladrillo:
        return Colors.brown;
      case CalculationType.piso:
        return Colors.teal;
      case CalculationType.losaAligerada:
        return Colors.deepPurple;
      case CalculationType.tarrajeo:
        return Colors.amber.shade700;
      case CalculationType.columna:
      case CalculationType.viga:
        return Colors.blue.shade800;
    }
  }

  IconData _getTypeIcon() {
    switch (type) {
      case CalculationType.ladrillo:
        return Icons.grid_view;
      case CalculationType.piso:
        return Icons.grid_on;
      case CalculationType.losaAligerada:
        return Icons.layers;
      case CalculationType.tarrajeo:
        return Icons.brush;
      case CalculationType.columna:
        return Icons.view_column;
      case CalculationType.viga:
        return Icons.horizontal_rule;
    }
  }
}

/// Card que muestra los datos del metrado
class MetradoDetailsCard extends StatelessWidget {
  final CalculationResult result;

  const MetradoDetailsCard({
    super.key,
    required this.result,
  });

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
              color: AppColors.accent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text(
                  'Datos del Metrado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${result.measurements.length} item${result.measurements.length != 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMeasurementsTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsTable() {
    if (result.measurements.isEmpty) {
      return const Center(
        child: Text('No hay datos de medición disponibles'),
      );
    }

    return Column(
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(3),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            _buildTableHeader(['Descripción', 'Und.', result.totalUnit]),
            ...result.measurements.map((measurement) {
              return _buildTableRow([
                measurement.description,
                measurement.unit,
                measurement.value.toStringAsFixed(2),
              ]);
            }),
            _buildTotalRow(
              label: 'Total',
              unit: result.totalUnit,
              value: result.totalValue.toStringAsFixed(2),
            ),
          ],
        ),
        if (result.additionalInfo.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAdditionalInfo(),
        ],
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              const Text(
                'Información adicional:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...result.additionalInfo.entries.map((entry) {
            return Text(
              '• ${_formatInfoKey(entry.key)}: ${entry.value}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatInfoKey(String key) {
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
        return key;
    }
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}

/// Card que muestra la lista de materiales
class MaterialsListCard extends StatelessWidget {
  final CalculationResult result;

  const MaterialsListCard({
    super.key,
    required this.result,
  });

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
              color: AppColors.accent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Lista de Materiales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
    if (result.materials.isEmpty) {
      return const Center(
        child: Text('No hay materiales disponibles'),
      );
    }

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(['Material', 'Und.', 'Cantidad']),
        ...result.materials.map((material) {
          return _buildTableRow([
            material.description,
            material.unit,
            material.quantity,
          ]);
        }),
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

/// Botones de acción (compartir, PDF, etc.)
class ActionButtons extends StatelessWidget {
  final CalculationResult result;
  final String metradoId;

  const ActionButtons({
    super.key,
    required this.result,
    required this.metradoId,
  });

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
                  color: AppColors.secondary,
                  onPressed: () => _previewPdf(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionButton(
                  context,
                  title: 'Compartir',
                  icon: Icons.share,
                  color: AppColors.primary,
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
            onPressed: () => _navigateToProviders(context),
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
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _previewPdf(BuildContext context) async {
    try {
      final pdfFile = await PdfGenerationService.generatePdf(result as WidgetRef);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewPage(pdfFile: pdfFile),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error al generar PDF: $e');
      }
    }
  }

  Future<void> _showShareOptions(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return OptionsDialog(
          options: [
            DialogOption(
              icon: Icons.picture_as_pdf,
              text: 'Compartir PDF',
              onTap: () async {
                Navigator.of(context).pop();
                await _sharePdf(context);
              },
            ),
            DialogOption(
              icon: Icons.text_format,
              text: 'Compartir Texto',
              onTap: () async {
                Navigator.of(context).pop();
                await _shareText(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sharePdf(BuildContext context) async {
    try {
      final pdfFile = await PdfGenerationService.generatePdf(result as WidgetRef);
      await ShareService.sharePdf(pdfFile);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error al compartir PDF: $e');
      }
    }
  }

  Future<void> _shareText(BuildContext context) async {
    try {
      final text = ShareService.generateShareText(result);
      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error al compartir texto: $e');
      }
    }
  }

  void _navigateToProviders(BuildContext context) {
    // Implementar navegación a proveedores
    // context.pushNamed('map-screen-projects');
    _showError(context, 'Funcionalidad de proveedores próximamente');
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Página de vista previa del PDF
class PdfPreviewPage extends StatelessWidget {
  final dynamic pdfFile; // File

  const PdfPreviewPage({super.key, required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista previa PDF'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              try {
                await ShareService.sharePdf(pdfFile);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al compartir: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Vista previa del PDF',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}