import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/providers.dart';
import '../../widgets/widgets.dart';

class PisosScreen extends StatelessWidget {
  const PisosScreen({super.key});
  static const String route = 'pisos';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(titleAppBar: "Pisos",),
      body: _PisosView(),
    );
  }
}

class _PisosView extends ConsumerWidget {
  const _PisosView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.watch(tipoPisoProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Que vas a construir ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const SizedBox(height: 15,),
          ElevatedButton(
            onPressed: () {
              ref.read(tipoPisoProvider.notifier).selectPiso('falso');
              context.pushNamed('falso-piso');
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            child: const Text('FALSO PISO'),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              ref.read(tipoPisoProvider.notifier).selectPiso('contrapiso');
              context.pushNamed('contrapiso');
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            child: const Text('CONTRAPISO'),
          ),
        ],
      ),
    );
  }
}

