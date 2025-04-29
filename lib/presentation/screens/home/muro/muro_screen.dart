
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/config/constants/colors.dart';
import 'package:meter_app/domain/entities/home/muro/wall_material.dart';
import 'package:meter_app/presentation/widgets/cards/wall_material_card.dart';

import '../../../providers/home/muro/wall_material_providers.dart';
import '../../../providers/providers.dart';
import '../../../widgets/widgets.dart';

class MuroScreen extends ConsumerWidget {
  const MuroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(wallMaterialsProvider);
    final selectedMaterial = ref.watch(selectedMaterialProvider);
    ref.watch(tipoLadrilloProvider);
    ref.watch(tipoBloquetaProvider);

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Muro',),
      body: materialsAsync.when(
        data: (materials) => _buildMaterialGrid(context, ref, materials),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMaterialGrid(BuildContext context, WidgetRef ref, List<WallMaterial> materials) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
              'Tipo de material',
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
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final material = materials[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedMaterialProvider.notifier).state = material;
                },
                child: WallMaterialCard(
                  material: material,
                  onTap: () {
                    switch (material.id) {
                      case '1':
                        ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Pandereta1');
                        context.pushNamed('ladrillo1');
                      case '2':
                        ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Pandereta2');
                        context.pushNamed('ladrillo1');
                      case '3':
                        ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Kingkong1');
                        context.pushNamed('ladrillo1');
                      case '4':
                        ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Kingkong2');
                        context.pushNamed('ladrillo1');
                      case '5':
                        ref.read(tipoLadrilloProvider.notifier).selectLadrillo('Tabicon');
           //             context.pushNamed('ladrillo1');
                      case '6':
                        ref.read(tipoBloquetaProvider.notifier).selectBloqueta('P14');
            //            context.pushNamed('bloqueta1');
                      case '7':
                        ref.read(tipoBloquetaProvider.notifier).selectBloqueta('P10');
           //             context.pushNamed('bloqueta1');
                      case '8':
                        ref.read(tipoBloquetaProvider.notifier).selectBloqueta('P7');
           //             context.pushNamed('bloqueta1');
                      default:
                          print(' invalid entry');
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


