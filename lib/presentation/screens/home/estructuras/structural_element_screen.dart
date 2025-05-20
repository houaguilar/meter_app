import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/constants.dart';
import 'package:meter_app/presentation/widgets/widgets.dart';

import '../../../../domain/entities/home/estructuras/structural_element.dart';
import '../../../providers/home/estructuras/structural_element_providers.dart';
import '../../../widgets/cards/structural_element_card.dart';

class StructuralElementScreen extends ConsumerWidget {
  const StructuralElementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elementsAsync = ref.watch(structuralElementsProvider);
    final selectedElement = ref.watch(selectedStructuralElementProvider);
    ref.watch(tipoStructuralElementProvider);

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Elementos Estructurales'),
      body: _buildElementGrid(context, ref, elementsAsync), // Usa la lista directamente
    );
  }

  Widget _buildElementGrid(BuildContext context, WidgetRef ref, List<StructuralElement> elements) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tipo de elemento estructural',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryMetraShop,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.7),
            itemCount: elements.length,
            itemBuilder: (context, index) {
              final element = elements[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedStructuralElementProvider.notifier).state = element;
                },
                child: StructuralElementCard(
                  element: element,
                  onTap: () {
                    if (element.id == '1') {
                      ref.read(tipoStructuralElementProvider.notifier).selectStructuralElement('columna');
                      context.pushNamed('structural-element-datos');
                    } else if (element.id == '2') {
                      ref.read(tipoStructuralElementProvider.notifier).selectStructuralElement('viga');
                      context.pushNamed('structural-element-datos');
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}