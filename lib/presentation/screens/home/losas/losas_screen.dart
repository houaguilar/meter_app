import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/home/losas/slab.dart';
import 'package:meter_app/presentation/providers/home/losa/slab_providers.dart';
import 'package:meter_app/presentation/widgets/cards/slab_card.dart';

import '../../../../config/theme/theme.dart';
import '../../../widgets/widgets.dart';

class LosasScreen extends StatelessWidget {
  const LosasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Losas',),
      body: const _LosasView(),
    );
  }
}

class _LosasView extends ConsumerWidget {
  const _LosasView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slabsAsync = ref.watch(slabProvider);

    return Scaffold(
      body: slabsAsync.when(
        data: (slabs) => _buildSlabGrid(context, ref, slabs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSlabGrid(BuildContext context, WidgetRef ref, List<Slab> slabs) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Tipo de Losa',
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
            itemCount: slabs.length,
            itemBuilder: (context, index) {
              final slab = slabs[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedSlabProvider.notifier).state = slab;
                },
                child: SlabCard(
                  slab: slab,
                  onTap: () {
                    if (slab.id == '1') {
                      context.pushNamed('losas-aligeradas');
                    } else {
                      context.pushNamed('losas-aligeradas');
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
