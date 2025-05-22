import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/home/piso/floor.dart';
import 'package:meter_app/presentation/providers/home/piso/floor_providers.dart';
import 'package:meter_app/presentation/widgets/cards/floor_card.dart';

import '../../../../config/theme/theme.dart';
import '../../../providers/providers.dart';
import '../../../widgets/widgets.dart';

class PisosScreen extends StatelessWidget {
  const PisosScreen({super.key});
  static const String route = 'pisos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(titleAppBar: "Pisos",),
      body: const _PisosView(),
    );
  }
}

class _PisosView extends ConsumerWidget {
  const _PisosView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floorsAsync = ref.watch(floorsProvider);
    final selectedMaterial = ref.watch(selectedFloorProvider);
    ref.watch(tipoPisoProvider);

    return Scaffold(
      body: floorsAsync.when(
        data: (coatings) => _buildCoatingGrid(context, ref, coatings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCoatingGrid(BuildContext context, WidgetRef ref, List<Floor> floors) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tipo de revestimiento',
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
            itemCount: floors.length,
            itemBuilder: (context, index) {
              final floor = floors[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedFloorProvider.notifier).state = floor;
                },
                child: FloorCard(
                  floor: floor,
                  onTap: () {
                    if (floor.id == '1') {
                      ref.read(tipoPisoProvider.notifier).selectPiso('falso');
                      context.pushNamed('falso-piso');
                    } else {
                      ref.read(tipoPisoProvider.notifier).selectPiso('contrapiso');
                      context.pushNamed('contrapiso');
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

