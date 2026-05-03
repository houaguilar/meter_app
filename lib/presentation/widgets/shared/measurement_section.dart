import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:meter_app/domain/entities/entities.dart';
import 'package:meter_app/presentation/widgets/cards/measurement_item_card.dart';

class MeasurementSection extends StatelessWidget {
  final List<Measurement> items;

  const MeasurementSection({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return MeasurementItemCard(
          title: item.title,
          imageAsset: item.imageAsset,
          onTap: () {
            context.pushNamed(item.location);
          },
        );
      }).toList(),
    );
  }
}