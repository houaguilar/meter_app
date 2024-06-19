import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/providers.dart';
import '../../screens/widgets/widgets.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: constraints.maxWidth <= 800
                ? _buildMobileLayout()
                : _buildWebLayout(constraints),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return const Column(
      children: [
        SizedBox(height: 20),
        Expanded(child: _HomeScreenView()),
      ],
    );
  }

  Widget _buildWebLayout(BoxConstraints constraints) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            alignment: AlignmentDirectional.center,
            child: Row(
              children: [
                const Expanded(child: SizedBox()),
                SizedBox(
                  width: 800,
                  height: constraints.maxHeight,
                  child: const _HomeScreenView(),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeScreenView extends ConsumerWidget {
  const _HomeScreenView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeListItems = ref.watch(homeListItemsProvider);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Número de columnas
        childAspectRatio: 1.0, // Proporción del tamaño de los ítems
        crossAxisSpacing: 10, // Espacio horizontal entre ítems
        mainAxisSpacing: 10, // Espacio vertical entre ítems
      ),
      itemCount: homeListItems.length,
      itemBuilder: (context, index) {
        final item = homeListItems[index];
        return ImageCard(
          imagePath: item.imageAsset,
          title: item.title,
          location: item.location,
          bgColor: item.bgColor,
          onTap: () {
            context.pushNamed(homeListItems[index].location);
          },
        );
      },
    );
  }
}
