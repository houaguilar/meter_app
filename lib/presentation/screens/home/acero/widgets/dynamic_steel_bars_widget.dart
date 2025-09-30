// Widget para gestionar barras de acero dinámicamente
import 'package:flutter/material.dart';

import '../../../../../config/theme/theme.dart';
import '../../../../../domain/entities/home/acero/steel_beam_constants.dart';
import '../viga/datos/models/beam_form_data.dart';
import '../viga/datos/models/steel_bar_data.dart';

class DynamicSteelBarsWidget extends StatefulWidget {
  final List<SteelBarData> steelBars;
  final VoidCallback onChanged;

  const DynamicSteelBarsWidget({
    super.key,
    required this.steelBars,
    required this.onChanged,
  });

  @override
  State<DynamicSteelBarsWidget> createState() => _DynamicSteelBarsWidgetState();
}

class _DynamicSteelBarsWidgetState extends State<DynamicSteelBarsWidget> {
  void _addSteelBar() {
    setState(() {
      widget.steelBars.add(SteelBarData(quantity: 1, diameter: '1/2"'));
    });
    widget.onChanged();
  }

  void _removeSteelBar(int index) {
    if (widget.steelBars.length > 1) {
      setState(() {
        widget.steelBars.removeAt(index);
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
          'Barras de Acero Longitudinal',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Lista de barras
        ...widget.steelBars.asMap().entries.map((entry) {
          final index = entry.key;
          final bar = entry.value;
          return _buildSteelBarRow(bar, index);
        }),

        const SizedBox(height: 12),

        // Botón para agregar
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addSteelBar,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Agregar Barra'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSteelBarRow(SteelBarData bar, int index) {
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
            flex: 2,
            child: TextFormField(
              initialValue: bar.quantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  widget.steelBars[index] = bar.copyWith(
                    quantity: int.tryParse(value) ?? 1,
                  );
                });
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Diámetro
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: bar.diameter,
              decoration: const InputDecoration(
                labelText: 'Diámetro',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
              items: SteelBeamConstants.availableDiameters.map((diameter) {
                return DropdownMenuItem(
                  value: diameter,
                  child: Text(diameter),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  widget.steelBars[index] = bar.copyWith(diameter: value!);
                });
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 12),

          // Botón eliminar
          IconButton(
            onPressed: widget.steelBars.length > 1 ? () => _removeSteelBar(index) : null,
            icon: Icon(
              Icons.delete,
              color: widget.steelBars.length > 1 ? Colors.red : Colors.grey,
              size: 20,
            ),
            tooltip: 'Eliminar barra',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }
}