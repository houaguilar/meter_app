
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/widgets.dart';

class LadrilloScreen extends StatelessWidget {
  const LadrilloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Ladrillo',),
      body: _LadrilloScreenView(),
    );
  }
}

class _LadrilloScreenView extends ConsumerWidget {
  const _LadrilloScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tipoLadrilloProvider);
    final data = TipoLadrilloModel.generateTipoLadrillo();

    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Image.asset(data[index].imageAsset),
            title: Text(data[index].title),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              ref.read(tipoLadrilloProvider.notifier).selectLadrillo(data[index].title);
              context.pushNamed(data[index].location);
            },
          ),
        );
      },
      itemCount: data.length,
    );
  }
}