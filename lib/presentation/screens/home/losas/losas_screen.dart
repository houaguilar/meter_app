import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

class _LosasView extends StatelessWidget {
  const _LosasView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              context.pushNamed('losas-aligeradas');
            },
            child: const Text('Listo'),
          ),
        ],
      ),
    );
  }
}
