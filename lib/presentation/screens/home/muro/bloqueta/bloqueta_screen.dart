
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../data/models/models.dart';
import '../../../../providers/providers.dart';
import '../../../widgets/widgets.dart';

class BloquetaScreen extends StatelessWidget {
  const BloquetaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(titleAppBar: "Bloqueta",),
      body: _BloquetaScreenView(),
    );
  }
}

class _BloquetaScreenView extends ConsumerWidget {
  const _BloquetaScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.watch(tipoBloquetaProvider);
    final data = TipoBloquetaModel.generateTipoBloqueta();

    return ListView.builder(
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Image.asset(data[index].imageAsset),
            title: Text(data[index].title),
            trailing: const Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              ref.read(tipoBloquetaProvider.notifier).selectBloqueta(data[index].title);
              context.pushNamed(data[index].location);
            },
          ),
        );
      },
      itemCount: data.length,
    );
  }
}
