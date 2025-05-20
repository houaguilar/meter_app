import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/entities.dart';
import '../cards/measurement_item_card.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Nuevo diálogo de mediciones con animación mejorada
class MeasurementItemsBottomSheet extends StatelessWidget {
  final List<Measurement> items;

  const MeasurementItemsBottomSheet({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador de arrastre
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text(
                      'Todas las mediciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MeasurementItemCard(
                      title: item.title,
                      description: item.description,
                      imageAsset: item.imageAsset,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(item.location);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Función auxiliar para mostrar el bottom sheet con animación mejorada
void showMeasurementsSheet(BuildContext context, List<Measurement> items) {
  showCupertinoModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    expand: false,
    enableDrag: true,
    topRadius: const Radius.circular(16),
    duration: const Duration(milliseconds: 400),
    builder: (context) => MeasurementItemsBottomSheet(items: items),
  );
}
