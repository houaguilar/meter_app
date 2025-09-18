// Widget para gestionar distribuciones de estribos dinámicamente
import 'package:flutter/material.dart';

import '../../../../../config/theme/theme.dart';
import '../viga/datos/models/beam_form_data.dart';
import '../viga/datos/models/stirrup_distribution_data.dart';

class DynamicStirrupDistributionsWidget extends StatefulWidget {
  final List<StirrupDistributionData> stirrupDistributions;
  final VoidCallback onChanged;

  const DynamicStirrupDistributionsWidget({
    super.key,
    required this.stirrupDistributions,
    required this.onChanged,
  });

  @override
  State<DynamicStirrupDistributionsWidget> createState() => _DynamicStirrupDistributionsWidgetState();
}

class _DynamicStirrupDistributionsWidgetState extends State<DynamicStirrupDistributionsWidget> {
  void _addDistribution() {
    setState(() {
      widget.stirrupDistributions.add(StirrupDistributionData(quantity: 1, separation: 0.10));
    });
    widget.onChanged();
  }

  void _removeDistribution(int index) {
    if (widget.stirrupDistributions.length > 1) {
      setState(() {
        widget.stirrupDistributions.removeAt(index);
      });
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Estribos',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Lista de distribuciones
        ...widget.stirrupDistributions.asMap().entries.map((entry) {
          final index = entry.key;
          final distribution = entry.value;
          return _buildDistributionRow(distribution, index);
        }),

        const SizedBox(height: 12),

        // Botón para agregar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addDistribution,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar Distribución'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.secondary,
              side: const BorderSide(color: AppColors.secondary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionRow(StirrupDistributionData distribution, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          // Cantidad
          Expanded(
            child: TextFormField(
              initialValue: distribution.quantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  widget.stirrupDistributions[index] = distribution.copyWith(
                    quantity: int.tryParse(value) ?? 1,
                  );
                });
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Separación
          Expanded(
            child: TextFormField(
              initialValue: distribution.separation.toString(),
              decoration: const InputDecoration(
                labelText: 'Separación (m)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  widget.stirrupDistributions[index] = distribution.copyWith(
                    separation: double.tryParse(value) ?? 0.10,
                  );
                });
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Botón eliminar
          IconButton(
            onPressed: widget.stirrupDistributions.length > 1 ? () => _removeDistribution(index) : null,
            icon: Icon(
              Icons.delete,
              color: widget.stirrupDistributions.length > 1 ? Colors.red : Colors.grey,
              size: 20,
            ),
            tooltip: 'Eliminar distribución',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}