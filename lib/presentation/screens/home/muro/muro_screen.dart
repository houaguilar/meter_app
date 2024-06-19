import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/widgets.dart';

class MuroScreen extends StatelessWidget {
  const MuroScreen({super.key});
  static const String route = 'muro';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppBarWidget(titleAppBar: 'Muro',),
      body: _MuroView(),
    );
  }
}

class _MuroView extends StatelessWidget {
  const _MuroView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Que material usarás:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          const SizedBox(height: 15,),
          ElevatedButton(
            onPressed: () {
              context.pushNamed('ladrillo');
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            child: const Text("LADRILLO"),
          ),
          const SizedBox(height: 10,),
          ElevatedButton(
            onPressed: () {
              context.pushNamed('bloqueta');
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)
                )
            ),
            child: const Text("BLOQUETA"),
          ),
        ],
      ),
    );
  }
}

