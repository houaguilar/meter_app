import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meter_app/domain/entities/home/tarrajeo/coating.dart';
import 'package:meter_app/presentation/providers/home/tarrajeo/coating_providers.dart';
import 'package:meter_app/presentation/widgets/cards/coating_card.dart';
import 'package:meter_app/presentation/widgets/widgets.dart';

import '../../../../config/theme/theme.dart';


class TarrajeoScreen extends ConsumerWidget {
  const TarrajeoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coatingsAsync = ref.watch(coatingsProvider);
    final selectedMaterial = ref.watch(selectedCoatingProvider);

    return Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Tarrajeo',),
      body: coatingsAsync.when(
        data: (coatings) => _buildCoatingGrid(context, ref, coatings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCoatingGrid(BuildContext context, WidgetRef ref, List<Coating> coatings) {
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
            itemCount: coatings.length,
            itemBuilder: (context, index) {
              final coating = coatings[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedCoatingProvider.notifier).state = coating;
                },
                child: CoatingCard(
                  coating: coating,
                  onTap: () {
                    if (coating.id == '1') {
                      context.pushNamed('tarrajeo-muro');
                    } else {
    //                  context.pushNamed('tarrajeo-cielorraso');
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
